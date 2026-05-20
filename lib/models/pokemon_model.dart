import 'dart:math';

class Pokemon {
  final String? idDb; // ID gerado pelo seu json-server
  final int idPokeApi; // ID oficial da PokeAPI
  final String nome;
  final String imagem;
  
  // --- ATRIBUTOS DE JOGO ---
  int level;
  int hpMax;
  int hpAtual;
  int ataque;
  int defesa;

  Pokemon({
    this.idDb,
    required this.idPokeApi,
    required this.nome,
    required this.imagem,
    this.level = 1,
    this.hpMax = 20,
    this.hpAtual = 20,
    this.ataque = 10,
    this.defesa = 10,
  });

  // Converte o JSON do banco ou da API para o objeto Pokémon no Flutter
  factory Pokemon.fromJson(Map<String, dynamic> json) {
    int apiId;
    if (json['pokemonId'] != null) {
      apiId = int.tryParse(json['pokemonId'].toString()) ?? 0;
    } else {
      apiId = json['id'] is int ? json['id'] : 0;
    }

    return Pokemon(
      idDb: (json['id'] is String) ? json['id'] : null,
      idPokeApi: apiId,
      nome: json['nome'] ?? json['name'] ?? 'Desconhecido',
      imagem: json['imagem'] ?? "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$apiId.png",
      level: json['level'] ?? 1,
      hpMax: json['hpMax'] ?? 20,
      hpAtual: json['hpAtual'] ?? 20,
      ataque: json['ataque'] ?? 10,
      defesa: json['defesa'] ?? 10,
    );
  }

  // Prepara os dados para salvar no banco gerando status aleatórios de RPG!
  Map<String, dynamic> toJsonDefinitivo(String userId) {
    var random = Random();
    
    // Sorteia um level de 1 a 15 para o Pokémon selvagem
    int lvl = random.nextInt(15) + 1; 
    
    // Calcula os status baseados no level sorteado (quanto maior o level, mais forte)
    int hp = 30 + (lvl * 2) + random.nextInt(10);
    int atk = 10 + (lvl * 1) + random.nextInt(5);
    int def = 5 + (lvl * 1) + random.nextInt(5);

    return {
      "userId": userId,
      "pokemonId": idPokeApi,
      "nome": nome,
      "imagem": imagem,
      "level": lvl,
      "hpMax": hp,
      "hpAtual": hp,
      "ataque": atk,
      "defesa": def,
    };
  }
}