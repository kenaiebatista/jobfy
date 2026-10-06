import 'package:jobfy/core/session/user_session_controller.dart';
import 'package:jobfy/core/settings/settings_controller.dart';
import 'package:jobfy/core/theme/app_breakpoints.dart';
import 'package:jobfy/core/theme/build_context_x.dart';
import 'package:jobfy/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:jobfy/features/settings/domain/entities/user_preferences_entity.dart';
import 'package:jobfy/features/settings/domain/usecases/get_user_preferences_usecase.dart';
import 'package:jobfy/features/settings/domain/usecases/save_user_preferences_usecase.dart';
import 'package:jobfy/features/settings/presentation/controllers/account_settings_controller.dart';
import 'package:jobfy/features/user/data/repositories/user_repository_impl.dart';
import 'package:jobfy/features/user/domain/entities/user_profile_entity.dart';
import 'package:jobfy/features/user/domain/repositories/user_repository.dart';
import 'package:jobfy/features/user/domain/usecases/change_password_usecase.dart';
import 'package:jobfy/features/user/domain/usecases/delete_account_usecase.dart';
import 'package:jobfy/features/user/domain/usecases/update_user_profile_usecase.dart';
import 'package:jobfy/features/user/presentation/widgets/profile_sidebar.dart';
import 'package:jobfy/l10n/app_localizations.dart';
import 'package:jobfy/shared/widgets/theme_toggle_button.dart';
import 'package:jobfy/shared/widgets/user_shell.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

/// Settings screen. Theme and language go to the app-wide
/// [SettingsController]; the account card, password and account deletion
/// go to the database through the user repository; notification, privacy
/// and job preference toggles are kept on the device.
class SettingsPage extends StatefulWidget {
  /// Where account changes are saved. Defaults to [UserRepositoryImpl]
  /// (MySQL/fake/remote per AppConfig); tests pass their own.
  final UserRepository? userRepository;

  const SettingsPage({super.key, this.userRepository});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final AccountSettingsController _controller;

  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  /// Id of the profile the form fields were filled from, so they are filled
  /// once per user and not overwritten while the user is typing.
  String? _filledFromProfileId;

  @override
  void initState() {
    super.initState();
    final userRepository = widget.userRepository ?? UserRepositoryImpl();
    final settingsRepository = SettingsRepositoryImpl();
    _controller = AccountSettingsController(
      GetUserPreferencesUsecase(settingsRepository),
      SaveUserPreferencesUsecase(settingsRepository),
      UpdateUserProfileUsecase(userRepository),
      ChangePasswordUsecase(userRepository),
      DeleteAccountUsecase(userRepository),
    );
    _controller.loadPreferences();
    context.read<UserSessionController>().ensureLoaded();
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _fillForm(UserProfileEntity profile) {
    if (_filledFromProfileId == profile.id) return;
    _filledFromProfileId = profile.id;
    _nameCtrl.text = profile.name;
    _emailCtrl.text = profile.email;
    _phoneCtrl.text = profile.phone ?? '';
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _saveProfile(UserProfileEntity profile) async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context)!;
    final session = context.read<UserSessionController>();

    final result = await _controller.saveProfile(
      profile,
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
    );
    if (!mounted) return;

    switch (result) {
      case SaveProfileResult.saved:
        _showSnack(l10n.settingsSaved);
        // Refresh the sidebar and dashboard with the new name/email.
        session.reload();
      case SaveProfileResult.emailInUse:
        _showSnack(l10n.authErrorEmailInUse);
      case SaveProfileResult.failed:
        _showSnack(l10n.settingsSaveError);
    }
  }

  Future<void> _changePassword(String userId) async {
    final changed = await showDialog<bool>(
      context: context,
      builder: (_) => _ChangePasswordDialog(
        controller: _controller,
        userId: userId,
      ),
    );
    if (changed == true && mounted) {
      _showSnack(AppLocalizations.of(context)!.settingsPasswordChanged);
    }
  }

  Future<void> _deleteAccount(String userId) async {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.settingsDeleteAccount),
        content: Text(l10n.settingsDeleteAccountConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.dialogCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: colors.danger),
            child: Text(l10n.settingsDelete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final session = context.read<UserSessionController>();
    final deleted = await _controller.deleteAccount(userId);
    if (!mounted) return;

    if (deleted) {
      _showSnack(l10n.settingsAccountDeleted);
      context.go('/');
      session.clear();
    } else {
      _showSnack(l10n.settingsDeleteError);
    }
  }

