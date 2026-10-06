import 'package:aplicativo_jobfy/core/theme/app_colors.dart';
import 'package:aplicativo_jobfy/core/theme/app_palette.dart';
import 'package:aplicativo_jobfy/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:aplicativo_jobfy/features/auth/domain/usecases/login_usecase.dart';
import 'package:aplicativo_jobfy/features/auth/domain/usecases/register_usecase.dart';
import 'package:aplicativo_jobfy/features/auth/presentation/controllers/auth_controller.dart';
import 'package:aplicativo_jobfy/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const double _kRegisterCardMaxWidth = 440;

enum Genero { masculino, feminino, outro }

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nomeController = TextEditingController();
  final _cpfController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  Genero _genero = Genero.masculino;
  bool _aceitoTermos = false;

  late final AuthController _authController;

  @override
  void initState() {
    super.initState();
    final repo = AuthRepositoryImpl();
    _authController = AuthController(LoginUsecase(repo), RegisterUsecase(repo));
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cpfController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _authController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final l10n = AppLocalizations.of(context);
    if (!_aceitoTermos) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.registerTermsRequired)),
      );
      return;
    }
    final ok = await _authController.register(
      nome: _nomeController.text.trim(),
      email: _emailController.text.trim(),
      cpf: _cpfController.text.trim(),
      senha: _senhaController.text,
      genero: _genero.name,
    );
    if (ok && mounted) context.go('/user');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;

    return Scaffold(
      backgroundColor: palette.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 48),
          child: Column(
            children: [
              const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lightbulb_circle, size: 36),
                  SizedBox(width: 8),
                  Text(
                    'Jobfy',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                l10n.registerTitle,
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.registerSubtitle,
                style: const TextStyle(fontSize: 14, color: AppColors.textMuted),
              ),
              const SizedBox(height: 32),
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: _kRegisterCardMaxWidth),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: palette.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: palette.border),
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
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _nomeController,
                          decoration: InputDecoration(
                            labelText: l10n.fullNameLabel,
                            hintText: l10n.fullNameHint,
                            prefixIcon: const Icon(Icons.person_outline, size: 18),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: l10n.emailLabel,
                            hintText: l10n.emailHint,
                            prefixIcon: const Icon(Icons.email_outlined, size: 18),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _cpfController,
                          decoration: InputDecoration(
                            labelText: l10n.cpfLabel,
                            hintText: '000.000.000-00',
                            prefixIcon: const Icon(Icons.badge_outlined, size: 18),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _senhaController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: l10n.passwordLabel,
                            hintText: l10n.passwordHint,
                            prefixIcon: const Icon(Icons.lock_outline, size: 18),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          l10n.genderLabel,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: palette.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // ignore: deprecated_member_use
                        RadioGroup<Genero>(
                          groupValue: _genero,
                          onChanged: (v) => setState(() => _genero = v!),
                          child: Row(
                            children: Genero.values
                                .map((g) => Expanded(
                                      child: RadioListTile<Genero>(
                                        value: g,
                                        dense: true,
                                        contentPadding: EdgeInsets.zero,
                                        title: Text(
                                          _generoLabel(l10n, g),
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                        const Divider(height: 24),
                        Row(
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: Checkbox(
                                value: _aceitoTermos,
                                onChanged: (v) =>
                                    setState(() => _aceitoTermos = v!),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l10n.registerAcceptTermsPrefix,
                              style: const TextStyle(fontSize: 13),
                            ),
                            GestureDetector(
                              onTap: _showTermos,
                              child: Text(
                                l10n.registerTermsLink,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.accent,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_authController.error != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.danger.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppColors.danger.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              l10n.authErrorRegisterFailed,
                              style: const TextStyle(
                                color: AppColors.danger,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _authController.isLoading
                                ? null
                                : _handleRegister,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: palette.strongButton,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: _authController.isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    l10n.createAccount,
                                    style: const TextStyle(fontSize: 15),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: GestureDetector(
                            onTap: () => context.go('/login'),
                            child: Text(
                              l10n.registerGoToLogin,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textMuted,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ],
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

  String _generoLabel(AppLocalizations l10n, Genero genero) => switch (genero) {
        Genero.masculino => l10n.genderMale,
        Genero.feminino => l10n.genderFemale,
        Genero.outro => l10n.genderOther,
      };

  void _showTermos() {
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: palette.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 560, maxHeight: 480),
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    l10n.termsTitle,
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
                      backgroundColor: palette.background,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    l10n.termsBody,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.7,
                      color: palette.textPrimary,
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
