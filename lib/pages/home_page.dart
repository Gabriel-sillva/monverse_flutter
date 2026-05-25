import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart'; 
import '../models/pokemon_model.dart';
import '../services/api_services.dart';

import './details_page.dart';     
import './favoritos_page.dart';   
import './login_page.dart';

// ==========================================
// 1. ABA DO RADAR (CAÇA POKÉMON COM RETORNO DE CAPTURA)
// ==========================================
class RadarTab extends StatelessWidget {
  final bool procurandoGps;
  final String coordenadasTexto;
  final List<Pokemon> pokemonsNoRadar;
  final List<int> idsCapturados; // Nova lista para saber o que já foi pego
  final VoidCallback onEscanear;
  final Function(Pokemon) onInteragir; // Nova função para gerenciar o clique

  const RadarTab({
    super.key,
    required this.procurandoGps,
    required this.coordenadasTexto,
    required this.pokemonsNoRadar,
    required this.idsCapturados,
    required this.onEscanear,
    required this.onInteragir,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            color: const Color(0xFF1E293B),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_on, color: Colors.lightGreenAccent, size: 16),
                const SizedBox(width: 5),
                Text(
                  coordenadasTexto,
                  style: const TextStyle(color: Colors.lightGreenAccent, fontSize: 12, fontFamily: 'monospace'),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: procurandoGps
                ? const Column(
                    children: [
                      SizedBox(height: 40),
                      CircularProgressIndicator(strokeWidth: 6, color: Colors.blue),
                      SizedBox(height: 15),
                      Text("Escaneando coordenadas com pulso Sonar...", style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  )
                : pokemonsNoRadar.isEmpty
                    ? Column(
                        children: [
                          const SizedBox(height: 40),
                          Icon(Icons.radar, size: 100, color: Colors.grey[400]),
                          const SizedBox(height: 15),
                          const Text("Nenhum Pokémon selvagem por perto.", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
                          const Text("Clique abaixo para escanear seu GPS!", style: TextStyle(color: Colors.grey, fontSize: 13)),
                        ],
                      )
                    : Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(12),
                            child: Text("🔴 DETECTADOS NO RADAR GPS:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 15, letterSpacing: 1)),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            itemCount: pokemonsNoRadar.length,
                            itemBuilder: (context, index) {
                              final poke = pokemonsNoRadar[index];
                              
                              // Verifica se este Pokémon específico já está na lista de capturados
                              final bool jaCapturado = idsCapturados.contains(poke.idPokeApi);

                              return Card(
                                elevation: 3,
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                child: ListTile(
                                  leading: Image.network(poke.imagem, width: 50),
                                  title: Text(poke.nome.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  subtitle: Text(
                                    jaCapturado ? "Registrado na sua Pokédex" : "Status: Próximo à sua localização",
                                    style: TextStyle(fontSize: 12, color: jaCapturado ? Colors.green[700] : Colors.grey[600]),
                                  ),
                                  // Modificação visual baseada no status de captura
                                  trailing: jaCapturado
                                      ? Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: Colors.green[50],
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: Colors.green),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.check_circle, color: Colors.green, size: 16),
                                              SizedBox(width: 4),
                                              Text("CAPTURADO", style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                        )
                                      : ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.orange, 
                                            foregroundColor: Colors.white, 
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                                          ),
                                          onPressed: () => onInteragir(poke),
                                          child: const Text("INTERAGIR", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                        ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 4,
                ),
                onPressed: onEscanear,
                icon: const Icon(Icons.radar),
                label: const Text("ESCANEAR MEU GPS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 2. ABA DO MINI-GAME 
// ==========================================
class GameTab extends StatelessWidget {
  final Pokemon? pokemonDoGame;
  final List<String> opcionesDoGame;
  final bool revelarPokemonDoGame;
  final String resultadoTextoGame;
  final Function(String) onSelecionarResposta;
  final VoidCallback onProximoRound;

  const GameTab({
    super.key,
    required this.pokemonDoGame,
    required this.opcionesDoGame,
    required this.revelarPokemonDoGame,
    required this.resultadoTextoGame,
    required this.onSelecionarResposta,
    required this.onProximoRound,
  });

  @override
  Widget build(BuildContext context) {
    if (pokemonDoGame == null) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF1E293B)));
    }

    List<Widget> conteudoDoCard = [
      Text(
        resultadoTextoGame,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF166534)),
      ),
      const SizedBox(height: 25),
      Container(
        height: 140,
        alignment: Alignment.center,
        child: Image.network(
          pokemonDoGame!.imagem,
          height: 130,
          color: revelarPokemonDoGame ? null : Colors.black.withOpacity(0.9),
          colorBlendMode: revelarPokemonDoGame ? null : BlendMode.srcIn,
        ),
      ),
      const SizedBox(height: 25),
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 2.5,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          mainAxisExtent: 50,
        ),
        itemCount: opcionesDoGame.length,
        itemBuilder: (context, idx) {
          final opcaoNome = opcionesDoGame[idx];
          return ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: revelarPokemonDoGame 
                  ? (opcaoNome == pokemonDoGame!.nome.toUpperCase() ? Colors.green : Colors.grey[400])
                  : const Color(0xFFFFDE00),
              foregroundColor: revelarPokemonDoGame ? Colors.white : Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
            ),
            onPressed: () => onSelecionarResposta(opcaoNome),
            child: Text(opcaoNome, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          );
        },
      ),
    ];

    if (revelarPokemonDoGame) {
      conteudoDoCard.add(const SizedBox(height: 20));
      conteudoDoCard.add(
        TextButton.icon(
          onPressed: onProximoRound,
          icon: const Icon(Icons.refresh, color: Colors.blue, size: 24),
          label: const Text("PRÓXIMO ROUND", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 15)),
        ),
      );
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          child: Container(
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              gradient: const LinearGradient(
                colors: [Color(0xFFF0FDF4), Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: conteudoDoCard,
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 3. TELA PRINCIPAL (GERENCIAMENTO DE ESTADO E INVENTÁRIO)
// ==========================================
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService _apiService = ApiService();
  List<Pokemon> _todosPokemonsDaApi = [];
  List<Pokemon> _pokemonsNoRadar = [];
  List<int> _idsCapturados = []; // Lista local para monitorar os já capturados
  bool _carregando = true;
  bool _procurandoGps = false;
  String _coordenadasTexto = "Clique no radar para buscar";

  int _abaAtual = 0;

  Pokemon? _pokemonDoGame;
  List<String> _opcoesDoGame = [];
  bool _revelarPokemonDoGame = false;
  String _resultadoTextoGame = "Quem é esse Pokémon?";

  @override
  void initState() {
    super.initState();
    _carregarDadosIniciais();
  }

  void _carregarDadosIniciais() async {
    try {
      final lista = await _apiService.buscarTodosPokemons();
      setState(() {
        _todosPokemonsDaApi = lista;
      });
      
      // Busca quais IDs o usuário já capturou na nuvem do Render
      await _atualizarListaDeCapturados();
      
      setState(() => _carregando = false);
      _gerarNovoRoundGame();
    } catch (e) {
      setState(() => _carregando = false);
    }
  }

  // Função dedicada a bater no Render e atualizar o inventário de capturados
  Future<void> _atualizarListaDeCapturados() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId != null) {
      final capturados = await _apiService.getFavoritos(userId);
      setState(() {
        _idsCapturados = capturados.map((p) => p.idPokeApi).toList();
      });
    }
  }

  // Gerencia a navegação para a DetailsPage e espera o resultado da captura
  void _gerenciarInteracao(Pokemon pokemon) async {
    final resultadoCaptura = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DetailsPage(pokemon: pokemon)),
    );

    // Se o resultado voltar como true (Sucesso na captura), atualiza a Home imediatamente
    if (resultadoCaptura == true) {
      _atualizarListaDeCapturados();
    }
  }

