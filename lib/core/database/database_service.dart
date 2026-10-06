import 'dart:io' show Platform;

import 'package:bcrypt/bcrypt.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:mysql_client/exception.dart';
import 'package:mysql_client/mysql_client.dart';

/// Thrown by [DatabaseService.registerUser] when the email is already taken
/// (`uq_accounts_email`).
class EmailAlreadyInUseException implements Exception {
  const EmailAlreadyInUseException();
}

/// Thrown by [DatabaseService.registerUser] when the CPF is already taken
/// (`uq_users_cpf`).
class CpfAlreadyInUseException implements Exception {
  const CpfAlreadyInUseException();
}

class DatabaseService {
  /// MySQL error code for a duplicate key on a UNIQUE constraint.
  static const _duplicateEntry = 1062;

  /// The PC's IP on the Wi-Fi network (run `ipconfig` and look at the
  /// "Wi-Fi" adapter). Used by Android phones on the same Wi-Fi; the
  /// emulator reaches it too. Update it whenever you change networks.
  static const lanHost = '10.61.60.7';

  /// Optional override without editing code: `--dart-define=DB_HOST=x.x.x.x`.
  static const _hostOverride = String.fromEnvironment('DB_HOST');

  // Windows/desktop talks to the local MySQL through the loopback address.
  static String get host {
    if (_hostOverride.isNotEmpty) return _hostOverride;
    if (!kIsWeb && Platform.isAndroid) return lanHost;
    return '127.0.0.1';
  }

  static Future<MySQLConnection> connect() async {
    final conn = await MySQLConnection.createConnection(
      host: host,
      port: 3306,
      userName: 'Jobfy',
      password: 'Jobfy2026',
      databaseName: 'jobfy',
    );
    await conn.connect(timeoutMs: 5000);
    return conn;
  }

  /// Creates the whole sign-up in one transaction, so a failure never
  /// leaves half a user behind:
  ///   1. `accounts` (password hashed with bcrypt)
  ///   2. `users` (the profile, linked by account_id)
  ///   3. `skills` (only names that don't exist yet) + `user_skills`
  ///   4. `experiences`
  /// Dates are 'YYYY-MM-DD' strings; levels use the database ENUM values.
  static Future<void> registerUser({
    required String name,
    required String email,
    required String password,
    required String cpf,
    required String gender,
    String? phone,
    String? birthDate,
    String? educationLevel,
    List<({String name, String level})> skills = const [],
    List<
      ({
        String jobTitle,
        String companyName,
        String? description,
        String startDate,
        String? endDate,
      })
    >
    experiences = const [],
  }) async {
    final conn = await connect();

    try {
      await conn.transactional((conn) async {
        final account = await conn.execute(
          "INSERT INTO accounts (email, password_hash, account_type) "
          "VALUES (:email, :hash, 'user')",
          {'email': email, 'hash': BCrypt.hashpw(password, BCrypt.gensalt())},
        );

        final user = await conn.execute(
          'INSERT INTO users (account_id, name, cpf, gender, birth_date, '
          'phone, education_level) '
          'VALUES (:account, :name, :cpf, :gender, :birth, :phone, :education)',
          {
            'account': account.lastInsertID.toInt(),
            'name': name,
            'cpf': cpf,
            'gender': gender,
            'birth': birthDate,
            'phone': phone,
            'education': educationLevel,
          },
        );
        final userId = user.lastInsertID.toInt();

        for (final skill in skills) {
          // Reuses the existing skill if the name is already registered;
          // LAST_INSERT_ID(skill_id) makes lastInsertID return its id.
          final row = await conn.execute(
            'INSERT INTO skills (name) VALUES (:name) '
            'ON DUPLICATE KEY UPDATE skill_id = LAST_INSERT_ID(skill_id)',
            {'name': skill.name},
          );
          await conn.execute(
            'INSERT INTO user_skills (user_id, skill_id, level) '
            'VALUES (:user, :skill, :level)',
            {
              'user': userId,
              'skill': row.lastInsertID.toInt(),
              'level': skill.level,
            },
          );
        }

        for (final exp in experiences) {
          await conn.execute(
            'INSERT INTO experiences (user_id, job_title, company_name, '
            'description, start_date, end_date) '
            'VALUES (:user, :title, :company, :description, :start, :end)',
            {
              'user': userId,
              'title': exp.jobTitle,
              'company': exp.companyName,
              'description': exp.description,
              'start': exp.startDate,
              'end': exp.endDate,
            },
          );
        }
      });
    } on MySQLServerException catch (e) {
      if (e.errorCode == _duplicateEntry) {
        if (e.message.contains('uq_users_cpf')) {
          throw const CpfAlreadyInUseException();
        }
        throw const EmailAlreadyInUseException();
      }
      rethrow;
    } finally {
      await conn.close();
    }
  }

