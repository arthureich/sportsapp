import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/event_model.dart';
import '../models/user_model.dart';

class EventService {
  // Referência para a coleção 'eventos' no Firestore.
  final CollectionReference _eventsCollection =
      FirebaseFirestore.instance.collection('eventos');

  final CollectionReference _usersCollection = FirebaseFirestore.instance.collection('usuarios');
  Stream<List<Event>> getEvents() {
    return _eventsCollection.orderBy('dateTime', descending: false).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Event.fromSnapshot(doc)).toList();
    });
  }
  // Retorna um Stream que "escuta" as mudanças em um evento específico.
  Stream<DocumentSnapshot> getEventStream(String eventId) {
    return _eventsCollection.doc(eventId).snapshots();
  }
  Future<void> addEvent(Event event) async {
    try {
      await _eventsCollection.add(event.toJson());
    } catch (e) {
      if (kDebugMode) {
        print("Erro ao adicionar evento: $e");
      }
      final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("Usuário não autenticado para criar um evento.");
    }
     await _eventsCollection.add(event.toJson());
  }
  Future<UserModel> getUserData(String userId) async {
    final userDoc = await _usersCollection.doc(userId).get();
    if (!userDoc.exists) {
      throw Exception('Usuário não encontrado.');
    }
    return UserModel.fromSnapshot(userDoc);
    }
  }

  Future<List<UserModel>> getUsersData(List<String> userIds) async {
    if (userIds.isEmpty) {
      return [];
    }
    final userSnapshots = await _usersCollection.where(FieldPath.documentId, whereIn: userIds).get();
    return userSnapshots.docs.map((doc) => UserModel.fromSnapshot(doc)).toList();
  }
}