  void _gerarNovoRoundGame() {
    if (_todosPokemonsDaApi.isEmpty) return;

    var random = Random();
    Pokemon correto = _todosPokemonsDaApi[random.nextInt(_todosPokemonsDaApi.length)];

    Set<String> opcoes = {correto.nome.toUpperCase()};
    while (opcoes.length < 4) {
      String nomeErrado = _todosPokemonsDaApi[random.nextInt(_todosPokemonsDaApi.length)].nome.toUpperCase();
      opcoes.add(nomeErrado);
    }

    List<String> listaOpcoes = opcoes.toList();
    listaOpcoes.shuffle();

    setState(() {
      _pokemonDoGame = correto;
      _opcoesDoGame = listaOpcoes;
      _revelarPokemonDoGame = false;
      _resultadoTextoGame = "Quem é esse Pokémon?";
    });
  }

  void _verificarRespostaGame(String nomeSelecionado) {
    if (_revelarPokemonDoGame) return;

    setState(() {
      _revelarPokemonDoGame = true;
      if (nomeSelecionado == _pokemonDoGame!.nome.toUpperCase()) {
        _resultadoTextoGame = "🎉 CORRETO! É o ${_pokemonDoGame!.nome.toUpperCase()}!";
      } else {
        _resultadoTextoGame = "❌ ERRADO! Era o ${_pokemonDoGame!.nome.toUpperCase()}!";
      }
    });
  }

