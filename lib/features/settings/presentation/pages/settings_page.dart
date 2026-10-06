import 'package:aplicativo_jobfy/core/settings/app_settings_controller.dart';
import 'package:aplicativo_jobfy/core/theme/app_breakpoints.dart';
import 'package:aplicativo_jobfy/core/theme/app_colors.dart';
import 'package:aplicativo_jobfy/core/theme/app_palette.dart';
import 'package:aplicativo_jobfy/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:aplicativo_jobfy/features/settings/domain/entities/user_preferences_entity.dart';
import 'package:aplicativo_jobfy/features/settings/domain/usecases/get_user_preferences_usecase.dart';
import 'package:aplicativo_jobfy/features/settings/domain/usecases/save_user_preferences_usecase.dart';
import 'package:aplicativo_jobfy/features/settings/presentation/controllers/settings_controller.dart';
import 'package:aplicativo_jobfy/features/user/data/repositories/user_repository_impl.dart';
import 'package:aplicativo_jobfy/features/user/domain/entities/user_profile_entity.dart';
import 'package:aplicativo_jobfy/features/user/domain/usecases/get_user_profile_usecase.dart';
import 'package:aplicativo_jobfy/features/user/presentation/widgets/profile_sidebar.dart';
import 'package:aplicativo_jobfy/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Settings screen. Follows the same shell used by the dashboard
/// (UserAreaPage): a dark ProfileSidebar for navigation and a scrollable
/// content area made of rounded cards.
///
/// Below [AppBreakpoints.mobile] the fixed sidebar becomes a Drawer opened
/// from a menu button in the top bar, and every multi-column section
/// collapses into a single column, so the screen works on a phone as well
/// as on a wide desktop/web viewport.
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final SettingsController _controller;

  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _localizacaoCtrl = TextEditingController();

  bool _fieldsInitialized = false;

  @override
  void initState() {
    super.initState();
    final repository = UserRepositoryImpl();
    final settingsRepository = SettingsRepositoryImpl();
    _controller = SettingsController(
      GetUserProfileUsecase(repository),
      repository,
      GetUserPreferencesUsecase(settingsRepository),
      SaveUserPreferencesUsecase(settingsRepository),
    );
    _controller.loadProfile('usr_001');
  }

  @override
  void dispose() {
    _controller.dispose();
    _nomeCtrl.dispose();
    _emailCtrl.dispose();
    _localizacaoCtrl.dispose();
    super.dispose();
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _salvarPerfil() async {
    if (!_formKey.currentState!.validate()) return;

    await _controller.salvarPerfil(
      nome: _nomeCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      localizacao: _localizacaoCtrl.text.trim(),
    );
    if (!mounted) return;
    _showSnack(AppLocalizations.of(context).settingsSaved);
  }

  Future<void> _alterarSenha() async {
    final alterou = await showDialog<bool>(
      context: context,
      builder: (_) => _ChangePasswordDialog(controller: _controller),
    );
    if (alterou == true && mounted) {
      _showSnack(AppLocalizations.of(context).passwordChanged);
    }
  }

  Future<void> _confirmarExclusao() async {
    final l10n = AppLocalizations.of(context);
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteAccount),
        content: Text(l10n.deleteAccountConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmar == true && mounted) {
      _showSnack(l10n.accountDeleted);
      context.go('/');
    }
  }

  void _handleNav(BuildContext context, int index, bool isMobile) {
    if (isMobile) {
      Navigator.pop(context);
    }
    if (index == 0) {
      context.go('/user');
    } else if (index != 4) {
      // Vagas, Currículo e Mensagens ainda não têm tela própria.
      // index 4 (Configurações) já é a página atual.
      _showSnack(AppLocalizations.of(context).comingSoon);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        if (_controller.isLoading) {
          return Scaffold(
            backgroundColor: palette.background,
            body: const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            ),
          );
        }

        final profile = _controller.profile;
        if (profile == null) {
          return Scaffold(
            backgroundColor: palette.background,
            body: Center(child: Text(l10n.errorLoadingProfile)),
          );
        }

        if (!_fieldsInitialized) {
          _nomeCtrl.text = profile.nome;
          _emailCtrl.text = profile.email;
          _localizacaoCtrl.text = profile.localizacao;
          _fieldsInitialized = true;
        }

        final isMobile = MediaQuery.sizeOf(context).width < AppBreakpoints.mobile;

        final sidebar = ProfileSidebar(
          profile: profile,
          selectedIndex: 4,
          onNavTap: (i) => _handleNav(context, i, isMobile),
        );

        return Scaffold(
          backgroundColor: palette.background,
          drawer: isMobile ? Drawer(child: sidebar) : null,
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isMobile) sidebar,
              Expanded(
                child: _SettingsContent(
                  controller: _controller,
                  profile: profile,
                  isMobile: isMobile,
                  formKey: _formKey,
                  nomeCtrl: _nomeCtrl,
                  emailCtrl: _emailCtrl,
                  localizacaoCtrl: _localizacaoCtrl,
                  onSalvarPerfil: _salvarPerfil,
                  onAlterarSenha: _alterarSenha,
                  onExcluirConta: _confirmarExclusao,
                  onEmBreve: () => _showSnack(l10n.comingSoon),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SettingsContent extends StatelessWidget {
  final SettingsController controller;
  final UserProfileEntity profile;
  final bool isMobile;
  final GlobalKey<FormState> formKey;
  final TextEditingController nomeCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController localizacaoCtrl;
  final VoidCallback onSalvarPerfil;
  final VoidCallback onAlterarSenha;
  final VoidCallback onExcluirConta;
  final VoidCallback onEmBreve;

  const _SettingsContent({
    required this.controller,
    required this.profile,
    required this.isMobile,
    required this.formKey,
    required this.nomeCtrl,
    required this.emailCtrl,
    required this.localizacaoCtrl,
    required this.onSalvarPerfil,
    required this.onAlterarSenha,
    required this.onExcluirConta,
    required this.onEmBreve,
  });

  @override
  Widget build(BuildContext context) {
    final pad = isMobile ? 16.0 : 28.0;

    return Column(
      children: [
        _SettingsTopBar(
          profile: profile,
          isMobile: isMobile,
          onEmBreve: onEmBreve,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(pad, 0, pad, pad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: pad),
                const _PageHeading(),
                SizedBox(height: pad),
                _ProfileSummaryCard(profile: profile, isMobile: isMobile),
                SizedBox(height: pad),
                _ContaCard(
                  formKey: formKey,
                  nomeCtrl: nomeCtrl,
                  emailCtrl: emailCtrl,
                  localizacaoCtrl: localizacaoCtrl,
                  isSaving: controller.isSavingProfile,
                  onSalvar: onSalvarPerfil,
                ),
                SizedBox(height: pad),
                _ResponsiveGrid(
                  isMobile: isMobile,
                  spacing: pad,
                  children: [
                    ListenableBuilder(
                      listenable: appSettings,
                      builder: (_, _) => const _AparenciaCard(),
                    ),
                    ListenableBuilder(
                      listenable: appSettings,
                      builder: (_, _) => const _IdiomaCard(),
                    ),
                  ],
                ),
                SizedBox(height: pad),
                _ResponsiveGrid(
                  isMobile: isMobile,
                  spacing: pad,
                  children: [
                    _NotificacoesCard(controller: controller),
                    _PrivacidadeCard(
                      controller: controller,
                      onAlterarSenha: onAlterarSenha,
                    ),
                  ],
                ),
                SizedBox(height: pad),
                _PreferenciasVagaCard(controller: controller),
                SizedBox(height: pad),
                _DangerZoneCard(onExcluirConta: onExcluirConta),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingsTopBar extends StatelessWidget {
  final UserProfileEntity profile;
  final bool isMobile;
  final VoidCallback onEmBreve;

  const _SettingsTopBar({
    required this.profile,
    required this.isMobile,
    required this.onEmBreve,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 28,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(bottom: BorderSide(color: palette.border)),
      ),
      child: Row(
        children: [
          if (isMobile)
            IconButton(
              icon: const Icon(Icons.menu),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => Scaffold.of(context).openDrawer(),
            )
          else
            const Icon(Icons.lightbulb_circle, size: 28),
          const SizedBox(width: 10),
          const Text(
            'Jobfy',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const Spacer(),
          if (!isMobile) ...[
            InkWell(
              onTap: onEmBreve,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: palette.background,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: palette.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, size: 16, color: AppColors.textMuted),
                    const SizedBox(width: 6),
                    Text(
                      l10n.searchJobsHint,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              tooltip: l10n.notificationsTooltip,
              onPressed: onEmBreve,
              style: IconButton.styleFrom(
                backgroundColor: palette.background,
              ),
            ),
            const SizedBox(width: 8),
          ],
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.accent,
            child: Text(
              profile.nome.isNotEmpty ? profile.nome[0].toUpperCase() : '?',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PageHeading extends StatelessWidget {
  const _PageHeading();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.settingsTitle,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.settingsSubtitle,
          style: const TextStyle(fontSize: 14, color: AppColors.textMuted),
        ),
      ],
    );
  }
}

/// Rounded card container shared by every block of the page.
BoxDecoration _cardDecoration(AppPalette palette, {Color? borderColor}) {
  return BoxDecoration(
    color: palette.surface,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: borderColor ?? palette.border),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.03),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  );
}

class _ProfileSummaryCard extends StatelessWidget {
  final UserProfileEntity profile;
  final bool isMobile;

  const _ProfileSummaryCard({required this.profile, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final initials = profile.nome.trim().isNotEmpty
        ? profile.nome.trim().split(RegExp(r'\s+')).take(2).map((w) => w[0]).join()
        : '?';

    final avatar = Container(
      width: 72,
      height: 72,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: [AppColors.accent, AppColors.accent2]),
      ),
      alignment: Alignment.center,
      child: Text(
        initials.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    final info = Column(
      crossAxisAlignment:
          isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          profile.nome,
          textAlign: isMobile ? TextAlign.center : TextAlign.start,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 4),
        Text(
          profile.cargo,
          textAlign: isMobile ? TextAlign.center : TextAlign.start,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
        ),
        const SizedBox(height: 4),
        Text(
          profile.email,
          textAlign: isMobile ? TextAlign.center : TextAlign.start,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
        ),
      ],
    );

    final badges = Row(
      mainAxisAlignment:
          isMobile ? MainAxisAlignment.center : MainAxisAlignment.end,
      children: [
        _StatBadge(
          label: l10n.profileComplete,
          value: '${profile.perfilCompleto}%',
        ),
        const SizedBox(width: 12),
        _StatBadge(label: l10n.averageMatch, value: '${profile.matchScore}%'),
      ],
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(context.palette),
      child: isMobile
          ? Column(
              children: [
                avatar,
                const SizedBox(height: 12),
                info,
                const SizedBox(height: 16),
                badges,
              ],
            )
          : Row(
              children: [
                avatar,
                const SizedBox(width: 16),
                Expanded(child: info),
                badges,
              ],
            ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String label;
  final String value;

  const _StatBadge({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

/// Shared card shell (icon + title + optional subtitle header, then body)
/// used by every settings section so the whole page reads as one system.
class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(context.palette),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.accent, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

class _ContaCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nomeCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController localizacaoCtrl;
  final bool isSaving;
  final VoidCallback onSalvar;

  const _ContaCard({
    required this.formKey,
    required this.nomeCtrl,
    required this.emailCtrl,
    required this.localizacaoCtrl,
    required this.isSaving,
    required this.onSalvar,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return _SectionCard(
      icon: Icons.person_outline,
      title: l10n.accountInfoTitle,
      subtitle: l10n.accountInfoSubtitle,
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: nomeCtrl,
              decoration: InputDecoration(
                labelText: l10n.fullNameLabel,
                prefixIcon: const Icon(Icons.badge_outlined, size: 18),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? l10n.nameRequired : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: l10n.emailLabel,
                prefixIcon: const Icon(Icons.email_outlined, size: 18),
              ),
              validator: (v) => _emailRegex.hasMatch(v?.trim() ?? '')
                  ? null
                  : l10n.emailInvalid,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: localizacaoCtrl,
              decoration: InputDecoration(
                labelText: l10n.locationLabel,
                prefixIcon: const Icon(Icons.location_on_outlined, size: 18),
              ),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: isSaving ? null : onSalvar,
                icon: isSaving
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check, size: 16),
                label: Text(isSaving ? l10n.saving : l10n.saveChanges),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
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
      ),
    );
  }
}

/// Lays its children out two-per-row on wide screens and stacked full width
/// on mobile.
class _ResponsiveGrid extends StatelessWidget {
  final bool isMobile;
  final double spacing;
  final List<Widget> children;

  const _ResponsiveGrid({
    required this.isMobile,
    required this.spacing,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1) SizedBox(height: spacing),
          ],
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - spacing) / 2;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final child in children) SizedBox(width: itemWidth, child: child),
          ],
        );
      },
    );
  }
}

class _AparenciaCard extends StatelessWidget {
  const _AparenciaCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return _SectionCard(
      icon: Icons.palette_outlined,
      title: l10n.appearanceTitle,
      subtitle: l10n.appearanceSubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.themeLabel,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<ThemeMode>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: ThemeMode.light,
                  icon: const Icon(Icons.light_mode_outlined, size: 18),
                  label: Text(l10n.themeLight),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  icon: const Icon(Icons.dark_mode_outlined, size: 18),
                  label: Text(l10n.themeDark),
                ),
                ButtonSegment(
                  value: ThemeMode.system,
                  icon: const Icon(Icons.settings_suggest_outlined, size: 18),
                  label: Text(l10n.themeSystem),
                ),
              ],
              selected: {appSettings.themeMode},
              onSelectionChanged: (s) => appSettings.setThemeMode(s.first),
            ),
          ),
        ],
      ),
    );
  }
}

