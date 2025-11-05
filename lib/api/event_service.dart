import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
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

  Stream<List<Event>> getUpcomingEvents() { 
    return _eventsCollection
        .where('dateTime', isGreaterThanOrEqualTo: Timestamp.now())
        .orderBy('dateTime', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Event.fromSnapshot(doc)).toList();
    });
  }

  Stream<List<Event>> getAllEvents() {
    return _eventsCollection
        .orderBy('dateTime', descending: true) 
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
        print("Erro CRÍTICO ao adicionar evento: $e");
      }
      rethrow; 
    }
  }

  Future<void> updateEvent(String eventId, Map<String, dynamic> data) async {
    try {
      await _eventsCollection.doc(eventId).update(data);
    } catch (e) {
      debugPrint("Erro ao atualizar evento: $e");
      rethrow;
    }
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      await _eventsCollection.doc(eventId).delete();
    } catch (e) {
      debugPrint("Erro ao deletar evento: $e");
      rethrow;
    }
  }

  Future<void> requestToJoinEvent(String eventId, LocalUser user) async {
    try {
      await _eventsCollection.doc(eventId).update({
        'pendingParticipants': FieldValue.arrayUnion([user.toJson()])
      });
    } catch (e) {
      debugPrint("Erro ao solicitar entrada: $e");
      rethrow;
    }
  }

  Future<void> approveParticipant(String eventId, LocalUser userToApprove) async {
    try {
      await _eventsCollection.doc(eventId).update({
        'pendingParticipants': FieldValue.arrayRemove([userToApprove.toJson()]),
        'participants': FieldValue.arrayUnion([userToApprove.toJson()])
      });
    } catch (e) {
      debugPrint("Erro ao aprovar participante: $e");
      rethrow;
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

  Stream<List<Event>> getUpcomingEventsForLocation(String locationName) {
    return _eventsCollection
        .where('location.name', isEqualTo: locationName)
        .where('dateTime', isGreaterThanOrEqualTo: Timestamp.now())
        .orderBy('dateTime')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Event.fromSnapshot(doc)).toList();
    });
  }
}