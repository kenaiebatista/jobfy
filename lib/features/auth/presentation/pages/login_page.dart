import 'package:aplicativo_jobfy/core/theme/app_colors.dart';
import 'package:aplicativo_jobfy/data/repositories/auth_repository_impl.dart';
import 'package:aplicativo_jobfy/domain/usecases/auth_usecase.dart';
import 'package:aplicativo_jobfy/features/auth/presentation/controllers/auth_controller.dart';
import 'package:aplicativo_jobfy/shared/widgets/app_chip.dart';
import 'package:aplicativo_jobfy/shared/widgets/glow_circle.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _lembreMe = false;
  bool _hoverEsqueci = false;
  bool _hoverCadastro = false;

  late final AuthController _authController;

  @override
  void initState() {
    super.initState();
    _authController = AuthController(AuthUsecase(AuthRepositoryImpl()));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    _authController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final ok = await _authController.login(
      _emailController.text.trim(),
      _senhaController.text,
    );
    if (ok && mounted) context.go('/user');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const Expanded(child: _LeftPanel()),
          Expanded(
            child: Center(
              child: SizedBox(
                width: 480,
                child: _buildForm(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return ListenableBuilder(
      listenable: _authController,
      builder: (context, _) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.cardBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.lightbulb_circle, size: 36),
                  SizedBox(width: 8),
                  Text(
                    'Jobfy',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Bem-vindo de volta',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Insira suas credenciais para acessar.',
                style: TextStyle(fontSize: 13, color: AppColors.textMuted),
              ),
              const SizedBox(height: 28),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'seu@email.com',
                  prefixIcon: Icon(Icons.email_outlined, size: 18),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _senhaController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Senha',
                  hintText: 'Mínimo 6 caracteres',
                  prefixIcon: Icon(Icons.lock_outline, size: 18),
                ),
                onSubmitted: (_) => _handleLogin(),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: Checkbox(
                      value: _lembreMe,
                      onChanged: (v) => setState(() => _lembreMe = v!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('Lembre-me', style: TextStyle(fontSize: 13)),
                ],
              ),
              if (_authController.errorMessage.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.danger, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        _authController.errorMessage,
                        style: const TextStyle(color: AppColors.danger, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _authController.isLoading ? null : _handleLogin,
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
                      : const Text('Entrar', style: TextStyle(fontSize: 15)),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MouseRegion(
                    onEnter: (_) => setState(() => _hoverEsqueci = true),
                    onExit: (_) => setState(() => _hoverEsqueci = false),
                    child: GestureDetector(
                      onTap: () {},
                      child: Text(
                        'Esqueceu a senha?',
                        style: TextStyle(
                          fontSize: 12,
                          color: _hoverEsqueci ? AppColors.accent : AppColors.textMuted,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  MouseRegion(
                    onEnter: (_) => setState(() => _hoverCadastro = true),
                    onExit: (_) => setState(() => _hoverCadastro = false),
                    child: GestureDetector(
                      onTap: () => context.go('/register'),
                      child: Text(
                        'Criar conta',
                        style: TextStyle(
                          fontSize: 12,
                          color: _hoverCadastro ? AppColors.accent : AppColors.textMuted,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  MouseRegion(
                    onEnter: (_) => setState(() => _hoverCadastro = true),
                    onExit: (_) => setState(() => _hoverCadastro = false),
                    child: GestureDetector(
                      onTap: () => context.go('/company'),
                      child: Text(
                        'Sou empresa',
                        style: TextStyle(
                          fontSize: 12,
                          color: _hoverCadastro ? AppColors.accent : AppColors.textMuted,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LeftPanel extends StatelessWidget {
  const _LeftPanel();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.backgroundDark, AppColors.backgroundDark2],
            ),
          ),
        ),
        const Positioned(
          top: -80, left: -80,
          child: GlowCircle(size: 380, color: Color(0x401D4ED8)),
        ),
        const Positioned(
          bottom: 60, right: -100,
          child: GlowCircle(size: 400, color: Color(0x334F46E5)),
        ),
        const Positioned(
          top: 280, left: 80,
          child: GlowCircle(size: 180, color: Color(0x260EA5E9)),
        ),
        Padding(
          padding: const EdgeInsets.all(48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Row(
                children: [
                  Icon(Icons.lightbulb_circle, color: Colors.white, size: 36),
                  SizedBox(width: 10),
                  Text(
                    'Jobfy',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 64),
              Text(
                'Conecte-se ao\nseu próximo emprego.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  height: 1.25,
                ),
              ),
              SizedBox(height: 24),
              Text(
                'A Jobfy conecta talentos a oportunidades reais.\nPublique suas habilidades, encontre vagas\npersonalizadas e acelere sua carreira\ncom inteligência.',
                style: TextStyle(
                  color: AppColors.textLight,
                  fontSize: 15,
                  height: 1.7,
                ),
              ),
              SizedBox(height: 48),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  AppChip(icon: Icons.work_outline, label: 'Vagas personalizadas'),
                  AppChip(icon: Icons.bolt_outlined, label: 'Match inteligente'),
                  AppChip(icon: Icons.trending_up, label: 'Crescimento de carreira'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
