import 'package:aplicativo_jobfy/core/theme/app_colors.dart';
import 'package:aplicativo_jobfy/data/repositories/auth_repository_impl.dart';
import 'package:aplicativo_jobfy/domain/usecases/auth_usecase.dart';
import 'package:aplicativo_jobfy/features/auth/presentation/controllers/auth_controller.dart';
import 'package:aplicativo_jobfy/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
    _authController = AuthController(AuthUsecase(AuthRepositoryImpl()));
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
    if (!_aceitoTermos) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.termsRequiredError),
        ),
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
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 48),
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
                width: 440,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.cardBorder),
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
                            hintText: l10n.cpfHint,
                            prefixIcon: const Icon(Icons.badge_outlined, size: 18),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _senhaController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: l10n.passwordLabel,
                            hintText: l10n.passwordHintMin6,
                            prefixIcon: const Icon(Icons.lock_outline, size: 18),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          l10n.genderLabel,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
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
                              l10n.acceptTermsPrefix,
                              style: const TextStyle(fontSize: 13),
                            ),
                            GestureDetector(
                              onTap: _showTermos,
                              child: Text(
                                l10n.termsOfService,
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
                              l10n.authErrorRegistrationFailed,
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
                              backgroundColor: Colors.black,
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
                                    l10n.registerButton,
                                    style: const TextStyle(fontSize: 15),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: GestureDetector(
                            onTap: () => context.go('/login'),
                            child: Text(
                              l10n.alreadyHaveAccount,
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

  void _showTermos() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
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
                      backgroundColor: Colors.grey.shade100,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    l10n.termsDialogBody,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.7,
                      color: Colors.black87,
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

  String _generoLabel(AppLocalizations l10n, Genero genero) {
    switch (genero) {
      case Genero.masculino:
        return l10n.genderMale;
      case Genero.feminino:
        return l10n.genderFemale;
      case Genero.outro:
        return l10n.genderOther;
    }
  }
}