class _IdiomaCard extends StatelessWidget {
  const _IdiomaCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final atual = appSettings.locale.languageCode;
    final idiomas = AppSettingsController.supportedLanguages;

    return _SectionCard(
      icon: Icons.language,
      title: l10n.languageTitle,
      subtitle: l10n.languageSubtitle,
      child: Column(
        children: [
          for (var i = 0; i < idiomas.length; i++)
            _LanguageOption(
              code: idiomas[i].locale.languageCode,
              name: idiomas[i].name,
              selected: idiomas[i].locale.languageCode == atual,
              onTap: () => appSettings.setLocale(idiomas[i].locale),
              showDivider: i != idiomas.length - 1,
            ),
        ],
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String code;
  final String name;
  final bool selected;
  final VoidCallback onTap;
  final bool showDivider;

  const _LanguageOption({
    required this.code,
    required this.name,
    required this.selected,
    required this.onTap,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.accent
                        : AppColors.accent.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    code.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: selected ? Colors.white : AppColors.accent,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
                Icon(
                  selected ? Icons.check_circle : Icons.circle_outlined,
                  size: 20,
                  color: selected ? AppColors.accent : palette.border,
                ),
              ],
            ),
          ),
        ),
        if (showDivider) Divider(height: 1, color: palette.border),
      ],
    );
  }
}

