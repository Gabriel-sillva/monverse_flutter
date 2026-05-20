class Usuario {
  final String id;
  final String nome;
  final String email;
  final String password;
  final String role; // 'admin' ou 'user'

  Usuario({
    required this.id,
    required this.nome,
    required this.email,
    required this.password,
    required this.role,
  });

  // Transforma o JSON que vem do Render em Objeto Dart
  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'].toString(),
      nome: json['nome'],
      email: json['email'],
      password: json['password'],
      role: json['role'] ?? 'user',
    );
  }

  // Transforma o Objeto em JSON para enviar pro servidor (PUT/POST)
  Map<String, dynamic> toJson() {
    return {
      "nome": nome,
      "email": email,
      "password": password,
      "role": role,
    };
  }
}