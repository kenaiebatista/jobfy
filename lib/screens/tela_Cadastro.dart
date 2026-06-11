import 'package:aplicativo_jobfy/screens/tela_Login.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum Genero { Masculino, Feminino, Outro }

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

String nome = '';
String senha = '';
String CPF = '';
Genero genero = Genero.Masculino;
bool aceitoTermos = false;

class _RegisterPageState extends State<RegisterPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.white),
          onPressed: () {},
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
      body: Center(
        child: Column(
          children: [
            Text(
              'Crie sua conta Jobfy',
              style: TextStyle(
                fontSize: 40,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Para o crescimento da sua carreira e da sua pessoa',
              style: TextStyle(fontSize: 15),
            ),
            Container(
              width: 400,
              height: 500,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  spacing: 16,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Nome',
                        labelStyle: TextStyle(fontSize: 13),
                        hintText: 'Nome Completo...',
                        hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 2),
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onChanged: (text) {
                        nome = text;
                      },
                    ),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'CPF',
                        labelStyle: TextStyle(fontSize: 13),
                        hintText: 'Seu CPF...',
                        hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 2),
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onChanged: (text) {
                        CPF = text;
                      },
                    ),
                    Divider(),
                    Row(
                      spacing: 1,
                      children: [
                        Radio(
                          value: Genero.Masculino,
                          groupValue: genero,
                          onChanged: (Genero? generoSelecionado) {
                            setState(() {
                              genero = generoSelecionado!;
                            });
                          },
                        ),
                        Text('Masculino'),
                        Radio(
                          value: Genero.Feminino,
                          groupValue: genero,
                          onChanged: (Genero? generoSelecionado) {
                            setState(() {
                              genero = generoSelecionado!;
                            });
                          },
                        ),
                        Text('Feminino'),
                        Radio(
                          value: Genero.Outro,
                          groupValue: genero,
                          onChanged: (Genero? generoSelecionado) {
                            setState(() {
                              genero = generoSelecionado!;
                            });
                          },
                        ),
                        Text('Outro'),
                      ],
                    ),
                    Divider(),
                    Row(
                      children: [
                        Checkbox(
                          value: aceitoTermos,
                          onChanged: (bool? value) {
                            setState(() {
                              aceitoTermos = value!;
                            });
                          },
                        ),
                        Text('Aceito os termos'),
                      ],
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(15),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return Dialog(
                              backgroundColor: Colors.white,
                              constraints: BoxConstraints(
                                maxHeight: 680,
                                maxWidth: 600,
                                minWidth: 600,
                              ),
                              insetPadding: EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 24,
                              ),
                              child: Card(
                                margin: EdgeInsets.all(10),
                                elevation: 0,
                                color: Colors.white,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            'Termos de serviço',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Spacer(),
                                          InkWell(
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                            onTap: () {
                                              Navigator.pop(context);
                                            },
                                            child: Ink(
                                              width: 88,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                color: Colors.black,
                                              ),
                                              child: Center(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                    8.0,
                                                  ),
                                                  child: Text(
                                                    'Fechar',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                      child: Ink(
                        child: Text(
                          'Ler os termos de serviço',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ),
                    ),
                    Center(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: (){

                          },
                          borderRadius: BorderRadius.circular(15),
                          child: Ink(height: 40, width: 400,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Center(
                              child: Text(
                                'Cadastrar-se',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
