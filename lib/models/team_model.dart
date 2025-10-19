import 'package:cloud_firestore/cloud_firestore.dart';

class Team {
  final String id;
  final String name;
  final String sport;
  final String crestUrl;
  final String description;
  final int currentMembers;
  final int maxMembers;
  final bool isPublic;
  // Poderia adicionar uma lista de IDs de membros aqui no futuro
  // final List<String> memberIds; 

  Team({
    required this.id,
    required this.name,
    required this.sport,
    required this.crestUrl,
    required this.description,
    required this.currentMembers,
    required this.maxMembers,
    required this.isPublic,
  });

  // Converte o objeto Team para um mapa que pode ser guardado no Firestore
  Map<String, dynamic> toJson() => {
        'name': name,
        'sport': sport,
        'crestUrl': crestUrl,
        'description': description,
        'currentMembers': currentMembers,
        'maxMembers': maxMembers,
        'isPublic': isPublic,
      };

  // Cria uma instância de Team a partir de um documento do Firestore
  factory Team.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>? ?? {};

    return Team(
      id: snapshot.id,
      name: data['name'] ?? 'Equipe Sem Nome',
      sport: data['sport'] ?? 'Esporte não definido',
      crestUrl: data['crestUrl'] ?? '',
      description: data['description'] ?? '',
      currentMembers: data['currentMembers'] ?? 1,
      maxMembers: data['maxMembers'] ?? 0,
      isPublic: data['isPublic'] ?? true,
    );
  }
}