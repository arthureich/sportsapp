import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/team_model.dart';
import 'package:flutter/foundation.dart';

class TeamService {
  final CollectionReference _teamsCollection =
      FirebaseFirestore.instance.collection('equipes');

  Future<void> addTeam(Team team) async {
    try {
      await _teamsCollection.add(team.toJson());
    } catch (e) {
      debugPrint("Erro ao adicionar equipe: $e");
      rethrow; 
    }
  }

  Stream<List<Team>> getTeams() {
    return _teamsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Team.fromSnapshot(doc)).toList();
    });
  }
  Future<void> joinTeam(String teamId, String userId) async {
     try {
       await _teamsCollection.doc(teamId).update({
         'memberIds': FieldValue.arrayUnion([userId]) 
       });
     } catch (e) {
       debugPrint("Erro ao entrar na equipe: $e");
       rethrow;
     }
   }

   Future<void> leaveTeam(String teamId, String userId) async {
     try {
       await _teamsCollection.doc(teamId).update({
         'memberIds': FieldValue.arrayRemove([userId]) 
       });
     } catch (e) {
       debugPrint("Erro ao sair da equipe: $e");
       rethrow;
     }
   }

   Stream<Team?> getTeamStream(String teamId) {
     return _teamsCollection.doc(teamId).snapshots().map((snapshot) {
       if (snapshot.exists) {
         return Team.fromSnapshot(snapshot);
       }
       return null; 
     }).handleError((error) {
       debugPrint("Erro ao ouvir equipe $teamId: $error");
       return null;
     });
   }
}
