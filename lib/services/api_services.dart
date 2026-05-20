import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; 
import '../models/pokemon_model.dart';
import '../models/usuario_model.dart';

class ApiService {
  // Ajuste automático entre Web e Android
  final String urlLocal = kIsWeb ? "http://localhost:3000" : "http://10.0.2.2:3000";
  final String urlPokeApi = "https://pokeapi.co/api/v2";

  // --- POKEAPI ---
  Future<List<Pokemon>> buscarTodosPokemons() async {
    final response = await http.get(Uri.parse("$urlPokeApi/pokemon?limit=151"));

    if (response.statusCode == 200) {
      List data = json.decode(response.body)['results'];
      return data.asMap().entries.map((entry) {
        int index = entry.key + 1;
        return Pokemon(
          idPokeApi: index,
          nome: entry.value['name'],
          imagem: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$index.png",
        );
      }).toList();
    } else {
      throw Exception("Erro ao buscar Pokémons");
    }
  }

  // --- JSON SERVER (MECÂNICAS DO JOGO) ---

  // Login do Jogador
  Future<Usuario?> login(String email, String password) async {
    final response = await http.get(Uri.parse("$urlLocal/usuarios"));

    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      try {
        final usuario = data.firstWhere(
          (user) =>
              user['email'].toString().trim() == email.trim() &&
              user['password'].toString().trim() == password.trim(),
        );
        return Usuario.fromJson(usuario);
      } catch (e) {
        print("ERRO LOGIN: Jogador não encontrado");
        return null;
      }
    }
    return null;
  }

  // Buscar Pokémons Capturados do Jogador (Filtro inteligente via Dart)
  Future<List<Pokemon>> getFavoritos(String userId) async {
    // Agora batemos na rota /capturados
    final response = await http.get(Uri.parse("$urlLocal/capturados"));

    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      
      // Filtra os pokémons capturados pelo jogador logado
      final capturadosDoUsuario = data.where((item) => 
        item['userId'].toString().trim() == userId.trim()
      ).toList();

      return capturadosDoUsuario.map((json) => Pokemon.fromJson(json)).toList();
    }
    return [];
  }

  // Capturar um Pokémon (POST)
  Future<bool> adicionarFavorito(Pokemon pokemon, String userId) async {
    final response = await http.post(
      Uri.parse("$urlLocal/capturados"),
      headers: {"Content-Type": "application/json"},
      // Salvando com os status de jogo gerados aleatoriamente!
      body: json.encode(pokemon.toJsonDefinitivo(userId)),
    );
    return response.statusCode == 201;
  }

  // Libertar um Pokémon (DELETE)
  Future<bool> removerFavorito(String idDb) async {
    final response = await http.delete(Uri.parse("$urlLocal/capturados/$idDb"));
    return response.statusCode == 200 || response.statusCode == 204;
  }

  // --- CADASTRAR NOVO JOGADOR (POST) ---
  Future<bool> cadastrarUsuario(String nome, String email, String password) async {
    try {
      // Primeiro, verificamos se o e-mail já existe no banco
      final verificar = await http.get(Uri.parse("$urlLocal/usuarios"));
      if (verificar.statusCode == 200) {
        List dados = json.decode(verificar.body);
        bool jaExiste = dados.any((u) => u['email'].toString().trim() == email.trim());
        if (jaExiste) {
          print("ERRO CADASTRO: E-mail já cadastrado.");
          return false; 
        }
      }

      // Se não existe, faz o cadastro
      final response = await http.post(
        Uri.parse("$urlLocal/usuarios"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "nome": nome.trim(),
          "email": email.trim(),
          "password": password.trim(),
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      print("ERRO NO CADASTRO: $e");
      return false;
    }
  }

}