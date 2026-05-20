import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pokemon_model.dart';
import '../services/api_services.dart';

class DetailsPage extends StatefulWidget {
  final Pokemon pokemon;
  const DetailsPage({super.key, required this.pokemon});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  final ApiService _apiService = ApiService();
  bool _tentandoCapturar = false;

  void _tentarCapturar() async {
    setState(() => _tentandoCapturar = true);

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId == null) return;

    // Simula o tempo da Pokebola balançando no chão
    await Future.delayed(const Duration(seconds: 2));

    // Sistema de Sorte: 60% de chance de sucesso
    int chance = Random().nextInt(100);
    if (chance < 60) {
      bool sucesso = await _apiService.adicionarFavorito(widget.pokemon, userId);
      if (sucesso) {
        _mostrarResultado("Capturado!", "Woohoo! Você capturou o ${widget.pokemon.nome.toUpperCase()} com sucesso!", Colors.green);
      }
    } else {
      _mostrarResultado("Fugiu!", "Ah não! O ${widget.pokemon.nome.toUpperCase()} quebrou a Pokebola e escapou!", Colors.red);
    }

    setState(() => _tentandoCapturar = false);
  }

  void _mostrarResultado(String titulo, String msg, Color cor) {
    showDialog(
      context: context,
      barrierDismissible: false, // Força o jogador a clicar no OK
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(titulo, style: TextStyle(color: cor, fontWeight: FontWeight.bold, fontSize: 24)),
        content: Text(msg, style: const TextStyle(fontSize: 16)),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: cor, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(context); // Fecha o alerta
              if (titulo == "Capturado!") {
                Navigator.pop(context); // Se capturou, volta automático para o mapa/lista principal
              }
            },
            child: const Text("OK", style: TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        title: const Text("Área Selvagem", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xFF2A3A5C),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Círculo de habitat do Pokémon selvagem
              Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF2A3A5C), width: 4),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, spreadRadius: 2),
                  ],
                ),
                child: Center(
                  child: Hero(
                    tag: widget.pokemon.idPokeApi,
                    child: Image.network(widget.pokemon.imagem, height: 180, fit: BoxFit.contain),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Text(
                "Nível Desconhecido",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[600]),
              ),
              Text(
                widget.pokemon.nome.toUpperCase(),
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 50),
              
              // Mecânica do botão de ação do jogo
              _tentandoCapturar
                  ? Column(
                      children: [
                        const CircularProgressIndicator(color: Colors.red, strokeWidth: 5),
                        const SizedBox(height: 15),
                        Text(
                          "1... 2... 3...", 
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red[700]),
                        ),
                        const Text("A Pokebola está balançando!", style: TextStyle(color: Colors.grey)),
                      ],
                    )
                  : ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDC2626),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        elevation: 5,
                        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      onPressed: _tentarCapturar,
                      icon: const Icon(Icons.catching_pokemon, size: 28),
                      label: const Text("LANÇAR POKEBOLA"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}