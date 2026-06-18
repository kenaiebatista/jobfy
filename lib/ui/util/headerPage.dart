import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';

class headerPage extends StatelessWidget implements PreferredSizeWidget {
  const headerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          borderRadius: BorderRadius.circular(16),
          onHover: (event) {
            setState() {}
          },
          onTap: () {},
          child: Ink(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(Icons.menu, color: Colors.white),
            ),
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.account_circle, color: Colors.white),
            onPressed: () {
              context.go('/login');
            },
          ),
        ],
        title: Row(
          spacing: 5,
          children: <Widget>[
            Icon(Icons.lightbulb_circle, color: Colors.white, size: 40),
            Text('Jobfy', style: TextStyle(color: Colors.white, fontSize: 22)),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
