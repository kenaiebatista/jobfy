import 'package:aplicativo_jobfy/core/theme/app_breakpoints.dart';
import 'package:aplicativo_jobfy/core/theme/app_colors.dart';
import 'package:aplicativo_jobfy/features/settings/presentation/controllers/settings_controller.dart';
import 'package:aplicativo_jobfy/features/user/data/repositories/user_repository_impl.dart';
import 'package:aplicativo_jobfy/features/user/domain/entities/user_profile_entity.dart';
import 'package:aplicativo_jobfy/features/user/domain/usecases/get_user_profile_usecase.dart';
import 'package:aplicativo_jobfy/features/user/presentation/widgets/profile_sidebar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Settings screen. Follows the same shell used by the dashboard
/// (UserAreaPage): a dark ProfileSidebar for navigation and a light
/// scrollable content area made of rounded white cards.
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

  final _nomeCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _localizacaoCtrl = TextEditingController();

  bool _fieldsInitialized = false;

  @override
  void initState() {
    super.initState();
    final repository = UserRepositoryImpl();
    _controller = SettingsController(
      GetUserProfileUsecase(repository),
      repository,
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

  Future<void> _salvarPerfil() async {
    await _controller.salvarPerfil(
      nome: _nomeCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      localizacao: _localizacaoCtrl.text.trim(),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Alterações salvas com sucesso.')),
    );
  }

  Future<void> _confirmarExclusao() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir conta'),
        content: const Text(
          'Tem certeza que deseja excluir sua conta? Essa ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmar == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conta marcada para exclusão.')),
      );
    }
  }

  void _handleNav(BuildContext context, int index, bool isMobile) {
    if (isMobile) {
      Navigator.pop(context);
    }
    if (index == 0) {
      context.go('/user');
    }
    // Vagas, Currículo e Mensagens ainda não têm tela própria.
    // index 4 (Configurações) já é a página atual.
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        if (_controller.isLoading) {
          return const Scaffold(
            backgroundColor: AppColors.backgroundLight,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            ),
          );
        }

        final profile = _controller.profile;
        if (profile == null) {
          return const Scaffold(
            backgroundColor: AppColors.backgroundLight,
            body: Center(child: Text('Erro ao carregar perfil.')),
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
          backgroundColor: AppColors.backgroundLight,
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
                  nomeCtrl: _nomeCtrl,
                  emailCtrl: _emailCtrl,
                  localizacaoCtrl: _localizacaoCtrl,
                  onSalvarPerfil: _salvarPerfil,
                  onExcluirConta: _confirmarExclusao,
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
  final TextEditingController nomeCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController localizacaoCtrl;
  final VoidCallback onSalvarPerfil;
  final VoidCallback onExcluirConta;

  const _SettingsContent({
    required this.controller,
    required this.profile,
    required this.isMobile,
    required this.nomeCtrl,
    required this.emailCtrl,
    required this.localizacaoCtrl,
    required this.onSalvarPerfil,
    required this.onExcluirConta,
  });

  @override
  Widget build(BuildContext context) {
    final pad = isMobile ? 16.0 : 28.0;

    return Column(
      children: [
        _SettingsTopBar(profile: profile, isMobile: isMobile),
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
                    _NotificacoesCard(controller: controller),
                    _PrivacidadeCard(controller: controller),
                  ],
                ),
                SizedBox(height: pad),
                _ResponsiveGrid(
                  isMobile: isMobile,
                  spacing: pad,
                  children: [
                    _PreferenciasVagaCard(controller: controller),
                    _AparenciaCard(controller: controller),
                  ],
                ),
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

  const _SettingsTopBar({required this.profile, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 28,
        vertical: 14,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.cardBorder)),
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: const Row(
                children: [
                  Icon(Icons.search, size: 16, color: AppColors.textMuted),
                  SizedBox(width: 6),
                  Text(
                    'Buscar vagas...',
                    style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {},
              style: IconButton.styleFrom(
                backgroundColor: AppColors.backgroundLight,
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
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Configurações',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 6),
        Text(
          'Gerencie sua conta, notificações e preferências.',
          style: TextStyle(fontSize: 14, color: AppColors.textMuted),
        ),
      ],
    );
  }
}

class _ProfileSummaryCard extends StatelessWidget {
  final UserProfileEntity profile;
  final bool isMobile;

  const _ProfileSummaryCard({required this.profile, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final initials = profile.nome.isNotEmpty
        ? profile.nome.trim().split(' ').take(2).map((w) => w[0]).join()
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
        _StatBadge(label: 'Perfil completo', value: '${profile.perfilCompleto}%'),
        const SizedBox(width: 12),
        _StatBadge(label: 'Match médio', value: '${profile.matchScore}%'),
      ],
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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

class _ContaCard extends StatelessWidget {
  final TextEditingController nomeCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController localizacaoCtrl;
  final bool isSaving;
  final VoidCallback onSalvar;

  const _ContaCard({
    required this.nomeCtrl,
    required this.emailCtrl,
    required this.localizacaoCtrl,
    required this.isSaving,
    required this.onSalvar,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      icon: Icons.person_outline,
      title: 'Informações da conta',
      subtitle: 'Seus dados básicos de perfil.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: nomeCtrl,
            decoration: const InputDecoration(
              labelText: 'Nome completo',
              prefixIcon: Icon(Icons.badge_outlined, size: 18),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: emailCtrl,
            decoration: const InputDecoration(
              labelText: 'E-mail',
              prefixIcon: Icon(Icons.email_outlined, size: 18),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: localizacaoCtrl,
            decoration: const InputDecoration(
              labelText: 'Localização',
              prefixIcon: Icon(Icons.location_on_outlined, size: 18),
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
              label: Text(isSaving ? 'Salvando...' : 'Salvar alterações'),
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

class _NotificacoesCard extends StatelessWidget {
  final SettingsController controller;

  const _NotificacoesCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      icon: Icons.notifications_outlined,
      title: 'Notificações',
      subtitle: 'Escolha o que você quer ser avisado.',
      child: Column(
        children: [
          _ToggleRow(
            title: 'Novas vagas compatíveis',
            subtitle: 'Avise quando surgirem vagas com alto match.',
            value: controller.notifNovasVagas,
            onChanged: controller.setNotifNovasVagas,
          ),
          _ToggleRow(
            title: 'Mensagens de empresas',
            subtitle: 'Notificar sobre novas mensagens de recrutadores.',
            value: controller.notifMensagens,
            onChanged: controller.setNotifMensagens,
          ),
          _ToggleRow(
            title: 'Resumo semanal por e-mail',
            subtitle: 'Receba um resumo das suas candidaturas.',
            value: controller.notifEmailSemanal,
            onChanged: controller.setNotifEmailSemanal,
          ),
          _ToggleRow(
            title: 'Notificações push',
            subtitle: 'Alertas em tempo real no dispositivo.',
            value: controller.notifPush,
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

  const _PrivacidadeCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      icon: Icons.shield_outlined,
      title: 'Privacidade e segurança',
      subtitle: 'Controle quem vê suas informações.',
      child: Column(
        children: [
          _ToggleRow(
            title: 'Perfil visível para empresas',
            subtitle: 'Empresas podem encontrar seu perfil nas buscas.',
            value: controller.perfilVisivelParaEmpresas,
            onChanged: controller.setPerfilVisivelParaEmpresas,
          ),
          _ToggleRow(
            title: 'Mostrar e-mail no perfil',
            subtitle: 'Exibir seu e-mail para recrutadores.',
            value: controller.mostrarEmailNoPerfil,
            onChanged: controller.setMostrarEmailNoPerfil,
            showDivider: false,
          ),
          const SizedBox(height: 4),
          _ActionRow(icon: Icons.lock_outline, label: 'Alterar senha', onTap: () {}),
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
              Switch(value: value, activeColor: AppColors.accent, onChanged: onChanged),
            ],
          ),
        ),
        if (showDivider) const Divider(height: 1, color: AppColors.cardBorder),
      ],
    );
  }
}

class _PreferenciasVagaCard extends StatelessWidget {
  final SettingsController controller;

  const _PreferenciasVagaCard({required this.controller});

  static const _tipos = ['Remoto', 'Híbrido', 'Presencial'];

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      icon: Icons.work_outline,
      title: 'Preferências de vaga',
      subtitle: 'Tipos de trabalho que você aceita.',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _tipos
            .map(
              (tipo) => _SelectableChip(
                label: tipo,
                selected: controller.tiposVagaPreferidos.contains(tipo),
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

class _AparenciaCard extends StatelessWidget {
  final SettingsController controller;

  const _AparenciaCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      icon: Icons.palette_outlined,
      title: 'Aparência',
      subtitle: 'Personalize a interface.',
      child: _ToggleRow(
        title: 'Tema escuro',
        subtitle: 'Prévia do tema escuro — em breve para o app inteiro.',
        value: controller.temaEscuro,
        onChanged: controller.setTemaEscuro,
        showDivider: false,
      ),
    );
  }
}

class _DangerZoneCard extends StatelessWidget {
  final VoidCallback onExcluirConta;

  const _DangerZoneCard({required this.onExcluirConta});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 20),
              SizedBox(width: 10),
              Text(
                'Zona de risco',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
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
                label: const Text('Sair da conta'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black87,
                  side: const BorderSide(color: AppColors.cardBorder),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              OutlinedButton.icon(
                onPressed: onExcluirConta,
                icon: const Icon(Icons.delete_outline, size: 16),
                label: const Text('Excluir conta'),
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
