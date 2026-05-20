import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pokemon_model.dart';
import '../services/api_services.dart';

class FavoritosPage extends StatefulWidget {
  const FavoritosPage({super.key});

  @override
  State<FavoritosPage> createState() => _FavoritosPageState();
}

class _FavoritosPageState extends State<FavoritosPage> {
  final ApiService _apiService = ApiService();
  List<Pokemon> _meusPokemons = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarMochila();
  }

  void _carregarMochila() async {
    setState(() => _carregando = true);
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId != null) {
      final lista = await _apiService.getFavoritos(userId);
      setState(() {
        _meusPokemons = lista;
        _carregando = false;
      });
    } else {
      setState(() => _carregando = false);
    }
  }

  void _soltarPokemon(String idDb) async {
    bool sucesso = await _apiService.removerFavorito(idDb);
    if (sucesso) {
      _carregarMochila();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("O Pokémon voltou feliz para a floresta!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text("Minha Equipe", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E293B),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1E293B)))
          : _meusPokemons.isEmpty
              ? const Center(
                  child: Text(
                    "Sua mochila está vazia!\nVá capturar alguns Pokémons selvagens.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _meusPokemons.length,
                  itemBuilder: (context, index) {
                    return _cardPokemonEquipe(_meusPokemons[index]);
                  },
                ),
    );
  }

  Widget _cardPokemonEquipe(Pokemon pokemon) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Imagem e Level
            Column(
              children: [
                Image.network(pokemon.imagem, height: 85, width: 85, fit: BoxFit.contain),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "Nível ${pokemon.level}",
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 15),
            
            // Atributos de RPG (HP, ATK, DEF)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pokemon.nome.toUpperCase(),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 6),
                  _barraStatus("Vida (HP)", pokemon.hpAtual, pokemon.hpMax, Colors.green),
                  _barraStatus("Ataque", pokemon.ataque, 60, Colors.red),
                  _barraStatus("Defesa", pokemon.defesa, 60, Colors.orange),
                ],
              ),
            ),
            
            // Botão de Libertar
            IconButton(
              icon: const Icon(Icons.disabled_by_default, color: Colors.redAccent, size: 28),
              tooltip: "Soltar na Natureza",
              onPressed: () => _confirmarLiberacao(pokemon),
            ),
          ],
        ),
      ),
    );
  }

  Widget _barraStatus(String nome, int valorAtual, int valorMax, Color cor) {
    double progresso = valorAtual / valorMax;
    // Garante que o progresso não quebre se passar de 1.0 ou cair de 0.0
    if (progresso > 1.0) progresso = 1.0;
    if (progresso < 0.0) progresso = 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            child: Text(nome, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: LinearProgressIndicator(
                value: progresso,
                backgroundColor: Colors.grey[200],
                color: cor,
                minHeight: 6,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text("$valorAtual/$valorMax", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _confirmarLiberacao(Pokemon pokemon) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Soltar Pokémon?"),
        content: Text("Tem certeza que deseja despedir-se de seu ${pokemon.nome.toUpperCase()} e deixá-lo voltar à natureza?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCELAR")),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (pokemon.idDb != null) {
                _soltarPokemon(pokemon.idDb!);
              }
            },
            child: const Text("SOLTAR", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}