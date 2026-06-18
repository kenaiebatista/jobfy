import 'package:aplicativo_jobfy/main.dart';
import 'package:aplicativo_jobfy/ui/util/headerPage.dart';
import 'package:flutter/material.dart';

enum Genero { Masculino, Feminino, Outro }

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

var cadastro = false;
String nome = '';
String senha = '';
String CPF = '';
Genero genero = Genero.Masculino;
bool aceitoTermos = false;

class _RegisterPageState extends State<RegisterPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Center(
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
                  height: 550,
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
                            hintStyle: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey,
                                width: 2,
                              ),
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
                            hintStyle: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onChanged: (text) {
                            CPF = text;
                          },
                        ),
                        Divider(),
                        TextField(
                          decoration: InputDecoration(
                            labelText: 'Senha',
                            labelStyle: TextStyle(fontSize: 13),
                            hintText: 'Sua Senha...',
                            hintStyle: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey,
                                width: 2,
                              ),
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
                              onChanged: (Genero? generoSelecionado) =>
                                  setState(() {
                                    genero = generoSelecionado!;
                                  }),
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
                                                borderRadius:
                                                    BorderRadius.circular(15),
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
                                                      padding:
                                                          const EdgeInsets.all(
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
                              onTap: () {
                                (bool? value) {
                                  setState(
                                    (bool? value) {
                                          cadastro = value!;
                                        }
                                        as VoidCallback,
                                  );
                                };
                              },
                              borderRadius: BorderRadius.circular(15),
                              child: Ink(
                                height: 40,
                                width: 400,
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
                        Center(
                          child: cadastro == true
                              ? Text(
                                  'Cadastro realizado com sucesso',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.green,
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
