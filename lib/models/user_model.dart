import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String nome;
  final String email;
  final String fotoUrl;
  final String bio;
  final double? scoreEsportividade;
  final List<String> esportesInteresse;
  final List<String> fcmTokens;
  final String genero;

  UserModel({
    required this.id,
    required this.nome,
    required this.email,
    required this.fotoUrl,
    required this.bio,
    required this.scoreEsportividade,
    required this.esportesInteresse,
    required this.fcmTokens,
    required this.genero,
  });

  factory UserModel.fromSnapshot(DocumentSnapshot snap) {
    var data = snap.data() as Map<String, dynamic>;
    
    return UserModel(
      id: snap.id,
      nome: data['nome'] ?? '', 
      email: data['email'] ?? '',
      fotoUrl: data['fotoUrl'] ?? '',
      bio: data['bio'] ?? '',
      scoreEsportividade: (data['scoreEsportividade'] as num?)?.toDouble(),
      esportesInteresse: List<String>.from(data['esportesInteresse'] ?? []),
      fcmTokens: List<String>.from(data['fcmTokens'] ?? []),
      genero: data['genero'] ?? 'boy',
    );
  }
}