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

/// Thrown by [DatabaseService.registerCompany] when the CNPJ is already
/// taken (`uq_companies_cnpj`).
class CnpjAlreadyInUseException implements Exception {
  const CnpjAlreadyInUseException();
}

/// A chat message was refused: the chat is only open between a user and a
/// company, and only while the company has approved that user's application.
class ChatNotAllowedException implements Exception {
  const ChatNotAllowedException();
}

class DatabaseService {
  /// MySQL error code for a duplicate key on a UNIQUE constraint.
  static const _duplicateEntry = 1062;

  /// The PC's IP on the Wi-Fi network (run `ipconfig` and look at the
  /// "Wi-Fi" adapter). Used by Android phones on the same Wi-Fi; the
  /// emulator reaches it too. Update it whenever you change networks.
  static const lanHost = '10.61.4.51';

  /// Optional override without editing code: `--dart-define=DB_HOST=x.x.x.x`.
  static const _hostOverride = String.fromEnvironment('DB_HOST');

  /// Same for the port: `--dart-define=DB_PORT=3307`.
  static const _port = int.fromEnvironment('DB_PORT', defaultValue: 3306);

  // Windows/desktop talks to the local MySQL through the loopback address.
  static String get host {
    if (_hostOverride.isNotEmpty) return _hostOverride;
    if (!kIsWeb && Platform.isAndroid) return lanHost;
    return '127.0.0.1';
  }

