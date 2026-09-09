import 'package:jobfy/core/theme/app_colors.dart';
import 'package:jobfy/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:jobfy/features/auth/domain/usecases/login_usecase.dart';
import 'package:jobfy/features/auth/domain/usecases/register_usecase.dart';
import 'package:jobfy/features/auth/presentation/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum Gender { male, female, other }

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _cpfController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  Gender _gender = Gender.male;
  bool _acceptedTerms = false;

  late final AuthController _authController;

  @override
  void initState() {
    super.initState();
    final repo = AuthRepositoryImpl();
    _authController = AuthController(LoginUsecase(repo), RegisterUsecase(repo));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cpfController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _authController.dispose();
    super.dispose();
  }

  String _errorMessage(AuthErrorCode code) => switch (code) {
        AuthErrorCode.invalidCredentials => 'Email ou senha inválidos.',
        AuthErrorCode.registrationFailed => 'Erro ao criar conta. Tente novamente.',
      };

  Future<void> _handleRegister() async {
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Você precisa aceitar os termos.')),
      );
      return;
    }
    final ok = await _authController.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      cpf: _cpfController.text.trim(),
      password: _passwordController.text,
      gender: _gender.name,
    );
    if (ok && mounted) context.go('/user');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: Column(
            spacing: 12,
            children: [
              const Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: [
                  Icon(Icons.lightbulb_circle, size: 36),
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
              const Text(
                'Crie sua conta',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const Text(
                'Para o crescimento da sua carreira',
                style: TextStyle(fontSize: 14, color: AppColors.textMuted),
              ),
              const SizedBox(height: 20),
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
                      spacing: 16,
                      children: [
                        TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Nome completo',
                            hintText: 'Seu nome...',
                            prefixIcon: Icon(Icons.person_outline, size: 18),
                          ),
                        ),
                        TextField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            hintText: 'seu@email.com',
                            prefixIcon: Icon(Icons.email_outlined, size: 18),
                          ),
                        ),
                        TextField(
                          controller: _cpfController,
                          decoration: const InputDecoration(
                            labelText: 'CPF',
                            hintText: '000.000.000-00',
                            prefixIcon: Icon(Icons.badge_outlined, size: 18),
                          ),
                        ),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Senha',
                            hintText: 'Mínimo 6 caracteres',
                            prefixIcon: Icon(Icons.lock_outline, size: 18),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 8,
                          children: [
                            const Text(
                              'Gênero',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            // ignore: deprecated_member_use
                            RadioGroup<Gender>(
                              groupValue: _gender,
                              onChanged: (v) => setState(() => _gender = v!),
                              child: Row(
                                children: Gender.values
                                    .map((g) => Expanded(
                                          child: RadioListTile<Gender>(
                                            value: g,
                                            dense: true,
                                            contentPadding: EdgeInsets.zero,
                                            title: Text(
                                              g.name[0].toUpperCase() +
                                                  g.name.substring(1),
                                              style: const TextStyle(fontSize: 13),
                                            ),
                                          ),
                                        ))
                                    .toList(),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 8),
                        Row(
                          spacing: 8,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: Checkbox(
                                value: _acceptedTerms,
                                onChanged: (v) =>
                                    setState(() => _acceptedTerms = v!),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                            const Text(
                              'Aceito os ',
                              style: TextStyle(fontSize: 13),
                            ),
                            GestureDetector(
                              onTap: _showTerms,
                              child: const Text(
                                'termos de serviço',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.accent,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_authController.errorCode != null)
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
                              _errorMessage(_authController.errorCode!),
                              style: const TextStyle(
                                color: AppColors.danger,
                                fontSize: 13,
                              ),
                            ),
                          ),
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
                                : const Text(
                                    'Criar conta',
                                    style: TextStyle(fontSize: 15),
                                  ),
                          ),
                        ),
                        Center(
                          child: GestureDetector(
                            onTap: () => context.go('/login'),
                            child: const Text(
                              'Já tenho conta → Fazer login',
                              style: TextStyle(
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

  void _showTerms() {
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
            spacing: 16,
            children: [
              Row(
                children: [
                  const Text(
                    'Termos de Serviço',
                    style: TextStyle(
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
              const Divider(),
              const Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    'Ao criar uma conta na Jobfy, você concorda com nossa política de privacidade e termos de uso. Seus dados serão utilizados exclusivamente para conectar você a oportunidades de emprego relevantes.',
                    style: TextStyle(
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
}
