import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:geolocator/geolocator.dart';
import '../models/event_model.dart';
import '../models/user_model.dart';

class EventService {
  final CollectionReference _eventsCollection =
      FirebaseFirestore.instance.collection('eventos');

  final CollectionReference _usersCollection = FirebaseFirestore.instance.collection('usuarios');

  Stream<List<Event>> getNearbyEvents(Position position, double radiusInKm) {
    
    final geoCollection = GeoCollectionReference(_eventsCollection);
    final center = GeoFirePoint(GeoPoint(position.latitude, position.longitude));

    return geoCollection.subscribeWithin(
      center: center, 
      radiusInKm: radiusInKm,
      field: 'geo',
      geopointFrom: (data) {
         // Converte o 'data' (Object?) para um Map
         final docData = data as Map<String, dynamic>?;
         if (docData == null) {
           throw Exception('Dados do documento estão nulos.');
         }
         final geoData = docData['geo'] as Map<String, dynamic>?; 
         if (geoData == null) {
           throw Exception('Documento não contém o campo "geo".');
         }
         final geoPoint = geoData['geopoint'] as GeoPoint?;
         if (geoPoint == null) {
            throw Exception('O campo "geo" não contém um "geopoint".');
         }
         return geoPoint;
      },
      strictMode: true
    ).map((snapshots) {
      final now = DateTime.now();
      List<Event> events = [];

      for (final doc in snapshots) {
        try {
          // Filtra eventos futuros AQUI (pós-query)
          final event = Event.fromSnapshot(doc);
          if (event.dateTime.isAfter(now)) {
            events.add(event);
          }
        } catch (e) {
          debugPrint("Erro ao converter evento ${doc.id} na geoquery: $e");
        }
      }
      
      events.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      return events;
    });
  }

  Stream<List<Event>> getEvents() {
    return _eventsCollection
        .where('dateTime', isGreaterThanOrEqualTo: Timestamp.now()) 
        .orderBy('dateTime', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Event.fromSnapshot(doc)).toList();
    });
  }
  
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
  }

  Future<void> joinEvent(String eventId, LocalUser user) async {
    try {
      await _eventsCollection.doc(eventId).update({
        'participants': FieldValue.arrayUnion([user.toJson()]) 
      });
    } catch (e) {
      debugPrint("Erro ao entrar no evento: $e");
      rethrow;
    }
  }

  Future<void> leaveEvent(String eventId, LocalUser user) async {
    try {
      await _eventsCollection.doc(eventId).update({
        'participants': FieldValue.arrayRemove([user.toJson()]) 
      });
    } catch (e) {
      debugPrint("Erro ao sair do evento: $e");
      rethrow;
    }
  }

Future<UserModel> getUserData(String userId) async {
      final userDoc = await _usersCollection.doc(userId).get();
      if (!userDoc.exists) {
        throw Exception('Usuário não encontrado.');
      }
      return UserModel.fromSnapshot(userDoc);
  }

  Future<List<UserModel>> getUsersData(List<String> userIds) async {
      if (userIds.isEmpty) {
        return [];
      }
      final userSnapshots = await _usersCollection.where(FieldPath.documentId, whereIn: userIds).get();
      return userSnapshots.docs.map((doc) => UserModel.fromSnapshot(doc)).toList();
  }
}