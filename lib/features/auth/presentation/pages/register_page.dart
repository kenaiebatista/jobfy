import 'package:jobfy/core/session/user_session_controller.dart';
import 'package:jobfy/core/theme/app_breakpoints.dart';
import 'package:jobfy/core/theme/build_context_x.dart';
import 'package:jobfy/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:jobfy/features/auth/domain/entities/registration_entity.dart';
import 'package:jobfy/features/auth/domain/usecases/get_skill_names_usecase.dart';
import 'package:jobfy/features/auth/domain/usecases/login_usecase.dart';
import 'package:jobfy/features/auth/domain/usecases/register_usecase.dart';
import 'package:jobfy/features/auth/presentation/controllers/auth_controller.dart';
import 'package:jobfy/features/user/domain/entities/user_profile_entity.dart';
import 'package:jobfy/features/user/presentation/user_labels.dart';
import 'package:jobfy/l10n/app_localizations.dart';
import 'package:jobfy/shared/widgets/hover_link.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

/// Sign-up for job seekers. Fills every column of the `users` table plus
/// the user's skills (`user_skills`) and experiences (`experiences`).
/// Only name, email, CPF, password and gender are required.
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cpfController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otherSkillController = TextEditingController();
  Gender _gender = Gender.male;
  DateTime? _birthDate;
  EducationLevel? _education;
  bool _acceptedTerms = false;

  /// Skill names offered as chips (from the `skills` table, plus any the
  /// user typed), and the ones picked with their level.
  List<String> _skillOptions = [];
  bool _skillsLoadFailed = false;
  final Map<String, SkillLevel> _selectedSkills = {};

  final List<ExperienceEntity> _experiences = [];

  late final AuthController _authController;

  @override
  void initState() {
    super.initState();
    final repo = AuthRepositoryImpl();
    _authController = AuthController(LoginUsecase(repo), RegisterUsecase(repo));
    GetSkillNamesUsecase(repo)().then(
      (names) {
        if (mounted) setState(() => _skillOptions = names);
      },
      onError: (_) {
        if (mounted) setState(() => _skillsLoadFailed = true);
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cpfController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _otherSkillController.dispose();
    _authController.dispose();
    super.dispose();
  }

  String _errorMessage(AppLocalizations l10n, AuthErrorCode code) => switch (code) {
        AuthErrorCode.invalidCredentials => l10n.authErrorInvalidCredentials,
        AuthErrorCode.registrationFailed => l10n.authErrorRegistrationFailed,
        AuthErrorCode.emailInUse => l10n.authErrorEmailInUse,
        AuthErrorCode.cpfInUse => l10n.authErrorCpfInUse,
        AuthErrorCode.network => l10n.authErrorNetwork,
      };

  static String _digits(String s) => s.replaceAll(RegExp(r'\D'), '');

  Future<void> _handleRegister() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.termsRequiredError)),
      );
      return;
    }
    final phone = _phoneController.text.trim();
    final ok = await _authController.register(RegistrationEntity(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      cpf: _digits(_cpfController.text),
      gender: _gender,
      phone: phone.isEmpty ? null : phone,
      birthDate: _birthDate,
      educationLevel: _education,
      skills: [
        for (final e in _selectedSkills.entries)
          UserSkillEntity(name: e.key, level: e.value),
      ],
      experiences: List.of(_experiences),
    ));
    if (ok && mounted) {
      context.read<UserSessionController>().start(_authController.user!.id);
      context.go('/user');
    }
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 18),
      firstDate: DateTime(1920),
      lastDate: now,
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  void _addOtherSkill() {
    final name = _otherSkillController.text.trim();
    if (name.isEmpty) return;
    // Reuse the catalog's spelling if the skill already exists.
    final existing = _skillOptions.firstWhere(
      (s) => s.toLowerCase() == name.toLowerCase(),
      orElse: () => name,
    );
    setState(() {
      if (!_skillOptions.contains(existing)) _skillOptions.add(existing);
      _selectedSkills.putIfAbsent(existing, () => SkillLevel.beginner);
      _otherSkillController.clear();
    });
  }

  Future<void> _addExperience() async {
    final experience = await showDialog<ExperienceEntity>(
      context: context,
      builder: (_) => const _ExperienceDialog(),
    );
    if (experience != null) setState(() => _experiences.add(experience));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _buildScaffold(context, l10n);
  }

  Widget _buildScaffold(BuildContext context, AppLocalizations l10n) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: context.pagePadding,
            vertical: context.responsive(mobile: 24.0, laptop: 48.0),
          ),
          child: Column(
            spacing: 12,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: [
                  const Icon(Icons.lightbulb_circle, size: 36),
                  Text(
                    l10n.appName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
              Text(
                l10n.registerTitle,
                style: TextStyle(
                  fontSize: context.responsive(mobile: 26.0, laptop: 32.0),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                l10n.registerSubtitle,
                style: TextStyle(fontSize: 14, color: colors.textMuted),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 520),
                padding: EdgeInsets.all(context.responsive(mobile: 20.0, laptop: 32.0)),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: colors.surfaceBorder),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListenableBuilder(
                  listenable: _authController,
                  builder: (context, _) {
                    return Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 16,
                        children: [
                          _SectionTitle(l10n.registerSectionPersonal),
                          ..._personalFields(l10n),
                          const Divider(height: 8),
                          _SectionTitle(l10n.registerSectionSkills),
                          _skillsSection(l10n),
                          const Divider(height: 8),
                          _SectionTitle(l10n.registerSectionExperience),
                          _experienceSection(l10n),
                          const Divider(height: 8),
                          _termsRow(l10n),
                          if (_authController.errorCode != null) _errorBox(l10n),
                          _submitButton(l10n),
                          Center(
                            child: HoverLink(
                              label: l10n.alreadyHaveAccount,
                              onTap: () => context.go('/login'),
                              style: (hovered) => TextStyle(
                                fontSize: 13,
                                color: hovered ? colors.accent : colors.textMuted,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _personalFields(AppLocalizations l10n) {
    String? required(String? v) =>
        (v == null || v.trim().isEmpty) ? l10n.fieldRequired : null;
    final optional = l10n.optionalSuffix;

    return [
      TextFormField(
        controller: _nameController,
        textCapitalization: TextCapitalization.words,
        validator: required,
        decoration: InputDecoration(
          labelText: l10n.fullNameLabel,
          hintText: l10n.fullNameHint,
          prefixIcon: const Icon(Icons.person_outline, size: 18),
        ),
      ),
      TextFormField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        validator: (v) {
          if (v == null || v.trim().isEmpty) return l10n.fieldRequired;
          final valid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim());
          return valid ? null : l10n.emailInvalid;
        },
        decoration: InputDecoration(
          labelText: l10n.emailLabel,
          hintText: l10n.emailHint,
          prefixIcon: const Icon(Icons.email_outlined, size: 18),
        ),
      ),
      TextFormField(
        controller: _cpfController,
        keyboardType: TextInputType.number,
        validator: (v) {
          if (v == null || v.trim().isEmpty) return l10n.fieldRequired;
          return _digits(v).length == 11 ? null : l10n.cpfInvalid;
        },
        decoration: InputDecoration(
          labelText: l10n.cpfLabel,
          hintText: l10n.cpfHint,
          prefixIcon: const Icon(Icons.badge_outlined, size: 18),
        ),
      ),
      TextFormField(
        controller: _passwordController,
        obscureText: true,
        validator: (v) {
          if (v == null || v.isEmpty) return l10n.fieldRequired;
          return v.length >= 6 ? null : l10n.passwordTooShort;
        },
        decoration: InputDecoration(
          labelText: l10n.passwordLabel,
          hintText: l10n.passwordHintMin6,
          prefixIcon: const Icon(Icons.lock_outline, size: 18),
        ),
      ),
      TextFormField(
        controller: _phoneController,
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(
          labelText: '${l10n.phoneLabel} $optional',
          hintText: l10n.phoneHint,
          prefixIcon: const Icon(Icons.phone_outlined, size: 18),
        ),
      ),
      InkWell(
        onTap: _pickBirthDate,
        borderRadius: BorderRadius.circular(12),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: '${l10n.birthDateLabel} $optional',
            prefixIcon: const Icon(Icons.cake_outlined, size: 18),
          ),
          child: Text(_birthDate == null ? '' : formatDate(_birthDate!)),
        ),
      ),
      DropdownButtonFormField<EducationLevel>(
        initialValue: _education,
        isExpanded: true,
        onChanged: (v) => setState(() => _education = v),
        decoration: InputDecoration(
          labelText: '${l10n.educationLevelLabel} $optional',
          prefixIcon: const Icon(Icons.school_outlined, size: 18),
        ),
        items: [
          for (final level in EducationLevel.values)
            DropdownMenuItem(
              value: level,
              child: Text(l10n.educationLevel(level), overflow: TextOverflow.ellipsis),
            ),
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Text(
            l10n.genderLabel,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: context.colors.textPrimary,
            ),
          ),
          RadioGroup<Gender>(
            groupValue: _gender,
            onChanged: (v) => setState(() => _gender = v!),
            child: Material(
              type: MaterialType.transparency,
              child: Row(
                children: Gender.values
                    .map((g) => Expanded(
                          child: RadioListTile<Gender>(
                            value: g,
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              l10n.gender(g),
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    ];
  }

  Widget _skillsSection(AppLocalizations l10n) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        Text(
          _skillsLoadFailed ? l10n.registerSkillsLoadError : l10n.registerSkillsHint,
          style: TextStyle(
            fontSize: 12,
            color: _skillsLoadFailed ? colors.danger : colors.textMuted,
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            for (final name in _skillOptions)
              FilterChip(
                label: Text(name, style: const TextStyle(fontSize: 12)),
                selected: _selectedSkills.containsKey(name),
                onSelected: (on) => setState(() {
                  on
                      ? _selectedSkills[name] = SkillLevel.beginner
                      : _selectedSkills.remove(name);
                }),
              ),
          ],
        ),
        Row(
          spacing: 8,
          children: [
            Expanded(
              child: TextField(
                controller: _otherSkillController,
                onSubmitted: (_) => _addOtherSkill(),
                decoration: InputDecoration(
                  hintText: l10n.otherSkillHint,
                  isDense: true,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: _addOtherSkill,
              icon: const Icon(Icons.add, size: 16),
              label: Text(l10n.addSkill),
            ),
          ],
        ),
        // One row per picked skill to choose its level.
        for (final entry in _selectedSkills.entries)
          Row(
            children: [
              Expanded(
                child: Text(entry.key, style: const TextStyle(fontSize: 13)),
              ),
              DropdownButton<SkillLevel>(
                value: entry.value,
                isDense: true,
                underline: const SizedBox.shrink(),
                onChanged: (v) => setState(() => _selectedSkills[entry.key] = v!),
                items: [
                  for (final level in SkillLevel.values)
                    DropdownMenuItem(
                      value: level,
                      child: Text(l10n.skillLevel(level), style: const TextStyle(fontSize: 13)),
                    ),
                ],
              ),
            ],
          ),
      ],
    );
  }

  Widget _experienceSection(AppLocalizations l10n) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        if (_experiences.isEmpty)
          Text(
            l10n.noExperiencesYet,
            style: TextStyle(fontSize: 12, color: colors.textMuted),
          ),
        for (final (i, exp) in _experiences.indexed)
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: colors.surfaceBorder),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exp.jobTitle,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '${exp.companyName} · ${formatMonthYear(exp.startDate)} – '
                        '${exp.endDate == null ? l10n.experiencePresent : formatMonthYear(exp.endDate!)}',
                        style: TextStyle(fontSize: 12, color: colors.textMuted),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18),
                  onPressed: () => setState(() => _experiences.removeAt(i)),
                ),
              ],
            ),
          ),
        OutlinedButton.icon(
          onPressed: _addExperience,
          icon: const Icon(Icons.add, size: 16),
          label: Text(l10n.addExperience),
        ),
      ],
    );
  }

  Widget _termsRow(AppLocalizations l10n) {
    final colors = context.colors;
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: Checkbox(
            value: _acceptedTerms,
            onChanged: (v) => setState(() => _acceptedTerms = v!),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        Text(
          l10n.acceptTermsPrefix,
          style: const TextStyle(fontSize: 13),
        ),
        HoverLink(
          label: l10n.termsOfService,
          onTap: () => _showTerms(context),
          style: (_) => TextStyle(
            fontSize: 13,
            color: colors.accent,
            decoration: TextDecoration.underline,
          ),
        ),
      ],
    );
  }

  Widget _errorBox(AppLocalizations l10n) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.danger.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: colors.danger.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        _errorMessage(l10n, _authController.errorCode!),
        style: TextStyle(
          color: colors.danger,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _submitButton(AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _authController.isLoading ? null : _handleRegister,
        style: ElevatedButton.styleFrom(
          backgroundColor: context.colors.textPrimary,
          foregroundColor: context.colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _authController.isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: context.colors.surface,
                  strokeWidth: 2,
                ),
              )
            : Text(
                l10n.registerButton,
                style: const TextStyle(fontSize: 15),
              ),
      ),
    );
  }

  void _showTerms(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: context.colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 560, maxHeight: 480),
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: [
              Row(
                children: [
                  Text(
                    l10n.termsDialogTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    style: IconButton.styleFrom(
                      backgroundColor: context.colors.background,
                    ),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    l10n.termsDialogBody,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.7,
                      color: context.colors.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
    );
  }
}

/// Form for one row of `experiences`. Pops with the [ExperienceEntity], or
/// null if cancelled.
class _ExperienceDialog extends StatefulWidget {
  const _ExperienceDialog();

  @override
  State<_ExperienceDialog> createState() => _ExperienceDialogState();
}

class _ExperienceDialogState extends State<_ExperienceDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _companyController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _start;
  DateTime? _end;
  bool _current = false;
  String? _dateError;

  @override
  void dispose() {
    _titleController.dispose();
    _companyController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<DateTime?> _pick(DateTime? initial) => showDatePicker(
        context: context,
        initialDate: initial ?? DateTime.now(),
        firstDate: DateTime(1950),
        lastDate: DateTime.now(),
      );

  void _save(AppLocalizations l10n) {
    final fieldsOk = _formKey.currentState!.validate();
    setState(() {
      _dateError = _start == null
          ? l10n.fieldRequired
          : (!_current && _end != null && _end!.isBefore(_start!))
              ? l10n.experienceDatesInvalid
              : null;
    });
    if (!fieldsOk || _dateError != null) return;

    final description = _descriptionController.text.trim();
    Navigator.pop(
      context,
      ExperienceEntity(
        jobTitle: _titleController.text.trim(),
        companyName: _companyController.text.trim(),
        description: description.isEmpty ? null : description,
        startDate: _start!,
        endDate: _current ? null : _end,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    String? required(String? v) =>
        (v == null || v.trim().isEmpty) ? l10n.fieldRequired : null;

    return AlertDialog(
      title: Text(l10n.addExperience),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 12,
              children: [
                TextFormField(
                  controller: _titleController,
                  validator: required,
                  decoration: InputDecoration(labelText: l10n.experienceJobTitleLabel),
                ),
                TextFormField(
                  controller: _companyController,
                  validator: required,
                  decoration: InputDecoration(labelText: l10n.experienceCompanyLabel),
                ),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: '${l10n.experienceDescriptionLabel} ${l10n.optionalSuffix}',
                  ),
                ),
                Row(
                  spacing: 12,
                  children: [
                    Expanded(
                      child: _DateField(
                        label: l10n.experienceStartLabel,
                        value: _start,
                        onTap: () async {
                          final d = await _pick(_start);
                          if (d != null) setState(() => _start = d);
                        },
                      ),
                    ),
                    Expanded(
                      child: _DateField(
                        label: l10n.experienceEndLabel,
                        value: _current ? null : _end,
                        placeholder: _current ? l10n.experiencePresent : null,
                        onTap: _current
                            ? null
                            : () async {
                                final d = await _pick(_end ?? _start);
                                if (d != null) setState(() => _end = d);
                              },
                      ),
                    ),
                  ],
                ),
                CheckboxListTile(
                  value: _current,
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(l10n.experienceCurrentJob, style: const TextStyle(fontSize: 13)),
                  onChanged: (v) => setState(() => _current = v!),
                ),
                if (_dateError != null)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _dateError!,
                      style: TextStyle(fontSize: 12, color: context.colors.danger),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.dialogCancel),
        ),
        ElevatedButton(
          onPressed: () => _save(l10n),
          child: Text(l10n.dialogAdd),
        ),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final String? placeholder;
  final VoidCallback? onTap;

  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_today_outlined, size: 16),
          enabled: onTap != null,
        ),
        child: Text(value == null ? (placeholder ?? '') : formatMonthYear(value!)),
      ),
    );
  }
}
