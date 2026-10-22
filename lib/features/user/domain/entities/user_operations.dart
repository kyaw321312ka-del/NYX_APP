import 'package:nyxproject/features/user/domain/entities/authenticated_user.dart';
import 'package:nyxproject/features/user/domain/entities/user.dart';

class SignupChallenge {
  const SignupChallenge({required this.email, required this.tempToken});

  final String email;
  final String tempToken;
}

class PasswordChallenge {
  const PasswordChallenge({required this.tempToken, required this.message});

  final String tempToken;
  final String message;
}

class PasswordVerification {
  const PasswordVerification({required this.resetToken});

  final String resetToken;
}

class ProfileDetails {
  const ProfileDetails({required this.user, this.warning});

  final User user;
  final String? warning;
}

class ProfileUpdate {
  const ProfileUpdate({this.newToken});

  final String? newToken;
}

class ContactInformation {
  const ContactInformation({
    this.logoImageUrl,
    this.shopName,
    this.contactInfo,
    this.address,
    this.socialLink,
  });

  final String? logoImageUrl;
  final String? shopName;
  final String? contactInfo;
  final String? address;
  final String? socialLink;
}

class SignupAuthentication {
  const SignupAuthentication({required this.verified, this.authenticatedUser});

  final bool verified;
  final AuthenticatedUser? authenticatedUser;
}
