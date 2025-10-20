import 'package:cloud_firestore/cloud_firestore.dart';

// Este modelo representa um utilizador individual guardado no Firestore.
// Ele é usado para converter os dados do banco de dados num objeto Dart fácil de usar.
class UserModel {
  final String id;
  final String nome;
  final String email;
  final String fotoUrl;
  final String bio;
  final double scoreEsportividade;
  final List<String> esportesInteresse;

  UserModel({
    required this.id,
    required this.nome,
    required this.email,
    required this.fotoUrl,
    required this.bio,
    required this.scoreEsportividade,
    required this.esportesInteresse,
  });

  // Factory constructor: Cria uma instância de UserModel a partir de um DocumentSnapshot do Firestore.
  // Este é o método que "traduz" os dados da nuvem para o seu aplicativo.
  factory UserModel.fromSnapshot(DocumentSnapshot snap) {
    var data = snap.data() as Map<String, dynamic>;
    
    return UserModel(
      id: snap.id,
      nome: data['nome'] ?? '', // Usa '' como valor padrão se o campo não existir
      email: data['email'] ?? '',
      fotoUrl: data['fotoUrl'] ?? '',
      bio: data['bio'] ?? '',
      scoreEsportividade: (data['scoreEsportividade'] ?? 5.0).toDouble(),
      // Converte a lista de 'dynamic' do Firestore para uma lista de 'String'
      esportesInteresse: List<String>.from(data['esportesInteresse'] ?? []),
    );
  }
}