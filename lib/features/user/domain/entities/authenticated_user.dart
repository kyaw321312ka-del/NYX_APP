import 'package:nyxproject/features/user/domain/entities/user.dart';

class AuthenticatedUser {
  const AuthenticatedUser({required this.user, required this.token});

  final User user;
  final String token;
}
