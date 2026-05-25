import 'dart:convert';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:sanctuary/core/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// End-to-end encryption service using X25519 key exchange + AES-256-GCM.
///
/// Flow:
/// 1. Each user generates an X25519 key pair on registration/login
/// 2. Public key is uploaded to the server; private key stays on device
/// 3. When chatting, a shared secret is derived via ECDH (my private + their public)
/// 4. Messages are encrypted with AES-256-GCM using the derived key
/// 5. Server only ever sees ciphertext
class EncryptionService {
  static const _privateKeyStorageKey = 'e2ee_private_key';
  static const _publicKeyStorageKey = 'e2ee_public_key';

  static final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static final X25519 _x25519 = X25519();
  static final AesGcm _aesGcm = AesGcm.with256bits();

  /// Cache derived shared secret keys per receiver to avoid re-computing
  static final Map<String, SecretKey> _sharedSecretCache = {};

  /// Cache fetched public keys
  static final Map<String, SimplePublicKey> _publicKeyCache = {};

  // ─── INITIALIZATION ───────────────────────────────────────

  /// Initialize E2EE: generate key pair if needed, upload public key to server.
  /// Call this after successful login/registration/verification.
  static Future<void> initialize() async {
    try {
      final existingPrivateKey = await _secureStorage.read(key: _privateKeyStorageKey);

      if (existingPrivateKey == null) {
        // Generate a new key pair
        await _generateAndStoreKeyPair();
      }

      // Always upload public key to server (handles device re-installs)
      await uploadPublicKey();
    } catch (e) {
      print('[EncryptionService] Error initializing E2EE: $e');
    }
  }

  /// Generate a new X25519 key pair and store it securely.
  static Future<void> _generateAndStoreKeyPair() async {
    final keyPair = await _x25519.newKeyPair();

    // Extract and store private key bytes
    final privateKeyBytes = await keyPair.extractPrivateKeyBytes();
    final privateKeyBase64 = base64Encode(privateKeyBytes);
    await _secureStorage.write(key: _privateKeyStorageKey, value: privateKeyBase64);

    // Extract and store public key bytes
    final publicKey = await keyPair.extractPublicKey();
    final publicKeyBase64 = base64Encode(publicKey.bytes);
    await _secureStorage.write(key: _publicKeyStorageKey, value: publicKeyBase64);

    print('[EncryptionService] Generated and stored new X25519 key pair');
  }

  /// Get the local key pair from secure storage.
  static Future<SimpleKeyPairData?> _getLocalKeyPair() async {
    try {
      final privateKeyBase64 = await _secureStorage.read(key: _privateKeyStorageKey);
      final publicKeyBase64 = await _secureStorage.read(key: _publicKeyStorageKey);

      if (privateKeyBase64 == null || publicKeyBase64 == null) return null;

      final privateKeyBytes = base64Decode(privateKeyBase64);
      final publicKeyBytes = base64Decode(publicKeyBase64);

      return SimpleKeyPairData(
        privateKeyBytes,
        publicKey: SimplePublicKey(publicKeyBytes, type: KeyPairType.x25519),
        type: KeyPairType.x25519,
      );
    } catch (e) {
      print('[EncryptionService] Error reading local key pair: $e');
      return null;
    }
  }

  // ─── PUBLIC KEY EXCHANGE ──────────────────────────────────

  /// Upload this user's public key to the server.
  static Future<void> uploadPublicKey() async {
    try {
      final publicKeyBase64 = await _secureStorage.read(key: _publicKeyStorageKey);
      if (publicKeyBase64 == null) return;

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) return;

      final response = await http.put(
        Uri.parse(Config.updatePublicKey_url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'publicKey': publicKeyBase64}),
      );

