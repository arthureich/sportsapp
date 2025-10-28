import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/team_model.dart';
import 'package:flutter/foundation.dart';

class TeamService {
  // Referência para a coleção 'equipes' no Firestore
  final CollectionReference _teamsCollection =
      FirebaseFirestore.instance.collection('equipes');

  // Adiciona uma nova equipe ao Firestore
  Future<void> addTeam(Team team) async {
    try {
      await _teamsCollection.add(team.toJson());
    } catch (e) {
      debugPrint("Erro ao adicionar equipe: $e");
      rethrow; 
    }
  }

  // Retorna um Stream com a lista de todas as equipes
  Stream<List<Team>> getTeams() {
    return _teamsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Team.fromSnapshot(doc)).toList();
    });
  }
  Future<void> joinTeam(String teamId, String userId) async {
     try {
       await _teamsCollection.doc(teamId).update({
         'memberIds': FieldValue.arrayUnion([userId]) // Adiciona o ID do usuário ao array
       });
     } catch (e) {
       debugPrint("Erro ao entrar na equipe: $e");
       rethrow;
     }
   }

   // --- NOVO MÉTODO PARA SAIR DA EQUIPE ---
   Future<void> leaveTeam(String teamId, String userId) async {
     try {
       await _teamsCollection.doc(teamId).update({
         'memberIds': FieldValue.arrayRemove([userId]) // Remove o ID do usuário do array
       });
     } catch (e) {
       debugPrint("Erro ao sair da equipe: $e");
       rethrow;
     }
   }

   // --- NOVO MÉTODO PARA BUSCAR UMA EQUIPE ESPECÍFICA (Stream) ---
   Stream<Team?> getTeamStream(String teamId) {
     return _teamsCollection.doc(teamId).snapshots().map((snapshot) {
       if (snapshot.exists) {
         return Team.fromSnapshot(snapshot);
       }
       return null; // Retorna null se a equipe não for encontrada
     }).handleError((error) {
       debugPrint("Erro ao ouvir equipe $teamId: $error");
       return null;
     });
   }
}
