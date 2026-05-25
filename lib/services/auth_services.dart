import 'dart:convert';

import 'package:chat_plugin/chat_plugin.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sanctuary/core/config.dart';
import 'package:sanctuary/screen/onboarding_screen.dart';
import 'package:sanctuary/services/encryption_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthServices {
  static Future<Map<String, dynamic>> loginUser(String userEmail, String password) async {
    try {
      final response = await http.post(Uri.parse(Config.login_url),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': userEmail, 'password': password}));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['userId'] != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('userId', data['userId']);
          await prefs.setString('token', data['token']);

          // Check verification status
          final bool isVerified = data['verification'] ?? false;
          await prefs.setBool('verified', isVerified);

          if (isVerified) {
            //CHAT PLUGINS
            await initializeChatPlugin();
            await Future.delayed(Duration(milliseconds: 500));
          }

          return {'success': true, 'verified': isVerified};
        }
      }
      return {'success': false, 'verified': false, 'message': 'Invalid credentials'};
    } catch (ex) {
      return {'success': false, 'verified': false, 'message': ex.toString()};
    }
  }

  static Future<bool> registerUser(String userName, String userEmail, String password) async {
    try {
      final response = await http.post(Uri.parse(Config.register_url),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'userName': userName,
            'email': userEmail,
            'password': password
          }));

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);

        if (data['userId'] != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('userId', data['userId']);
          await prefs.setString('token', data['token']);

          //CHAT PLUGINS
          await initializeChatPlugin();

          await Future.delayed(Duration(milliseconds: 500));

          return true;
        }
      }
      return false;
    } catch (ex) {
      return false;
    }
  }

  static Future<String?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  static Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId') != null ? true : false;
  }

  static Future<bool> isVerified() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('verified') ?? false;
  }

  static Future<String?> getUserToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<Map<String, dynamic>> verifyAccount(String otp) async {
    try {
      final token = await getUserToken();

      if (token == null) {
        return {'success': false, 'message': 'No auth token found. Please login again.'};
      }

      final response = await http.get(
        Uri.parse(Config.verify_url(otp)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Update stored token with the new one from verification
        if (data['userToken'] != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', data['userToken']);
          await prefs.setBool('verified', true);
        }

        // Initialize chat plugin after successful verification
        await initializeChatPlugin();
        await Future.delayed(Duration(milliseconds: 500));

        return {'success': true, 'message': 'Account verified successfully'};
      } else {
        final data = jsonDecode(response.body);
        return {'success': false, 'message': data['message'] ?? 'OTP verification failed'};
      }
    } catch (ex) {
      return {'success': false, 'message': ex.toString()};
    }
  }

  static Future<void> logoutUser(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    //chat
    try {
      if (ChatConfig.instance.userId != null) {
        ChatPlugin.chatService.fullDisconnect();
      }
    } catch (ex) {}

    await prefs.remove('userId');
    await prefs.remove('token');
    await prefs.clear();
    
    // Clear encryption cache
    EncryptionService.clearCache();

    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => OnboardingScreen()));
  }

  static Future<void> initializeChatPlugin() async {
    try {
      final userId = await AuthServices.getUserId();
      final token = await AuthServices.getUserToken();

      // Initialize E2EE Keys
      await EncryptionService.initialize();

      await ChatPlugin.initialize(
        config: ChatConfig(
            apiUrl: Config.API_URL,
            userId: userId,
            token: token,
            enableTypingIndicators: true,
            enableOnlineStatus: true,
            enableReadReceipts: true,
            autoMarkAsRead: true,
            maxReconnectionAttempts: 5,
            debugMode: true),
      );

      await _setupCHatAPIHandlers(userId!, token!);

      await ChatPlugin.chatService.initialize();
      await ChatPlugin.chatService.loadChatRooms();
    } catch (err) {}
  }

  static Future<void> _setupCHatAPIHandlers(String userId, String token) async {
    final apiHandlers = ChatApiHandlers(
        loadMessagesHandler: ({page = 1, limit = 20, searchText = ""}) async {
      final receiverId = ChatPlugin.chatService.receiverId;

      if (receiverId.isEmpty) return [];

      try {
        var url =
            "${Config.API_URL}api/chat/messages?senderId=$userId&receiverId=$receiverId&page=$page&limit=$limit";

        if (searchText.isNotEmpty) {
          url += "&searchText=${Uri.encodeComponent(searchText)}";
        }

        final response = await http.get(Uri.parse(url), headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        });

        if (response.statusCode == 200) {
          final List<dynamic> data = jsonDecode(response.body);

          return data.map((msg) => ChatMessage.fromMap(msg, userId)).toList();
        } else {
          return [];
        }
      } catch (ex) {
        return [];
      }
    }, loadMoreMessagesHandler: ({page = 1, limit = 20, searchText = ""}) async {
      final receiverId = ChatPlugin.chatService.receiverId;

      if (receiverId.isEmpty) return [];

      try {
        var url =
            "${Config.API_URL}api/chat/messages?senderId=$userId&receiverId=$receiverId&page=$page&limit=$limit";

        if (searchText.isNotEmpty) {
          url += "&searchText=${Uri.encodeComponent(searchText)}";
        }

        final response = await http.get(Uri.parse(url), headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        });

        if (response.statusCode == 200) {
          final List<dynamic> data = jsonDecode(response.body);

          return data.map((msg) => ChatMessage.fromMap(msg, userId)).toList();
        } else {
          return [];
        }
      } catch (ex) {
        return [];
      }
    }, loadChatRoomsHandler: () async {
      try {
        var url = Config.chatRoom_url;

        final response = await http.get(Uri.parse(url), headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        });

        if (response.statusCode == 200) {
          final List<dynamic> data = jsonDecode(response.body);

          return data.map((room) => ChatRoom.fromMap(room)).toList();
        } else {
          return [];
        }
      } catch (ex) {
        return [];
      }
    });

    ChatPlugin.chatService.setApiHandlers(apiHandlers);
  }

  static Future<List<dynamic>> fetchUsers() async {
    try {
      var token = await getUserToken();
      final response = await http.get(Uri.parse(Config.getUser_url),
          headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token',},);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      }
      return [];
    } catch (ex) {
      return [];
    }
  }
}