  /// Names of every skill in the `skills` table, for the sign-up form.
  static Future<List<String>> getSkillNames() async {
    final conn = await connect();

    try {
      final result = await conn.execute('SELECT name FROM skills ORDER BY name');
      return [for (final row in result.rows) row.colAt(0) ?? ''];
    } finally {
      await conn.close();
    }
  }

  /// Everything the dashboard shows about one user, read in a single
  /// connection. Returns null when [userId] doesn't exist.
  static Future<
    ({
      Map<String, String?> user,
      List<Map<String, String?>> skills,
      List<Map<String, String?>> experiences,
      int applications,
      List<Map<String, String?>> recentApplications,
    })?
  >
  getUserProfile(int userId) async {
    final conn = await connect();

    try {
      final user = await conn.execute(
        'SELECT u.*, a.email FROM users u '
        'JOIN accounts a ON a.account_id = u.account_id '
        'WHERE u.user_id = :id',
        {'id': userId},
      );
      if (user.rows.isEmpty) return null;

      final skills = await conn.execute(
        'SELECT s.name, us.level FROM user_skills us '
        'JOIN skills s ON s.skill_id = us.skill_id '
        'WHERE us.user_id = :id ORDER BY s.name',
        {'id': userId},
      );

      // Current job (end_date NULL) first, then the most recent ones.
      final experiences = await conn.execute(
        'SELECT job_title, company_name, description, start_date, end_date '
        'FROM experiences WHERE user_id = :id '
        'ORDER BY end_date IS NULL DESC, start_date DESC',
        {'id': userId},
      );

      final count = await conn.execute(
        'SELECT COUNT(*) FROM applications WHERE user_id = :id',
        {'id': userId},
      );

      final recent = await conn.execute(
        'SELECT j.title, c.company_name, ap.applied_at FROM applications ap '
        'JOIN jobs j ON j.job_id = ap.job_id '
        'JOIN companies c ON c.company_id = j.company_id '
        'WHERE ap.user_id = :id ORDER BY ap.applied_at DESC LIMIT 5',
        {'id': userId},
      );

      return (
        user: user.rows.first.assoc(),
        skills: [for (final r in skills.rows) r.assoc()],
        experiences: [for (final r in experiences.rows) r.assoc()],
        applications: int.parse(count.rows.first.colAt(0) ?? '0'),
        recentApplications: [for (final r in recent.rows) r.assoc()],
      );
    } finally {
      await conn.close();
    }
  }

  /// Saves the fields the settings screen edits: `users.name`,
  /// `users.phone` and the login email in `accounts`. Throws
  /// [EmailAlreadyInUseException] when the new email belongs to another
  /// account.
  static Future<void> updateUserAccount({
    required int userId,
    required String name,
    required String email,
    String? phone,
  }) async {
    final conn = await connect();

    try {
      await conn.transactional((conn) async {
        await conn.execute(
          'UPDATE users SET name = :name, phone = :phone WHERE user_id = :id',
          {'id': userId, 'name': name, 'phone': phone},
        );
        await conn.execute(
          'UPDATE accounts a JOIN users u ON u.account_id = a.account_id '
          'SET a.email = :email WHERE u.user_id = :id',
          {'id': userId, 'email': email},
        );
      });
    } on MySQLServerException catch (e) {
      if (e.errorCode == _duplicateEntry) {
        throw const EmailAlreadyInUseException();
      }
      rethrow;
    } finally {
      await conn.close();
    }
  }

