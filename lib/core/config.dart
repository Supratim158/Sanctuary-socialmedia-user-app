class Config {
  static const String API_URL = "http://192.168.1.7:5000/";
  static const String login_url = "${API_URL}login";
  static const String register_url = "${API_URL}register";
  static const String chatRoom_url = "${API_URL}api/chat/chat-room";
  static const String getUser_url = "${API_URL}api/users/all/users";
  static String verify_url(String otp) => "${API_URL}api/users/verify/$otp";
  static const String updatePublicKey_url = "${API_URL}api/users/public-key";
  static String getPublicKey_url(String userId) => "${API_URL}api/users/public-key/$userId";
}