class _NotificacoesCard extends StatelessWidget {
  final SettingsController controller;

  const _NotificacoesCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final prefs = controller.preferences;

    return _SectionCard(
      icon: Icons.notifications_outlined,
      title: l10n.notificationsTitle,
      subtitle: l10n.notificationsSubtitle,
      child: Column(
        children: [
          _ToggleRow(
            title: l10n.notifNewJobsTitle,
            subtitle: l10n.notifNewJobsSubtitle,
            value: prefs.notifNovasVagas,
            onChanged: controller.setNotifNovasVagas,
          ),
          _ToggleRow(
            title: l10n.notifMessagesTitle,
            subtitle: l10n.notifMessagesSubtitle,
            value: prefs.notifMensagens,
            onChanged: controller.setNotifMensagens,
          ),
          _ToggleRow(
            title: l10n.notifWeeklyTitle,
            subtitle: l10n.notifWeeklySubtitle,
            value: prefs.notifEmailSemanal,
            onChanged: controller.setNotifEmailSemanal,
          ),
          _ToggleRow(
            title: l10n.notifPushTitle,
            subtitle: l10n.notifPushSubtitle,
            value: prefs.notifPush,
            onChanged: controller.setNotifPush,
            showDivider: false,
          ),
        ],
      ),
    );
  }
}

