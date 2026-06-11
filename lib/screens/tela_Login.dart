import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

bool lembreMe = false;

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Row(
          children: [
            Expanded(child: _LeftPanel()),
            Expanded(
              child: Center(
                child: IntrinsicHeight(
                  child: SizedBox(width: 600, child: _CardForm()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeftPanel extends StatelessWidget {
  const _LeftPanel();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF090D1A), Color(0xFF111827)],
            ),
          ),
        ),
        Positioned(
          top: -80,
          left: -80,
          child: _GlowCircle(
            size: 380,
            color: Color(0xFF1D4ED8).withValues(alpha: 0.25),
          ),
        ),
        Positioned(
          bottom: 60,
          right: -100,
          child: _GlowCircle(
            size: 400,
            color: Color(0xFF4F46E5).withValues(alpha: 0.2),
          ),
        ),
        Positioned(
          top: 280,
          left: 80,
          child: _GlowCircle(
            size: 180,
            color: Color(0xFF0EA5E9).withValues(alpha: 0.15),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
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
              const SizedBox(height: 64),
              const Text(
                'Conecte-se ao\nseu próximo emprego.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'A Jobfy conecta talentos a oportunidades reais.\nPublique suas habilidades, encontre vagas\npersonalizadas e acelere sua carreira\ncom inteligência.',
                style: TextStyle(
                  color: Color(0xFFCBD5E1),
                  fontSize: 15,
                  height: 1.7,
                ),
              ),
              const SizedBox(height: 48),
              Row(
                children: const [
                  _Chip(
                    icon: Icons.work_outline,
                    label: 'Vagas personalizadas',
                  ),
                  SizedBox(width: 12),
                  _Chip(icon: Icons.bolt_outlined, label: 'Match inteligente'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GlowCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowCircle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _Chip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 15),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _CardForm extends StatefulWidget {
  const _CardForm({super.key});

  @override
  State<_CardForm> createState() => _CardFormState();
}

class _CardFormState extends State<_CardForm> {
  var color = Colors.grey;
  var color2 = Colors.grey;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(64.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: <Widget>[
            Row(
              spacing: 5,
              children: [
                Icon(Icons.lightbulb_circle, size: 40),
                Text(
                  'Jobfy',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
            Text(
              'Coloque suas informações',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextField(
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: Colors.black, fontSize: 14),
                hintText: 'seu@email.com',
                hintStyle: TextStyle(color: Colors.grey, fontSize: 12),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 2),
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onChanged: (text) {

              },
            ),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Senha',
                labelStyle: TextStyle(color: Colors.black, fontSize: 14),
                hintText: 'Mínimo 8 caracteres',
                hintStyle: TextStyle(color: Colors.grey, fontSize: 12),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 2),
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onChanged: (text) {

              },
            ),

            Row(
              spacing: 14,
              children: [
                InkWell(
                  onHover: (event) {
                    setState(() {
                      color = event ? Colors.lightBlue : Colors.grey;
                    });
                  },
                  onTap: () {

                  },
                  child: Ink(
                    child: Text(
                      'Esqueceu sua senha?',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: color,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),

                InkWell(
                  onHover: (event) {
                    setState(() {
                      color2 = event ? Colors.lightBlue : Colors.grey;
                    });
                  },
                  onTap: () {
                    context.go('/register');
                  },
                  child: Ink(
                    child: Text(
                      'Cadastrar-se',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: color2,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: () {},
                child: Ink(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.black,
                  ),
                  height: 40,
                  width: 500,

                  child: Center(
                    child: Text(
                      'Logar',
                      style: TextStyle(fontSize: 17, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
