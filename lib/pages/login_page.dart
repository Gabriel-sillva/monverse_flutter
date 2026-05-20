import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_services.dart';
import 'home_page.dart';
import 'cadastro_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final ApiService _apiService = ApiService();

  bool _carregando = false;

  // FUNÇÃO LOGIN
  void _fazerLogin() async {
    setState(() => _carregando = true);

    String email = _emailController.text.trim();
    String senha = _passwordController.text.trim();

    var usuario = await _apiService.login(email, senha);

    if (usuario != null) {
      // SALVA DADOS LOCALMENTE
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('userId', usuario.id);
      await prefs.setString('userName', usuario.nome);
      await prefs.setString('userRole', usuario.role);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomePage(),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Email ou senha incorretos!"),
          ),
        );
      }
    }

    if (mounted) {
      setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E293B),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              // TÍTULO
              const Text(
                "MONVERSE",
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFFDE00),
                  letterSpacing: 4,
                ),
              ),

              const SizedBox(height: 40),

              // CARD LOGIN
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),

                child: Column(
                  children: [
                    // EMAIL
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: "Email",
                      ),
                    ),

                    const SizedBox(height: 15),

                    // SENHA
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: "Senha",
                      ),
                    ),

                    const SizedBox(height: 30),

                    // BOTÃO LOGIN
                    _carregando
                        ? const CircularProgressIndicator()
                        : SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color(0xFFCC0000),
                                foregroundColor: Colors.white,
                              ),
                              onPressed: _fazerLogin,
                              child: const Text(
                                "ENTRAR NA POKÉDEX",
                              ),
                            ),
                          ),

                    const SizedBox(height: 15),

                    // BOTÃO CADASTRO
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const CadastroPage(),
                          ),
                        );
                      },
                      child: const Text(
                        "Sou um novo Treinador. Criar Conta!",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}