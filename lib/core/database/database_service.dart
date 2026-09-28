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

  /// Creates the `accounts` row (password hashed with bcrypt) and its
  /// `users` profile in one transaction, so a failure never leaves an
  /// account without a profile.
  static Future<void> registerUser(String name, String email, String password) async {
    final conn = await connect();

    try {
      await conn.transactional((conn) async {
        final result = await conn.execute(
          "INSERT INTO accounts (email, password_hash, account_type) "
          "VALUES (:email, :hash, 'user')",
          {'email': email, 'hash': BCrypt.hashpw(password, BCrypt.gensalt())},
        );

        await conn.execute(
          'INSERT INTO users (account_id, name) VALUES (:id, :name)',
          {'id': result.lastInsertID.toInt(), 'name': name},
        );
      });
    } on MySQLServerException catch (e) {
      if (e.errorCode == _duplicateEntry) throw const EmailAlreadyInUseException();
      rethrow;
    } finally {
      await conn.close();
    }
  }

  // Returns the account row joined with its user profile (columns from
  // `accounts` + `users`), or null if the email/password don't match.
  static Future<Map<String, String?>?> login(String email, String password) async {
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
}