  void _logout() {
    final session = context.read<UserSessionController>();
    context.go('/');
    session.clear();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = context.watch<SettingsController>();
    final session = context.watch<UserSessionController>();

    return Scaffold(
      drawer: UserShell.drawer(
        context,
        profile: session.profile,
        current: SidebarSection.settings,
      ),
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: l10n.settingsBack,
          onPressed: () => context.canPop() ? context.pop() : context.go('/user'),
        ),
        actions: const [
          ThemeToggleButton(color: Colors.white),
          MenuButton(color: Colors.white),
        ],
      ),
      body: UserShell(
        profile: session.profile,
        isError: session.status == UserSessionStatus.error,
        current: SidebarSection.settings,
        builder: (context, profile) {
          _fillForm(profile);

          return ListenableBuilder(
            listenable: _controller,
            builder: (context, _) => Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(context.pagePadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 24,
                    children: [
                      Text(
                        l10n.settingsSubtitle,
                        style: TextStyle(fontSize: 14, color: context.colors.textMuted),
                      ),
                      _SettingsSection(
                        title: l10n.settingsAccountTitle,
                        description: l10n.settingsAccountDescription,
                        child: _AccountForm(
                          formKey: _formKey,
                          nameCtrl: _nameCtrl,
                          emailCtrl: _emailCtrl,
                          phoneCtrl: _phoneCtrl,
                          isSaving: _controller.isSavingProfile,
                          onSave: () => _saveProfile(profile),
                        ),
                      ),
                      _SettingsSection(
                        title: l10n.settingsAppearance,
                        description: l10n.settingsAppearanceDescription,
                        child: _ThemeModeSelector(
                          l10n: l10n,
                          value: settings.themeMode,
                          onChanged: settings.setThemeMode,
                        ),
                      ),
                      _SettingsSection(
                        title: l10n.settingsLanguage,
                        description: l10n.settingsLanguageDescription,
                        child: _LanguageSelector(
                          l10n: l10n,
                          value: settings.locale,
                          onChanged: settings.setLocale,
                        ),
                      ),
                      _SettingsSection(
                        title: l10n.settingsNotifications,
                        description: l10n.settingsNotificationsDescription,
                        child: _NotificationsToggles(controller: _controller),
                      ),
                      _SettingsSection(
                        title: l10n.settingsPrivacy,
                        description: l10n.settingsPrivacyDescription,
                        child: _PrivacyToggles(
                          controller: _controller,
                          onChangePassword: () => _changePassword(profile.id),
                        ),
                      ),
                      _SettingsSection(
                        title: l10n.settingsJobPreferences,
                        description: l10n.settingsJobPreferencesDescription,
                        child: _JobTypeChips(controller: _controller),
                      ),
                      _DangerZone(
                        isDeleting: _controller.isDeleting,
                        onLogout: _logout,
                        onDelete: () => _deleteAccount(profile.id),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final String description;
  final Widget child;

  const _SettingsSection({
    required this.title,
    required this.description,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: colors.textPrimary,
            ),
          ),
          Text(
            description,
            style: TextStyle(fontSize: 13, color: colors.textMuted),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

class _AccountForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController phoneCtrl;
  final bool isSaving;
  final VoidCallback onSave;

  const _AccountForm({
    required this.formKey,
    required this.nameCtrl,
    required this.emailCtrl,
    required this.phoneCtrl,
    required this.isSaving,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: [
          TextFormField(
            controller: nameCtrl,
            maxLength: 120, // users.name VARCHAR(120)
            decoration: InputDecoration(
              counterText: '',
              labelText: l10n.fullNameLabel,
              prefixIcon: const Icon(Icons.badge_outlined, size: 18),
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? l10n.settingsNameRequired : null,
          ),
          TextFormField(
            controller: emailCtrl,
            maxLength: 150, // accounts.email VARCHAR(150)
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              counterText: '',
              labelText: l10n.emailLabel,
              prefixIcon: const Icon(Icons.email_outlined, size: 18),
            ),
            validator: (v) => _emailRegex.hasMatch(v?.trim() ?? '')
                ? null
                : l10n.settingsEmailInvalid,
          ),
          TextFormField(
            controller: phoneCtrl,
            maxLength: 20, // users.phone VARCHAR(20)
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              counterText: '',
              labelText: '${l10n.phoneLabel} ${l10n.optionalSuffix}',
              hintText: l10n.phoneHint,
              prefixIcon: const Icon(Icons.phone_outlined, size: 18),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: isSaving ? null : onSave,
              icon: isSaving
                  ? SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colors.onAccent,
                      ),
                    )
                  : const Icon(Icons.check, size: 16),
              label: Text(isSaving ? l10n.settingsSaving : l10n.settingsSaveChanges),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.accent,
                foregroundColor: colors.onAccent,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeModeSelector extends StatelessWidget {
  final AppLocalizations l10n;
  final ThemeMode value;
  final ValueChanged<ThemeMode> onChanged;

  const _ThemeModeSelector({
    required this.l10n,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final options = <(ThemeMode, IconData, String)>[
      (ThemeMode.light, Icons.light_mode_outlined, l10n.settingsThemeLight),
      (ThemeMode.dark, Icons.dark_mode_outlined, l10n.settingsThemeDark),
      (ThemeMode.system, Icons.brightness_auto_outlined, l10n.settingsThemeSystem),
    ];

    return Row(
      spacing: 12,
      children: options
          .map((o) => Expanded(
                child: _OptionTile(
                  icon: o.$2,
                  label: o.$3,
                  selected: value == o.$1,
                  onTap: () => onChanged(o.$1),
                ),
              ))
          .toList(),
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  final AppLocalizations l10n;
  final Locale? value;
  final ValueChanged<Locale?> onChanged;

  const _LanguageSelector({
    required this.l10n,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final options = <(Locale?, String)>[
      (null, l10n.settingsLanguageSystem),
      (const Locale('en'), 'English'),
      (const Locale('pt', 'BR'), 'Português (Brasil)'),
      (const Locale('es'), 'Español'),
    ];

    return Column(
      spacing: 8,
      children: options
          .map((o) => _RadioRow(
                label: o.$2,
                selected: value == o.$1,
                onTap: () => onChanged(o.$1),
              ))
          .toList(),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: selected ? colors.accent.withValues(alpha: 0.1) : null,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? colors.accent : colors.surfaceBorder,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          spacing: 6,
          children: [
            Icon(icon, color: selected ? colors.accent : colors.textMuted),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                color: selected ? colors.accent : colors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RadioRow extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RadioRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? colors.accent.withValues(alpha: 0.08) : null,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? colors.accent : colors.surfaceBorder,
          ),
        ),
        child: Row(
          spacing: 10,
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 18,
              color: selected ? colors.accent : colors.textMuted,
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: colors.textPrimary,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String title;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.title,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        spacing: 12,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: colors.textPrimary,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: colors.textMuted),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: colors.accent,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _NotificationsToggles extends StatelessWidget {
  final AccountSettingsController controller;

  const _NotificationsToggles({required this.controller});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final prefs = controller.preferences;
    final divider = Divider(height: 1, color: context.colors.surfaceBorder);

    return Column(
      children: [
        _ToggleRow(
          title: l10n.settingsNotifNewJobs,
          description: l10n.settingsNotifNewJobsDescription,
          value: prefs.newJobAlerts,
          onChanged: controller.setNewJobAlerts,
        ),
        divider,
        _ToggleRow(
          title: l10n.settingsNotifMessages,
          description: l10n.settingsNotifMessagesDescription,
          value: prefs.messageAlerts,
          onChanged: controller.setMessageAlerts,
        ),
        divider,
        _ToggleRow(
          title: l10n.settingsNotifWeekly,
          description: l10n.settingsNotifWeeklyDescription,
          value: prefs.weeklyEmailSummary,
          onChanged: controller.setWeeklyEmailSummary,
        ),
        divider,
        _ToggleRow(
          title: l10n.settingsNotifPush,
          description: l10n.settingsNotifPushDescription,
          value: prefs.pushNotifications,
          onChanged: controller.setPushNotifications,
        ),
      ],
    );
  }
}

class _PrivacyToggles extends StatelessWidget {
  final AccountSettingsController controller;
  final VoidCallback onChangePassword;

  const _PrivacyToggles({
    required this.controller,
    required this.onChangePassword,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final prefs = controller.preferences;

    return Column(
      children: [
        _ToggleRow(
          title: l10n.settingsProfileVisible,
          description: l10n.settingsProfileVisibleDescription,
          value: prefs.profileVisibleToCompanies,
          onChanged: controller.setProfileVisibleToCompanies,
        ),
        Divider(height: 1, color: colors.surfaceBorder),
        _ToggleRow(
          title: l10n.settingsShowEmail,
          description: l10n.settingsShowEmailDescription,
          value: prefs.showEmailOnProfile,
          onChanged: controller.setShowEmailOnProfile,
        ),
        Divider(height: 1, color: colors.surfaceBorder),
        InkWell(
          onTap: onChangePassword,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              spacing: 12,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: colors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.lock_outline, size: 18, color: colors.accent),
                ),
                Expanded(
                  child: Text(
                    l10n.settingsChangePassword,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: colors.textPrimary,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right, color: colors.textMuted, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _JobTypeChips extends StatelessWidget {
  final AccountSettingsController controller;

  const _JobTypeChips({required this.controller});

  String _label(AppLocalizations l10n, JobPreferenceType type) => switch (type) {
        JobPreferenceType.remote => l10n.settingsJobTypeRemote,
        JobPreferenceType.hybrid => l10n.settingsJobTypeHybrid,
        JobPreferenceType.onsite => l10n.settingsJobTypeOnsite,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final type in JobPreferenceType.values)
          FilterChip(
            label: Text(_label(l10n, type)),
            selected: controller.preferences.jobTypes.contains(type),
            onSelected: (_) => controller.toggleJobType(type),
            selectedColor: colors.accent.withValues(alpha: 0.15),
            checkmarkColor: colors.accent,
          ),
      ],
    );
  }
}

class _DangerZone extends StatelessWidget {
  final bool isDeleting;
  final VoidCallback onLogout;
  final VoidCallback onDelete;

  const _DangerZone({
    required this.isDeleting,
    required this.onLogout,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.danger.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          Row(
            spacing: 10,
            children: [
              Icon(Icons.warning_amber_rounded, color: colors.danger, size: 20),
              Text(
                l10n.settingsDangerZone,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              OutlinedButton.icon(
                onPressed: onLogout,
                icon: const Icon(Icons.logout, size: 16),
                label: Text(l10n.settingsLogout),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.textPrimary,
                  side: BorderSide(color: colors.surfaceBorder),
                ),
              ),
              OutlinedButton.icon(
                onPressed: isDeleting ? null : onDelete,
                icon: isDeleting
                    ? SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colors.danger,
                        ),
                      )
                    : const Icon(Icons.delete_outline, size: 16),
                label: Text(l10n.settingsDeleteAccount),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.danger,
                  side: BorderSide(color: colors.danger.withValues(alpha: 0.5)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChangePasswordDialog extends StatefulWidget {
  final AccountSettingsController controller;
  final String userId;

  const _ChangePasswordDialog({required this.controller, required this.userId});

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  /// Error from the server (wrong current password / failure), shown in
  /// the dialog so the user can fix it without reopening it.
  String? _error;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context)!;

    final result = await widget.controller.changePassword(
      userId: widget.userId,
      currentPassword: _currentCtrl.text,
      newPassword: _newCtrl.text,
    );
    if (!mounted) return;

    switch (result) {
      case ChangePasswordResult.changed:
        Navigator.pop(context, true);
      case ChangePasswordResult.wrongPassword:
        setState(() => _error = l10n.settingsWrongPassword);
      case ChangePasswordResult.failed:
        setState(() => _error = l10n.settingsPasswordError);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final saving = widget.controller.isChangingPassword;

        return AlertDialog(
          title: Text(l10n.settingsChangePassword),
          content: SizedBox(
            width: 400,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 16,
                children: [
                  TextFormField(
                    controller: _currentCtrl,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: l10n.settingsCurrentPassword,
                      prefixIcon: const Icon(Icons.lock_outline, size: 18),
                    ),
                    validator: (v) => (v == null || v.isEmpty)
                        ? l10n.settingsPasswordRequired
                        : null,
                  ),
                  TextFormField(
                    controller: _newCtrl,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: l10n.settingsNewPassword,
                      prefixIcon: const Icon(Icons.lock_reset, size: 18),
                    ),
                    validator: (v) => (v == null || v.length < 6)
                        ? l10n.settingsPasswordTooShort
                        : null,
                  ),
                  TextFormField(
                    controller: _confirmCtrl,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: l10n.settingsConfirmPassword,
                      prefixIcon: const Icon(Icons.lock_reset, size: 18),
                    ),
                    validator: (v) =>
                        v != _newCtrl.text ? l10n.settingsPasswordsDontMatch : null,
                    onFieldSubmitted: (_) => _submit(),
                  ),
                  if (_error != null)
                    Text(_error!, style: TextStyle(color: colors.danger, fontSize: 13)),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: saving ? null : () => Navigator.pop(context, false),
              child: Text(l10n.dialogCancel),
            ),
            ElevatedButton(
              onPressed: saving ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.accent,
                foregroundColor: colors.onAccent,
                elevation: 0,
              ),
              child: saving
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colors.onAccent,
                      ),
                    )
                  : Text(l10n.settingsSave),
            ),
          ],
        );
      },
    );
  }
}