  /// Replaces the account password after checking the current one.
  /// Returns false (and changes nothing) when [currentPassword] is wrong.
  static Future<bool> changePassword({
    required int userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    final conn = await connect();

    try {
      final result = await conn.execute(
        'SELECT a.account_id, a.password_hash FROM accounts a '
        'JOIN users u ON u.account_id = a.account_id '
        'WHERE u.user_id = :id',
        {'id': userId},
      );
      if (result.rows.isEmpty) return false;
      final row = result.rows.first.assoc();

      final hash = row['password_hash'];
      if (hash == null || !BCrypt.checkpw(currentPassword, hash)) return false;

      await conn.execute(
        'UPDATE accounts SET password_hash = :hash WHERE account_id = :account',
        {
          'account': row['account_id'],
          'hash': BCrypt.hashpw(newPassword, BCrypt.gensalt()),
        },
      );
      return true;
    } finally {
      await conn.close();
    }
  }

  /// "Deletes" the account the same way [login] understands it: sets
  /// `accounts.is_active` to FALSE, so the user can no longer sign in but
  /// their applications and history stay consistent for the companies.
  static Future<void> deactivateAccount(int userId) async {
    final conn = await connect();

    try {
      await conn.execute(
        'UPDATE accounts a JOIN users u ON u.account_id = a.account_id '
        'SET a.is_active = FALSE WHERE u.user_id = :id',
        {'id': userId},
      );
    } finally {
      await conn.close();
    }
  }

  // Returns the account row joined with its user profile (columns from
  // `accounts` + `users`), or null if the email/password don't match.
  static Future<Map<String, String?>?> login(
    String email,
    String password,
  ) async {
    final conn = await connect();

    try {
      final result = await conn.execute(
        'SELECT a.account_id, a.email, a.password_hash, a.account_type, '
        'u.user_id, u.name '
        'FROM accounts a LEFT JOIN users u ON u.account_id = a.account_id '
        'WHERE a.email = :email AND a.is_active = TRUE '
        'LIMIT 1',
        {'email': email},
      );

      if (result.rows.isEmpty) return null;
      final row = result.rows.first.assoc();

      final hash = row['password_hash'];
      if (hash == null || !BCrypt.checkpw(password, hash)) return null;

      return row..remove('password_hash');
    } finally {
      await conn.close();
    }
  }

  // Open jobs with the company name, already in the shape the app shows
  // (column names match JobListingModel). [query] searches title/company,
  // [location] searches the city.
  static Future<List<Map<String, String?>>> getOpenJobs({
    String? query,
    String? location,
  }) async {
    final conn = await connect();

    try {
      final result = await conn.execute(
        "SELECT CAST(j.job_id AS CHAR) AS id, j.title, "
        "c.company_name AS company, j.location, j.work_mode AS type, "
        "CONCAT('R\$ ', FORMAT(j.salary_min, 0, 'de_DE'), ' – ', "
        "FORMAT(j.salary_max, 0, 'de_DE')) AS salary, j.description "
        "FROM jobs j JOIN companies c ON c.company_id = j.company_id "
        "WHERE j.status = 'open' "
        "AND (j.title LIKE :query OR c.company_name LIKE :query) "
        "AND j.location LIKE :location "
        "ORDER BY j.published_at DESC",
        {'query': '%${query ?? ''}%', 'location': '%${location ?? ''}%'},
      );

      return result.rows.map((row) => row.assoc()).toList();
    } finally {
      await conn.close();
    }
  }
}
