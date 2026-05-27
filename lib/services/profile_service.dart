import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:sanctuary/core/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileService {

  static Future<Map<String, dynamic>?> getProfile() async {

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final response = await http.get(
        Uri.parse(Config.getUserProfile_url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
      );

      if(response.statusCode == 200){
        return jsonDecode(response.body);
      }

      debugPrint("ProfileService: Failed with status ${response.statusCode}: ${response.body}");
      return null;

    } catch (e) {
      debugPrint("ProfileService: Exception - $e");
      return null;
    }
  }
}