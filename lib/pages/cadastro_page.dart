import 'package:flutter/material.dart';
import '../services/api_services.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final ApiService _apiService = ApiService();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _carregando = false;

  void _fazerCadastro() async {
    if (_nomeController.text.isEmpty || _emailController.text.isEmpty || _senhaController.text.isEmpty) {
      _msg("Preencha todos os campos!");
      return;
    }

    setState(() => _carregando = true);

    bool sucesso = await _apiService.cadastrarUsuario(
      _nomeController.text,
      _emailController.text,
      _senhaController.text,
    );

    setState(() => _carregando = false);

    if (sucesso) {
      _msg("Treinador cadastrado com sucesso! Faça o login.");
      Navigator.pop(context); // Volta para a tela de login
    } else {
      _msg("Erro ao cadastrar. E-mail já pode estar em uso.");
    }
  }

  void _msg(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, iconTheme: const IconThemeData(color: Colors.black)),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.catching_pokemon, size: 80, color: Color(0xFFDC2626)),
              const SizedBox(height: 10),
              const Text("Novo Treinador", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              const SizedBox(height: 30),
              TextField(
                controller: _nomeController,
                decoration: InputDecoration(labelText: "Nome do Treinador", border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(labelText: "E-mail", border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _senhaController,
                obscureText: true,
                decoration: InputDecoration(labelText: "Senha", border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
              ),
              const SizedBox(height: 30),
              _carregando
                  ? const CircularProgressIndicator(color: Color(0xFFDC2626))
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E293B),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      onPressed: _fazerCadastro,
                      child: const Text("CONCLUIR CADASTRO", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}