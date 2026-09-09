import 'package:jobfy/core/theme/app_colors.dart';
import 'package:jobfy/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:jobfy/features/auth/domain/usecases/login_usecase.dart';
import 'package:jobfy/features/auth/domain/usecases/register_usecase.dart';
import 'package:jobfy/features/auth/presentation/controllers/auth_controller.dart';
import 'package:jobfy/l10n/app_localizations.dart';
import 'package:jobfy/shared/widgets/app_chip.dart';
import 'package:jobfy/shared/widgets/glow_circle.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _hoverForgotPassword = false;
  bool _hoverRegister = false;
  bool _hoverCompany = false;

  late final AuthController _authController;

  @override
  void initState() {
    super.initState();
    final repo = AuthRepositoryImpl();
    _authController = AuthController(
      LoginUsecase(repo),
      RegisterUsecase(repo),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _authController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final ok = await _authController.login(
      _emailController.text.trim(),
      _passwordController.text,
    );
    if (ok && mounted) context.go('/user');
  }

  String _errorMessage(AppLocalizations l10n, AuthErrorCode code) => switch (code) {
        AuthErrorCode.invalidCredentials => l10n.authErrorInvalidCredentials,
        AuthErrorCode.registrationFailed => l10n.authErrorRegistrationFailed,
        AuthErrorCode.network => l10n.authErrorNetwork,
      };

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
        final l10n = AppLocalizations.of(context)!;
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
            spacing: 16,
            children: [
              Row(
                spacing: 8,
                children: [
                  const Icon(Icons.lightbulb_circle, size: 36),
                  Text(
                    l10n.appName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  Text(
                    l10n.loginWelcomeBack,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    l10n.loginSubtitle,
                    style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                  ),
                ],
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: l10n.emailLabel,
                  hintText: l10n.emailHint,
                  prefixIcon: const Icon(Icons.email_outlined, size: 18),
                ),
              ),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: l10n.passwordLabel,
                  hintText: l10n.passwordHintMin6,
                  prefixIcon: const Icon(Icons.lock_outline, size: 18),
                ),
                onSubmitted: (_) => _handleLogin(),
              ),
              Row(
                spacing: 8,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: Checkbox(
                      value: _rememberMe,
                      onChanged: (v) => setState(() => _rememberMe = v!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  Text(l10n.rememberMe, style: const TextStyle(fontSize: 13)),
                ],
              ),
              if (_authController.errorCode != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    spacing: 8,
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.danger, size: 16),
                      Expanded(
                        child: Text(
                          _errorMessage(l10n, _authController.errorCode!),
                          style: const TextStyle(color: AppColors.danger, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
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
                      : Text(l10n.loginButton, style: const TextStyle(fontSize: 15)),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MouseRegion(
                    onEnter: (_) => setState(() => _hoverForgotPassword = true),
                    onExit: (_) => setState(() => _hoverForgotPassword = false),
                    child: GestureDetector(
                      onTap: () {},
                      child: Text(
                        l10n.forgotPassword,
                        style: TextStyle(
                          fontSize: 12,
                          color: _hoverForgotPassword ? AppColors.accent : AppColors.textMuted,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  MouseRegion(
                    onEnter: (_) => setState(() => _hoverRegister = true),
                    onExit: (_) => setState(() => _hoverRegister = false),
                    child: GestureDetector(
                      onTap: () => context.go('/register'),
                      child: Text(
                        l10n.createAccount,
                        style: TextStyle(
                          fontSize: 12,
                          color: _hoverRegister ? AppColors.accent : AppColors.textMuted,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  MouseRegion(
                    onEnter: (_) => setState(() => _hoverCompany = true),
                    onExit: (_) => setState(() => _hoverCompany = false),
                    child: GestureDetector(
                      onTap: () => context.go('/company'),
                      child: Text(
                        l10n.iAmCompany,
                        style: TextStyle(
                          fontSize: 12,
                          color: _hoverCompany ? AppColors.accent : AppColors.textMuted,
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
    final l10n = AppLocalizations.of(context)!;
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
            children: [
              Row(
                spacing: 10,
                children: [
                  const Icon(Icons.lightbulb_circle, color: Colors.white, size: 36),
                  Text(
                    l10n.appName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 64),
              Text(
                l10n.loginHeroTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.loginHeroSubtitle,
                style: const TextStyle(
                  color: AppColors.textLight,
                  fontSize: 15,
                  height: 1.7,
                ),
              ),
              const SizedBox(height: 48),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  AppChip(icon: Icons.work_outline, label: l10n.chipCustomJobs),
                  AppChip(icon: Icons.bolt_outlined, label: l10n.chipSmartMatch),
                  AppChip(icon: Icons.trending_up, label: l10n.chipCareerGrowth),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
