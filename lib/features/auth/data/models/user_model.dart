import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.cpf,
    required super.gender,
    super.accountType,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'] as String,
    name: json['name'] as String,
    email: json['email'] as String,
    cpf: json['cpf'] as String,
    gender: json['gender'] as String,
    accountType: json['account_type'] as String? ?? 'user',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'cpf': cpf,
    'gender': gender,
    'account_type': accountType,
  };
}