  static Future<MySQLConnection> connect() async {
    final conn = await MySQLConnection.createConnection(
      host: host,
      port: _port,
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
    String? educationLevel,
  }) async {
    final conn = await connect();

    try {
      await conn.transactional((conn) async {
        await conn.execute(
          'UPDATE users SET name = :name, phone = :phone, '
          'education_level = :education WHERE user_id = :id',
          {
            'id': userId,
            'name': name,
            'phone': phone,
            'education': educationLevel,
          },
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
        'u.user_id, u.name, c.company_id, c.company_name '
        'FROM accounts a LEFT JOIN users u ON u.account_id = a.account_id '
        'LEFT JOIN companies c ON c.account_id = a.account_id '
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
  // [location] searches the city, [area] searches `jobs.area` and
  // [contractType] is an exact `jobs.contract_type` value; empty filters
  // are ignored.
  static Future<List<Map<String, String?>>> getOpenJobs({
    String? query,
    String? location,
    String? area,
    String? contractType,
  }) async {
    final conn = await connect();

    try {
      final hasArea = (area ?? '').trim().isNotEmpty;
      final hasContract = (contractType ?? '').isNotEmpty;
      final result = await conn.execute(
        "SELECT CAST(j.job_id AS CHAR) AS id, j.title, "
        "c.company_name AS company, j.location, j.work_mode AS type, "
        "CONCAT('R\$ ', FORMAT(j.salary_min, 0, 'de_DE'), ' – ', "
        "FORMAT(j.salary_max, 0, 'de_DE')) AS salary, j.description "
        "FROM jobs j JOIN companies c ON c.company_id = j.company_id "
        "WHERE j.status = 'open' "
        "AND (j.title LIKE :query OR c.company_name LIKE :query) "
        "AND j.location LIKE :location "
        "${hasArea ? 'AND j.area LIKE :area ' : ''}"
        "${hasContract ? 'AND j.contract_type = :contract ' : ''}"
        "ORDER BY j.published_at DESC, j.job_id DESC",
        {
          'query': '%${query ?? ''}%',
          'location': '%${location ?? ''}%',
          if (hasArea) 'area': '%${area!.trim()}%',
          if (hasContract) 'contract': contractType,
        },
      );

      return result.rows.map((row) => row.assoc()).toList();
    } finally {
      await conn.close();
    }
  }

  /// One job with its company, for the job details screen, or null if it
  /// doesn't exist. `applied` is '1' when [userId] already applied to it.
  static Future<Map<String, String?>?> getJob(int jobId, {int? userId}) async {
    final conn = await connect();

    try {
      final result = await conn.execute(
        "SELECT CAST(j.job_id AS CHAR) AS id, j.title, j.area, j.location, "
        "j.work_mode, j.contract_type, j.workload, j.description, "
        "j.requirements, j.benefits, j.published_at, j.status, "
        "CONCAT('R\$ ', FORMAT(j.salary_min, 0, 'de_DE'), ' – ', "
        "FORMAT(j.salary_max, 0, 'de_DE')) AS salary, "
        "c.company_name, c.trade_name, c.business_area, c.city, c.state, "
        "c.phone AS company_phone, c.description AS company_description, "
        "a.email AS company_email, "
        "(SELECT ap.status FROM applications ap "
        "WHERE ap.job_id = j.job_id AND ap.user_id = :user) AS application_status "
        "FROM jobs j JOIN companies c ON c.company_id = j.company_id "
        "JOIN accounts a ON a.account_id = c.account_id "
        "WHERE j.job_id = :id",
        {'id': jobId, 'user': userId},
      );
      return result.rows.isEmpty ? null : result.rows.first.assoc();
    } finally {
      await conn.close();
    }
  }

  /// Saves the user's application to the job (`applications`). Applying
  /// twice is ignored (the UNIQUE (user_id, job_id) keeps a single row) and
  /// so is applying to a job that isn't open.
  static Future<void> applyToJob({required int userId, required int jobId}) async {
    final conn = await connect();

    try {
      await conn.execute(
        "INSERT IGNORE INTO applications (user_id, job_id) "
        "SELECT :user, job_id FROM jobs WHERE job_id = :job AND status = 'open'",
        {'user': userId, 'job': jobId},
      );
    } finally {
      await conn.close();
    }
  }

  /// Who applied to the job, newest first. Deactivated accounts are left
  /// out, like everywhere else in the app.
  static Future<List<Map<String, String?>>> getJobCandidates(int jobId) async {
    final conn = await connect();

    try {
      final result = await conn.execute(
        'SELECT CAST(u.user_id AS CHAR) AS user_id, u.name, a.email, u.phone, '
        'ap.applied_at, ap.status FROM applications ap '
        'JOIN users u ON u.user_id = ap.user_id '
        'JOIN accounts a ON a.account_id = u.account_id '
        'WHERE ap.job_id = :job AND a.is_active = TRUE '
        'ORDER BY ap.applied_at DESC, ap.application_id DESC',
        {'job': jobId},
      );
      return [for (final row in result.rows) row.assoc()];
    } finally {
      await conn.close();
    }
  }

  /// Creates a company sign-up in one transaction: the `accounts` row
  /// (password hashed with bcrypt) and its `companies` profile. Optional
  /// fields may be null. Returns the new company_id.
  static Future<int> registerCompany({
    required String email,
    required String password,
    required String cnpj,
    required String companyName,
    String? tradeName,
    String? phone,
    String? businessArea,
    String? zipCode,
    String? address,
    String? city,
    String? state,
    String? description,
  }) async {
    final conn = await connect();

    try {
      return await conn.transactional((conn) async {
        final account = await conn.execute(
          "INSERT INTO accounts (email, password_hash, account_type) "
          "VALUES (:email, :hash, 'company')",
          {'email': email, 'hash': BCrypt.hashpw(password, BCrypt.gensalt())},
        );
        final company = await conn.execute(
          'INSERT INTO companies (account_id, company_name, trade_name, cnpj, '
          'phone, business_area, zip_code, address, city, state, description) '
          'VALUES (:account, :name, :trade, :cnpj, :phone, :area, :zip, '
          ':address, :city, :state, :description)',
          {
            'account': account.lastInsertID.toInt(),
            'name': companyName,
            'trade': tradeName,
            'cnpj': cnpj,
            'phone': phone,
            'area': businessArea,
            'zip': zipCode,
            'address': address,
            'city': city,
            'state': state,
            'description': description,
          },
        );
        return company.lastInsertID.toInt();
      });
    } on MySQLServerException catch (e) {
      if (e.errorCode == _duplicateEntry) {
        if (e.message.contains('uq_companies_cnpj')) {
          throw const CnpjAlreadyInUseException();
        }
        throw const EmailAlreadyInUseException();
      }
      rethrow;
    } finally {
      await conn.close();
    }
  }

  /// The company profile (all `companies` columns plus the account email),
  /// or null if [companyId] doesn't exist.
  static Future<Map<String, String?>?> getCompany(int companyId) async {
    final conn = await connect();

    try {
      final result = await conn.execute(
        'SELECT c.*, a.email FROM companies c '
        'JOIN accounts a ON a.account_id = c.account_id '
        'WHERE c.company_id = :id',
        {'id': companyId},
      );
      return result.rows.isEmpty ? null : result.rows.first.assoc();
    } finally {
      await conn.close();
    }
  }

  /// Publishes a job for the company. `published_at` and `status` use the
  /// table defaults (today, 'open'), so it shows up for users right away.
  static Future<void> insertJob({
    required int companyId,
    required String title,
    String? area,
    required String location,
    required String workMode,
    required String description,
    required String contractType,
    required int salaryMin,
    required int salaryMax,
    String? workload,
    String? requirements,
    String? benefits,
  }) async {
    final conn = await connect();

    try {
      await conn.execute(
        'INSERT INTO jobs (company_id, title, area, location, work_mode, '
        'description, contract_type, salary_min, salary_max, workload, '
        'requirements, benefits) '
        'VALUES (:company, :title, :area, :location, :mode, :description, '
        ':contract, :min, :max, :workload, :requirements, :benefits)',
        {
          'company': companyId,
          'title': title,
          'area': area,
          'location': location,
          'mode': workMode,
          'description': description,
          'contract': contractType,
          'min': salaryMin,
          'max': salaryMax,
          'workload': workload,
          'requirements': requirements,
          'benefits': benefits,
        },
      );
    } finally {
      await conn.close();
    }
  }

  /// Rewrites the job's fields. The company id in the WHERE keeps a company
  /// from editing someone else's job.
  static Future<void> updateJob({
    required int jobId,
    required int companyId,
    required String title,
    String? area,
    required String location,
    required String workMode,
    required String description,
    required String contractType,
    required int salaryMin,
    required int salaryMax,
    String? workload,
    String? requirements,
    String? benefits,
  }) async {
    final conn = await connect();

    try {
      await conn.execute(
        'UPDATE jobs SET title = :title, area = :area, location = :location, '
        'work_mode = :mode, description = :description, '
        'contract_type = :contract, salary_min = :min, salary_max = :max, '
        'workload = :workload, requirements = :requirements, '
        'benefits = :benefits '
        'WHERE job_id = :id AND company_id = :company',
        {
          'id': jobId,
          'company': companyId,
          'title': title,
          'area': area,
          'location': location,
          'mode': workMode,
          'description': description,
          'contract': contractType,
          'min': salaryMin,
          'max': salaryMax,
          'workload': workload,
          'requirements': requirements,
          'benefits': benefits,
        },
      );
    } finally {
      await conn.close();
    }
  }

  /// Opens, pauses or closes ('open', 'paused', 'closed') one of the
  /// company's jobs.
  static Future<void> setJobStatus({
    required int jobId,
    required int companyId,
    required String status,
  }) async {
    final conn = await connect();

    try {
      await conn.execute(
        'UPDATE jobs SET status = :status '
        'WHERE job_id = :id AND company_id = :company',
        {'id': jobId, 'company': companyId, 'status': status},
      );
    } finally {
      await conn.close();
    }
  }

  /// The company's answer to an application: 'under_review', 'approved' or
  /// 'rejected'. Only applications to the company's own jobs can change.
  static Future<void> setApplicationStatus({
    required int jobId,
    required int userId,
    required int companyId,
    required String status,
  }) async {
    final conn = await connect();

    try {
      await conn.execute(
        'UPDATE applications ap JOIN jobs j ON j.job_id = ap.job_id '
        'SET ap.status = :status '
        'WHERE ap.job_id = :job AND ap.user_id = :user '
        'AND j.company_id = :company',
        {'job': jobId, 'user': userId, 'company': companyId, 'status': status},
      );
    } finally {
      await conn.close();
    }
  }

  /// Every job the company published (any status), newest first, with how
  /// many (active) users applied to each one.
  static Future<List<Map<String, String?>>> getCompanyJobs(int companyId) async {
    final conn = await connect();

    try {
      final result = await conn.execute(
        "SELECT CAST(job_id AS CHAR) AS id, title, description, location, "
        "area, work_mode, contract_type, status, salary_min, salary_max, "
        "workload, requirements, benefits, "
        "CONCAT('R\$ ', FORMAT(salary_min, 0, 'de_DE'), ' – ', "
        "FORMAT(salary_max, 0, 'de_DE')) AS salary, "
        "(SELECT COUNT(*) FROM applications ap "
        "JOIN users u ON u.user_id = ap.user_id "
        "JOIN accounts a ON a.account_id = u.account_id "
        "WHERE ap.job_id = jobs.job_id AND a.is_active = TRUE) AS candidates "
        "FROM jobs WHERE company_id = :id ORDER BY published_at DESC, job_id DESC",
        {'id': companyId},
      );
      return [for (final row in result.rows) row.assoc()];
    } finally {
      await conn.close();
    }
  }

  // ---------------------------------------------------------------------
  // Chat. A chat is between a user and a company, never user-user or
  // company-company, and only while the company has approved one of that
  // user's applications. Every query below is written from the point of
  // view of the signed-in side ([asCompany] + its profile [id]) and joins
  // the *other* kind of profile as the partner, so a same-kind pair can't
  // even be expressed; the send is one atomic INSERT ... SELECT that only
  // inserts when the approval exists.
  // ---------------------------------------------------------------------

  /// SQL pieces for one side of the chat. `me` is the signed-in profile
  /// (`:id`), `p` the partner (`:partner` when it's a single one) and
  /// [linked] holds when an application links them (used with the aliases
  /// `ap` applications and `j` jobs).
  static ({
    String meTable,
    String meKey,
    String partnerTable,
    String partnerKey,
    String partnerName,
    String linked,
  })
  _chatSide(bool asCompany) => asCompany
      ? (
          meTable: 'companies',
          meKey: 'company_id',
          partnerTable: 'users',
          partnerKey: 'user_id',
          partnerName: 'p.name',
          linked: 'ap.user_id = p.user_id AND j.company_id = :id',
        )
      : (
          meTable: 'users',
          meKey: 'user_id',
          partnerTable: 'companies',
          partnerKey: 'company_id',
          partnerName: "COALESCE(NULLIF(p.trade_name, ''), p.company_name)",
          linked: 'ap.user_id = :id AND j.company_id = p.company_id',
        );

  /// The signed-in side's chats and every message in them. Partners are the
  /// other side's profiles with an approved application to/from this one,
  /// plus anyone already talked to (history stays after an approval is
  /// taken back; `can_send` then is '0').
  static Future<
    ({
      List<Map<String, String?>> partners,
      List<Map<String, String?>> messages,
    })
  >
  getChat({required bool asCompany, required int id}) async {
    final side = _chatSide(asCompany);
    final approved =
        'EXISTS (SELECT 1 FROM applications ap JOIN jobs j ON j.job_id = ap.job_id '
        "WHERE ${side.linked} AND ap.status = 'approved')";
    final conn = await connect();

    try {
      final partners = await conn.execute(
        'SELECT CAST(p.${side.partnerKey} AS CHAR) AS partner_id, '
        '${side.partnerName} AS name, '
        '(SELECT j.title FROM applications ap JOIN jobs j ON j.job_id = ap.job_id '
        "WHERE ${side.linked} AND ap.status = 'approved' "
        'ORDER BY ap.applied_at DESC, ap.application_id DESC LIMIT 1) AS subtitle, '
        '$approved AS can_send, '
        '(SELECT COUNT(*) FROM messages m WHERE m.sender_id = p.account_id '
        'AND m.receiver_id = me.account_id AND m.is_read = FALSE) AS unread '
        'FROM ${side.partnerTable} p '
        'JOIN accounts pa ON pa.account_id = p.account_id AND pa.is_active = TRUE '
        'CROSS JOIN (SELECT account_id FROM ${side.meTable} '
        'WHERE ${side.meKey} = :id) me '
        'WHERE $approved '
        'OR EXISTS (SELECT 1 FROM messages m '
        'WHERE (m.sender_id = p.account_id AND m.receiver_id = me.account_id) '
        'OR (m.sender_id = me.account_id AND m.receiver_id = p.account_id))',
        {'id': id},
      );

      final messages = await conn.execute(
        'SELECT CAST(m.message_id AS CHAR) AS id, '
        'CAST(p.${side.partnerKey} AS CHAR) AS partner_id, '
        'm.sender_id = me.account_id AS mine, m.message AS body, '
        'm.sent_at, m.is_read '
        'FROM messages m '
        'CROSS JOIN (SELECT account_id FROM ${side.meTable} '
        'WHERE ${side.meKey} = :id) me '
        'JOIN ${side.partnerTable} p ON p.account_id = '
        'IF(m.sender_id = me.account_id, m.receiver_id, m.sender_id) '
        'WHERE m.sender_id = me.account_id OR m.receiver_id = me.account_id '
        'ORDER BY m.sent_at, m.message_id',
        {'id': id},
      );

      return (
        partners: [for (final r in partners.rows) r.assoc()],
        messages: [for (final r in messages.rows) r.assoc()],
      );
    } finally {
      await conn.close();
    }
  }

  /// Sends [text] from the signed-in side to the partner profile
  /// [partnerId] (a company when a user is signed in, a user when a company
  /// is). Throws [ChatNotAllowedException] unless the company approved one
  /// of the user's applications; both accounts must also be active.
  static Future<Map<String, String?>> sendChatMessage({
    required bool asCompany,
    required int id,
    required int partnerId,
    required String text,
  }) async {
    final side = _chatSide(asCompany);
    final conn = await connect();

    try {
      final result = await conn.execute(
        'INSERT INTO messages (sender_id, receiver_id, message) '
        'SELECT me.account_id, p.account_id, :text '
        'FROM (SELECT x.account_id FROM ${side.meTable} x '
        'JOIN accounts a ON a.account_id = x.account_id AND a.is_active = TRUE '
        'WHERE x.${side.meKey} = :id) me '
        'CROSS JOIN (SELECT * FROM ${side.partnerTable} '
        'WHERE ${side.partnerKey} = :partner) p '
        'JOIN accounts pa ON pa.account_id = p.account_id AND pa.is_active = TRUE '
        'WHERE EXISTS (SELECT 1 FROM applications ap '
        'JOIN jobs j ON j.job_id = ap.job_id '
        "WHERE ${side.linked} AND ap.status = 'approved')",
        {'id': id, 'partner': partnerId, 'text': text},
      );
      if (result.affectedRows == BigInt.zero) throw const ChatNotAllowedException();

      final sent = await conn.execute(
        'SELECT CAST(message_id AS CHAR) AS id, sent_at FROM messages '
        'WHERE message_id = :id',
        {'id': result.lastInsertID.toInt()},
      );
      return sent.rows.first.assoc();
    } finally {
      await conn.close();
    }
  }

  /// Marks as read what the partner sent to the signed-in side.
  static Future<void> markChatRead({
    required bool asCompany,
    required int id,
    required int partnerId,
  }) async {
    final side = _chatSide(asCompany);
    final conn = await connect();

    try {
      await conn.execute(
        'UPDATE messages m '
        'JOIN ${side.meTable} x ON x.account_id = m.receiver_id '
        'AND x.${side.meKey} = :id '
        'JOIN ${side.partnerTable} p ON p.account_id = m.sender_id '
        'AND p.${side.partnerKey} = :partner '
        'SET m.is_read = TRUE WHERE m.is_read = FALSE',
        {'id': id, 'partner': partnerId},
      );
    } finally {
      await conn.close();
    }
  }
}
