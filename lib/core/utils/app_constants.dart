import 'package:nyxproject/features/user/domain/entities/user.dart';

class Constant {
  static const String _configuredBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://130.94.99.9:5001',
  );

  static String get BASE_URL =>
      _configuredBaseUrl.replaceFirst(RegExp(r'/+$'), '');

  // static const Tag_URL = "http://130.94.99.9:5000/api";

  static String get API_URL => '$BASE_URL/api';
  static User? user = null;
  static Map<String, String> headers = {"content-type": "application/json"};
}
