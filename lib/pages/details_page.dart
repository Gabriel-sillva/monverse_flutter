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
  bool _carregandoInventario = true;

  // Variáveis do Inventário de Bolas
  int _pokebolas = 0;
  int _greatBalls = 0;
  int _ultraBalls = 0;
  String _bolaSelecionada = "Pokébola";

  @override
  void initState() {
    super.initState();
    _carregarInventario();
  }

  // Carrega ou inicializa o inventário do jogador
  void _carregarInventario() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // Se for a primeira vez jogando, dá um pacote inicial de bolas
      _pokebolas = prefs.getInt('bag_pokebolas') ?? 5;
      _greatBalls = prefs.getInt('bag_greatballs') ?? 3;
      _ultraBalls = prefs.getInt('bag_ultraballs') ?? 1;
      _carregandoInventario = false;
    });
  }

  // Salva a quantidade atualizada na memória interna
  void _salvarInventario() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('bag_pokebolas', _pokebolas);
    await prefs.setInt('bag_greatballs', _greatBalls);
    await prefs.setInt('bag_ultraballs', _ultraBalls);
  }

  void _tentarCapturar() async {
    // 1. Valida se possui a bola escolhida
    if (_bolaSelecionada == "Pokébola" && _pokebolas <= 0 ||
        _bolaSelecionada == "Great Ball" && _greatBalls <= 0 ||
        _bolaSelecionada == "Ultra Ball" && _ultraBalls <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Você não tem mais $_bolaSelecionada!")),
      );
      return;
    }

    setState(() {
      _tentandoCapturar = true;
      // Desconta a bola utilizada
      if (_bolaSelecionada == "Pokébola") _pokebolas--;
      if (_bolaSelecionada == "Great Ball") _greatBalls--;
      if (_bolaSelecionada == "Ultra Ball") _ultraBalls--;
    });
    _salvarInventario();

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId == null) return;

    // Simula o tempo da Pokebola balançando no chão
    await Future.delayed(const Duration(seconds: 2));

    // 2. Lógica matemática de probabilidade baseada na bola
    double chanceBase = 40.0; // Chance padrão de captura (40%)
    double modificadorBola = 1.0;

    if (_bolaSelecionada == "Great Ball") modificadorBola = 1.5; // +50% de chance
    if (_bolaSelecionada == "Ultra Ball") modificadorBola = 2.2;  // Mais que o dobro

    double chanceFinal = chanceBase * modificadorBola;
    int dadoSorteado = Random().nextInt(100);

    // 3. Verifica sucesso
    if (dadoSorteado < chanceFinal) {
      bool sucesso = await _apiService.adicionarFavorito(widget.pokemon, userId);
      if (sucesso) {
        _mostrarResultado(
          "Capturado!", 
          "Woohoo! Sua $_bolaSelecionada funcionou e você capturou o ${widget.pokemon.nome.toUpperCase()}!", 
          Colors.green
        );
      }
    } else {
      _mostrarResultado(
        "Fugiu!", 
        "Ah não! O ${widget.pokemon.nome.toUpperCase()} quebrou a $_bolaSelecionada e escapou para o mato!", 
        Colors.red
      );
    }

    setState(() => _tentandoCapturar = false);
  }

  void _mostrarResultado(String titulo, String msg, Color cor) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(titulo, style: TextStyle(color: cor, fontWeight: FontWeight.bold, fontSize: 24)),
        content: Text(msg, style: const TextStyle(fontSize: 16)),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: cor, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(context); // Fecha o alerta
              Navigator.pop(context, titulo == "Capturado!"); // Retorna true ou false para a Home saber o status
            },
            child: const Text("OK", style: TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  // Widget auxiliar para renderizar os botões seletores de Pokébola
  Widget _buildBotaoBola(String nome, int quantidade, Color corItem) {
    bool selecionada = _bolaSelecionada == nome;
    return GestureDetector(
      onTap: _tentandoCapturar 
          ? null 
          : () => setState(() => _bolaSelecionada = nome),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selecionada ? corItem.withOpacity(0.2) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: selecionada ? corItem : Colors.grey[300]!,
            width: selecionada ? 2.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(Icons.catching_pokemon, color: corItem, size: 28),
            const SizedBox(height: 4),
            Text(nome, style: TextStyle(fontSize: 12, fontWeight: selecionada ? FontWeight.bold : FontWeight.normal)),
            Text("Qtd: $quantidade", style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
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
      body: _carregandoInventario
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2A3A5C)))
          : Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Círculo de habitat do Pokémon selvagem
                    Container(
                      width: 240,
                      height: 240,
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
                          child: Image.network(widget.pokemon.imagem, height: 160, fit: BoxFit.contain),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Pokémon Detectado",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[600]),
                    ),
                    Text(
                      widget.pokemon.nome.toUpperCase(),
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                    ),
                    
                    const SizedBox(height: 35),
                    const Text(
                      "SELECIONE SUA POKÉBOLA:",
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.blueGrey, letterSpacing: 1),
                    ),
                    const SizedBox(height: 10),

                    // Linha com seletores de Pokébolas
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildBotaoBola("Pokébola", _pokebolas, Colors.red),
                        const SizedBox(width: 10),
                        _buildBotaoBola("Great Ball", _greatBalls, Colors.blue),
                        const SizedBox(width: 10),
                        _buildBotaoBola("Ultra Ball", _ultraBalls, Colors.amber[700]!),
                      ],
                    ),

                    const SizedBox(height: 40),
                    
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
                              Text("A $_bolaSelecionada está balançando!", style: const TextStyle(color: Colors.grey)),
                            ],
                          )
                        : ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _bolaSelecionada == "Pokébola" 
                                  ? Colors.red 
                                  : _bolaSelecionada == "Great Ball" 
                                      ? Colors.blue 
                                      : Colors.amber[700],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 18),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              elevation: 5,
                              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            onPressed: _tentarCapturar,
                            icon: const Icon(Icons.catching_pokemon, size: 26),
                            label: Text("LANÇAR ${_bolaSelecionada.toUpperCase()}"),
                          ),
                  ],
                ),
              ),
            ),
    );
  }
}