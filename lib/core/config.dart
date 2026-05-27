class Config {
  static const String API_URL = "http://192.168.1.7:5000/";
  static const String login_url = "${API_URL}login";
  static const String register_url = "${API_URL}register";
  static const String chatRoom_url = "${API_URL}api/chat/chat-room";
  static const String getUser_url = "${API_URL}api/users/all/users";
  static const String getUserProfile_url = "${API_URL}api/users";
  static String verify_url(String otp) => "${API_URL}api/users/verify/$otp";
  static const String updatePublicKey_url = "${API_URL}api/users/public-key";
  static String getPublicKey_url(String userId) => "${API_URL}api/users/public-key/$userId";

  // POST
  static const String createPost_url = "${API_URL}api/post/";
  static const String getPosts_url = "${API_URL}api/post/";

  // CLOUDINARY
  static const String cloudinaryCloudName = "dwv7t8jvx";
  static const String cloudinaryApiKey = "671432955373339";
  static const String cloudinaryApiSecret = "TRm9HM19q9rSRY43JU3seJlGhXk";
  static const String cloudinaryUploadUrl =
      "https://api.cloudinary.com/v1_1/$cloudinaryCloudName/auto/upload";
}