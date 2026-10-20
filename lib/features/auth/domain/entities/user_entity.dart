/// Who signed in. [id] is the `users.user_id` for job seekers, or the
/// `companies.company_id` when [isCompany].
class UserEntity {
  final String id;
  final String name;
  final String email;
  final String cpf;
  final String gender;

  /// `accounts.account_type`: 'user' or 'company'.
  final String accountType;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.cpf,
    required this.gender,
    this.accountType = 'user',
  });

  bool get isCompany => accountType == 'company';
}