class _PrivacidadeCard extends StatelessWidget {
  final SettingsController controller;
  final VoidCallback onAlterarSenha;

  const _PrivacidadeCard({
    required this.controller,
    required this.onAlterarSenha,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final prefs = controller.preferences;

    return _SectionCard(
      icon: Icons.shield_outlined,
      title: l10n.privacyTitle,
      subtitle: l10n.privacySubtitle,
      child: Column(
        children: [
          _ToggleRow(
            title: l10n.privacyVisibleTitle,
            subtitle: l10n.privacyVisibleSubtitle,
            value: prefs.perfilVisivelParaEmpresas,
            onChanged: controller.setPerfilVisivelParaEmpresas,
          ),
          _ToggleRow(
            title: l10n.privacyShowEmailTitle,
            subtitle: l10n.privacyShowEmailSubtitle,
            value: prefs.mostrarEmailNoPerfil,
            onChanged: controller.setMostrarEmailNoPerfil,
            showDivider: false,
          ),
          const SizedBox(height: 4),
          _ActionRow(
            icon: Icons.lock_outline,
            label: l10n.changePassword,
            onTap: onAlterarSenha,
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionRow({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: AppColors.accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool showDivider;

  const _ToggleRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Switch(
                value: value,
                activeThumbColor: AppColors.accent,
                onChanged: onChanged,
              ),
            ],
          ),
        ),
        if (showDivider) Divider(height: 1, color: context.palette.border),
      ],
    );
  }
}

class _PreferenciasVagaCard extends StatelessWidget {
  final SettingsController controller;

  const _PreferenciasVagaCard({required this.controller});

  String _label(AppLocalizations l10n, TipoVaga tipo) => switch (tipo) {
        TipoVaga.remoto => l10n.jobTypeRemote,
        TipoVaga.hibrido => l10n.jobTypeHybrid,
        TipoVaga.presencial => l10n.jobTypeOnsite,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return _SectionCard(
      icon: Icons.work_outline,
      title: l10n.jobPrefsTitle,
      subtitle: l10n.jobPrefsSubtitle,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: TipoVaga.values
            .map(
              (tipo) => _SelectableChip(
                label: _label(l10n, tipo),
                selected: controller.preferences.tiposVaga.contains(tipo),
                onTap: () => controller.toggleTipoVaga(tipo),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _SelectableChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SelectableChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : AppColors.accent.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.accent.withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              const Icon(Icons.check, size: 14, color: Colors.white),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.accent,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChangePasswordDialog extends StatefulWidget {
  final SettingsController controller;

  const _ChangePasswordDialog({required this.controller});

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _atualCtrl = TextEditingController();
  final _novaCtrl = TextEditingController();
  final _confirmarCtrl = TextEditingController();

  @override
  void dispose() {
    _atualCtrl.dispose();
    _novaCtrl.dispose();
    _confirmarCtrl.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    await widget.controller.alterarSenha(
      senhaAtual: _atualCtrl.text,
      novaSenha: _novaCtrl.text,
    );
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final salvando = widget.controller.isChangingPassword;

        return AlertDialog(
          title: Text(l10n.changePassword),
          content: SizedBox(
            width: 400,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _atualCtrl,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: l10n.currentPasswordLabel,
                      prefixIcon: const Icon(Icons.lock_outline, size: 18),
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? l10n.passwordRequired : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _novaCtrl,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: l10n.newPasswordLabel,
                      prefixIcon: const Icon(Icons.lock_reset, size: 18),
                    ),
                    validator: (v) =>
                        (v == null || v.length < 6) ? l10n.passwordTooShort : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmarCtrl,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: l10n.confirmPasswordLabel,
                      prefixIcon: const Icon(Icons.lock_reset, size: 18),
                    ),
                    validator: (v) =>
                        v != _novaCtrl.text ? l10n.passwordsDontMatch : null,
                    onFieldSubmitted: (_) => _salvar(),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: salvando ? null : () => Navigator.pop(context, false),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: salvando ? null : _salvar,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: salvando
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(l10n.save),
            ),
          ],
        );
      },
    );
  }
}

class _DangerZoneCard extends StatelessWidget {
  final VoidCallback onExcluirConta;

  const _DangerZoneCard({required this.onExcluirConta});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(
        palette,
        borderColor: AppColors.danger.withValues(alpha: 0.25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 20),
              const SizedBox(width: 10),
              Text(
                l10n.dangerZoneTitle,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              OutlinedButton.icon(
                onPressed: () => context.go('/'),
                icon: const Icon(Icons.logout, size: 16),
                label: Text(l10n.logoutAccount),
                style: OutlinedButton.styleFrom(
                  foregroundColor: palette.textPrimary,
                  side: BorderSide(color: palette.border),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              OutlinedButton.icon(
                onPressed: onExcluirConta,
                icon: const Icon(Icons.delete_outline, size: 16),
                label: Text(l10n.deleteAccount),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  side: BorderSide(color: AppColors.danger.withValues(alpha: 0.4)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