  void _fazerLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
  }

  void _escanearRegiaoGps() async {
    setState(() {
      _procurandoGps = true;
      _coordenadasTexto = "Obtendo sinal do GPS...";
    });

    double latitude = -22.8609; 
    double longitude = -47.1429;

    try {
      LocationPermission permissao = await Geolocator.checkPermission();
      if (permissao == LocationPermission.denied) {
        permissao = await Geolocator.requestPermission();
      }
      
      if (permissao != LocationPermission.denied && permissao != LocationPermission.deniedForever) {
        Position posicao = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 4), 
        );
        latitude = posicao.latitude;
        longitude = posicao.longitude;
      }
    } catch (e) {
      // Usando coordenadas simuladas se o hardware falhar
    }

    var random = Random();
    List<Pokemon> sorteados = [];
    if (_todosPokemonsDaApi.isNotEmpty) {
      for (int i = 0; i < 3; i++) {
        int indexAleatorio = random.nextInt(_todosPokemonsDaApi.length);
        sorteados.add(_todosPokemonsDaApi[indexAleatorio]);
      }
    }

    setState(() {
      _coordenadasTexto = "Lat: ${latitude.toStringAsFixed(4)} | Lng: ${longitude.toStringAsFixed(4)} (Simulado)";
      _pokemonsNoRadar = sorteados;
      _procurandoGps = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> abas = [
      RadarTab(
        procurandoGps: _procurandoGps,
        coordenadasTexto: _coordenadasTexto,
        pokemonsNoRadar: _pokemonsNoRadar,
        idsCapturados: _idsCapturados, // Passando a lista de capturados para a aba do Radar
        onEscanear: _escanearRegiaoGps,
        onInteragir: _gerenciarInteracao, // Passando o gerenciador de cliques
      ),
      GameTab(
        pokemonDoGame: _pokemonDoGame,
        opcionesDoGame: _opcoesDoGame,
        revelarPokemonDoGame: _revelarPokemonDoGame,
        resultadoTextoGame: _resultadoTextoGame,
        onSelecionarResposta: _verificarRespostaGame,
        onProximoRound: _gerarNovoRoundGame,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFEDF2F7),
      appBar: AppBar(
        title: Text(
          _abaAtual == 0 ? "MONVERSE GO" : "MINI-GAME",
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E293B),
        leading: IconButton(
          icon: const Icon(Icons.logout, color: Colors.redAccent, size: 26),
          tooltip: "Sair do Aplicativo",
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text("Sair do Monverse?"),
                content: const Text("Você precisará fazer login novamente para jogar."),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCELAR")),
                  TextButton(onPressed: _fazerLogout, child: const Text("SAIR", style: TextStyle(color: Colors.red))),
                ],
              ),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu_book, color: Colors.redAccent, size: 26),
            tooltip: "Abrir Pokédex",
            onPressed: () async {
              // Quando abrir a Pokédex e voltar, também atualiza o status
              await Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => PokedexPage(todosPokemons: _todosPokemonsDaApi))
              );
              _atualizarListaDeCapturados();
            },
          ),
          IconButton(
            icon: const Icon(Icons.backpack, color: Colors.amber, size: 28),
            tooltip: "Mochila / Favoritos",
            onPressed: () async {
              // Quando abrir a Mochila e voltar, atualiza caso tenha libertado algum Pokémon
              await Navigator.push(context, MaterialPageRoute(builder: (context) => const FavoritosPage()));
              _atualizarListaDeCapturados();
            },
          )
        ],
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1E293B)))
          : abas[_abaAtual],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _abaAtual,
        onTap: (index) {
          setState(() {
            _abaAtual = index;
          });
        },
        backgroundColor: const Color(0xFF1E293B),
        selectedItemColor: Colors.amber,
        unselectedItemColor: Colors.white60,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold), 
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.radar),
            label: "Caçar Radar",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.videogame_asset),
            label: "Adivinhar",
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 4. CLASSE DA POKÉDEX
// ==========================================
class PokedexPage extends StatefulWidget {
  final List<Pokemon> todosPokemons;
  const PokedexPage({super.key, required this.todosPokemons});

