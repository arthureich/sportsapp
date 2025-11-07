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
  final List<String> memberIds;
  final String adminId;          
  final List<String> pendingMemberIds;

  Team({
    required this.id,
    required this.name,
    required this.sport,
    required this.crestUrl,
    required this.description,
    required this.currentMembers,
    required this.maxMembers,
    required this.isPublic,
    required this.memberIds,
    required this.adminId,          
    required this.pendingMemberIds,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'sport': sport,
        'crestUrl': crestUrl,
        'description': description,
        'maxMembers': maxMembers,
        'isPublic': isPublic,
        'memberIds': memberIds,
        'adminId': adminId,          
        'pendingMemberIds': pendingMemberIds,
      };

  factory Team.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>? ?? {};

    List<String> members = [];
    if (data['memberIds'] is List) {
      members = List<String>.from(data['memberIds']);
    }

    List<String> pendingMembers = [];
    if (data['pendingMemberIds'] is List) {
      pendingMembers = List<String>.from(data['pendingMemberIds']);
    }

    return Team(
      id: snapshot.id,
      name: data['name'] ?? 'Equipe Sem Nome',
      sport: data['sport'] ?? 'Esporte não definido',
      crestUrl: data['crestUrl'] ?? '',
      description: data['description'] ?? '',
      currentMembers: members.length, 
      maxMembers: data['maxMembers'] ?? 0,
      isPublic: data['isPublic'] ?? true,
      memberIds: members, 
      adminId: data['adminId'] ?? (members.isNotEmpty ? members.first : ''), 
      pendingMemberIds: pendingMembers,
    );
  }
}