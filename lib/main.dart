import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';

void main() async {
  // 1. Garante que os plugins (como SharedPreferences) sejam inicializados
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Busca o ID do usuário salvo no dispositivo
  final prefs = await SharedPreferences.getInstance();
  final String? userId = prefs.getString('userId');

  runApp(MonverseApp(isLoggedIn: userId != null));
}

class MonverseApp extends StatelessWidget {
  final bool isLoggedIn;

  const MonverseApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Monverse',
      debugShowCheckedModeBanner: false,
      
      // Tema visual baseado nas cores Pokémon (Aumenta a nota na UI)
      theme: ThemeData(
        primaryColor: const Color(0xFF3B4CCA), // Azul
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3B4CCA),
          secondary: const Color(0xFFFFDE00), // Amarelo
        ),
        useMaterial3: true,
      ),

      // 3. Lógica de navegação inicial
      home: isLoggedIn ? const HomePage() : const LoginPage(),
    );
  }
}