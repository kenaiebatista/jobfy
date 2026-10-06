import 'package:flutter_test/flutter_test.dart';
import 'package:jobfy/features/auth/data/datasources/auth_fake_data_source.dart';

void main() {
  group('AuthFakeDataSource', () {
    test('admin/admin logs in even though the password is under 6 characters', () async {
      final user = await AuthFakeDataSource().login('admin', 'admin');

      expect(user, isNotNull);
      expect(user!.name, 'Admin');
      expect(user.email, 'admin');
    });

    test('rejects admin email with the wrong password', () async {
      final user = await AuthFakeDataSource().login('admin', 'wrong');

      expect(user, isNull);
    });

    test('still accepts any email with a 6+ character password', () async {
      final user = await AuthFakeDataSource().login('someone@jobfy.app', 'password123');

      expect(user, isNotNull);
      expect(user!.email, 'someone@jobfy.app');
    });
  });
}