  @override
  State<PokedexPage> createState() => _PokedexPageState();
}

class _PokedexPageState extends State<PokedexPage> {
  final ApiService _apiService = ApiService();
  List<int> _idsCapturados = [];
  bool _carregandoCapturados = true;

  @override
  void initState() {
    super.initState();
    _buscarIdsCapturados();
  }

  void _buscarIdsCapturados() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId != null) {
      final capturados = await _apiService.getFavoritos(userId);
      setState(() {
        _idsCapturados = capturados.map((p) => p.idPokeApi).toList();
        _carregandoCapturados = false;
      });
    } else {
      setState(() => _carregandoCapturados = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        title: const Text("Pokédex Oficial", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFFDC2626),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _carregandoCapturados
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFDC2626)))
          : GridView.builder(
              padding: const EdgeInsets.all(15),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.85,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: widget.todosPokemons.length,
              itemBuilder: (context, index) {
                final pokemon = widget.todosPokemons[index];
                final bool jaCapturado = _idsCapturados.contains(pokemon.idPokeApi);

                return GestureDetector(
                  onTap: () {
                    if (jaCapturado) {
                      _mostrarInfoDialog(pokemon);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("❓ Pokémon desconhecido! Encontre-o no radar para registrar."),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    }
                  },
                  child: Card(
                    elevation: jaCapturado ? 4 : 1,
                    color: jaCapturado ? Colors.white : Colors.grey[300],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.network(
                          pokemon.imagem,
                          height: 65,
                          color: jaCapturado ? null : Colors.black.withOpacity(0.65),
                          colorBlendMode: jaCapturado ? null : BlendMode.srcIn,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          jaCapturado ? pokemon.nome.toUpperCase() : "???",
                          style: TextStyle(
                            fontSize: 11, 
                            fontWeight: FontWeight.bold,
                            color: jaCapturado ? Colors.black : Colors.grey[600],
                          ),
                        ),
                        Text(
                          "#${pokemon.idPokeApi.toString().padLeft(3, '0')}",
                          style: const TextStyle(fontSize: 9, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _mostrarInfoDialog(Pokemon pokemon) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Image.network(pokemon.imagem, height: 50),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                pokemon.nome.toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Nº na Pokédex: #${pokemon.idPokeApi.toString().padLeft(3, '0')}", style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text(
              "Status de Registro:\nDesbloqueado com sucesso na base de dados do Monverse. Este Pokémon já foi avistado e capturado por você na sua região!",
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("FECHAR", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}