      if (response.statusCode == 200) {
        print('[EncryptionService] Public key uploaded successfully');
      } else {
        print('[EncryptionService] Failed to upload public key: ${response.statusCode}');
      }
    } catch (e) {
      print('[EncryptionService] Error uploading public key: $e');
    }
  }

  /// Fetch a remote user's public key from the server.
  static Future<SimplePublicKey?> fetchPublicKey(String userId) async {
    // Check cache first
    if (_publicKeyCache.containsKey(userId)) {
      return _publicKeyCache[userId];
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) return null;

      final response = await http.get(
        Uri.parse(Config.getPublicKey_url(userId)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final publicKeyBase64 = data['publicKey'];

        if (publicKeyBase64 == null) {
          print('[EncryptionService] User $userId has no public key (E2EE not set up)');
          return null;
        }

        final publicKeyBytes = base64Decode(publicKeyBase64);
        final publicKey = SimplePublicKey(publicKeyBytes, type: KeyPairType.x25519);

        // Cache it
        _publicKeyCache[userId] = publicKey;
        return publicKey;
      }

      return null;
    } catch (e) {
      print('[EncryptionService] Error fetching public key for $userId: $e');
      return null;
    }
  }

  // ─── SHARED SECRET DERIVATION ─────────────────────────────

  /// Derive a shared AES-256 key from our private key + their public key.
  /// Uses X25519 ECDH + HKDF for key derivation.
  static Future<SecretKey?> _deriveSharedSecret(String remoteUserId) async {
    // Check cache
    if (_sharedSecretCache.containsKey(remoteUserId)) {
      return _sharedSecretCache[remoteUserId];
    }

    try {
      // Get our key pair
      final localKeyPair = await _getLocalKeyPair();
      if (localKeyPair == null) {
        print('[EncryptionService] No local key pair found');
        return null;
      }

      // Get their public key
      final remotePublicKey = await fetchPublicKey(remoteUserId);
      if (remotePublicKey == null) {
        print('[EncryptionService] No remote public key for $remoteUserId');
        return null;
      }

      // X25519 ECDH: derive shared secret
      final sharedSecret = await _x25519.sharedSecretKey(
        keyPair: localKeyPair,
        remotePublicKey: remotePublicKey,
      );

      // HKDF: stretch into a proper 32-byte AES key
      final hkdf = Hkdf(hmac: Hmac(Sha256()), outputLength: 32);
      final derivedKey = await hkdf.deriveKey(
        secretKey: sharedSecret,
        nonce: utf8.encode('sanctuary-e2ee-v1'), // domain separation
      );

      // Cache it
      _sharedSecretCache[remoteUserId] = derivedKey;
      return derivedKey;
    } catch (e) {
      print('[EncryptionService] Error deriving shared secret: $e');
      return null;
    }
  }

  // ─── ENCRYPT / DECRYPT ────────────────────────────────────

  /// Encrypt a plaintext message for a specific receiver.
  /// Returns a base64-encoded JSON payload containing version, nonce, ciphertext, and MAC.
  /// Returns the original plaintext if encryption fails (graceful fallback).
  static Future<String> encryptMessage(String plaintext, String receiverId) async {
    try {
      final secretKey = await _deriveSharedSecret(receiverId);
      if (secretKey == null) {
        // Can't encrypt — receiver may not have E2EE set up yet
        return plaintext;
      }

      // Encrypt with AES-256-GCM (random nonce generated automatically)
      final secretBox = await _aesGcm.encryptString(
        plaintext,
        secretKey: secretKey,
      );

      // Package into a JSON payload
      final payload = {
        'v': 1,
        'nonce': base64Encode(secretBox.nonce),
        'ct': base64Encode(secretBox.cipherText),
        'mac': base64Encode(secretBox.mac.bytes),
      };

      // Return as base64-encoded JSON so it's a clean string
      return 'E2EE:${base64Encode(utf8.encode(jsonEncode(payload)))}';
    } catch (e) {
      print('[EncryptionService] Encryption failed: $e');
      return plaintext; // Graceful fallback
    }
  }

  /// Decrypt an encrypted message from a specific sender.
  /// Returns the decrypted plaintext, or the original string if it's not encrypted.
  static Future<String> decryptMessage(String encryptedPayload, String senderId) async {
    try {
      // Check if this is an encrypted message
      if (!isEncrypted(encryptedPayload)) {
        return encryptedPayload; // Not encrypted, return as-is
      }

      final secretKey = await _deriveSharedSecret(senderId);
      if (secretKey == null) {
        return '🔒 Encrypted message';
      }

      // Extract the base64 JSON payload
      final base64Payload = encryptedPayload.substring(5); // Remove 'E2EE:' prefix
      final jsonString = utf8.decode(base64Decode(base64Payload));
      final payload = jsonDecode(jsonString);

      // Reconstruct the SecretBox
      final nonce = base64Decode(payload['nonce']);
      final cipherText = base64Decode(payload['ct']);
      final mac = Mac(base64Decode(payload['mac']));

      final secretBox = SecretBox(
        cipherText,
        nonce: nonce,
        mac: mac,
      );

      // Decrypt
      final decrypted = await _aesGcm.decryptString(
        secretBox,
        secretKey: secretKey,
      );

      return decrypted;
    } catch (e) {
      print('[EncryptionService] Decryption failed: $e');
      return '🔒 Encrypted message';
    }
  }

  /// Check if a message string is E2EE encrypted.
  static bool isEncrypted(String message) {
    return message.startsWith('E2EE:');
  }

  /// Pre-fetch and cache a user's public key + derive shared secret.
  /// Call this when entering a chat to avoid latency on first message.
  static Future<void> prefetchKeys(String userId) async {
    await _deriveSharedSecret(userId);
  }

  /// Clear cached keys (call on logout).
  static void clearCache() {
    _sharedSecretCache.clear();
    _publicKeyCache.clear();
  }

  /// Delete stored keys (call on account deletion).
  static Future<void> deleteKeys() async {
    await _secureStorage.delete(key: _privateKeyStorageKey);
    await _secureStorage.delete(key: _publicKeyStorageKey);
    clearCache();
  }
}
