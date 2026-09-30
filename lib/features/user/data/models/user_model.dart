import 'package:nyxproject/features/user/domain/entities/user.dart';

class UserModel extends User {
  UserModel({
    super.id,
    super.name,
    super.email,
    super.phone,
    super.imageUrl,
    super.dateOfBirth,
    super.address,
    super.createdAt,
    super.updatedAt,
    super.warning,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final user = User.fromJson(json);
    return UserModel(
      id: user.id,
      name: user.name,
      email: user.email,
      phone: user.phone,
      imageUrl: user.imageUrl,
      dateOfBirth: user.dateOfBirth,
      address: user.address,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
      warning: user.warning,
    );
  }
}
