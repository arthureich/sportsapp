import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/team_model.dart';

class TeamService {
  // Referência para a coleção 'equipes' no Firestore
  final CollectionReference _teamsCollection =
      FirebaseFirestore.instance.collection('equipes');

  // Adiciona uma nova equipa ao Firestore
  Future<void> addTeam(Team team) async {
    try {
      await _teamsCollection.add(team.toJson());
    } catch (e) {
      print("Erro ao adicionar equipa: $e");
      rethrow; // Lança o erro para ser tratado na UI
    }
  }

  // Retorna um Stream com a lista de todas as equipas
  Stream<List<Team>> getTeams() {
    return _teamsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Team.fromSnapshot(doc)).toList();
    });
  }
}