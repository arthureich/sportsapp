import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:flutter/foundation.dart'; 

T _getOrDefault<T>(Map<String, dynamic> data, String key, T defaultValue) {
  try {
    if (data.containsKey(key) && data[key] is T) {
      return data[key];
    }
  } catch (e) {
    debugPrint("Erro ao converter campo '$key': $e");
  }
  return defaultValue;
}

class LocalUser {
  final String id;
  final String name;
  final String avatarUrl;

  LocalUser({required this.id, required this.name, required this.avatarUrl});

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'avatarUrl': avatarUrl,
      };

  factory LocalUser.fromJson(Map<String, dynamic>? data) {
    if (data == null) {
      throw const FormatException("Erro: dados do LocalUser nulos.");
    }
    return LocalUser(
      id: data['id'] ?? '',
      name: data['name'] ?? 'Nome Indisponível',
      avatarUrl: data['avatarUrl'] ?? '',
    );
  }
}

class Location {
  final String name;
  final String address;
  final GeoPoint coordinates;

  Location({required this.name, required this.address, required this.coordinates});

  Map<String, dynamic> toJson() => {
        'name': name,
        'address': address,
        'coordinates': coordinates,
      };

  factory Location.fromJson(Map<String, dynamic>? data) {
    if (data == null) return Location(name: 'Localização Inválida', address: '', coordinates: const GeoPoint(0,0));
    return Location(
      name: _getOrDefault(data, 'name', 'Localização Indisponível'),
      address: _getOrDefault(data, 'address', ''),
      // 3. Lê o GeoPoint do Firestore
      coordinates: _getOrDefault(data, 'coordinates', const GeoPoint(0, 0)),
    );
  }
}

class Event {
  final String id;
  final String title;
  final String description;
  final String sport;
  final DateTime dateTime;
  final Location location;
  final String imageUrl;
  final LocalUser organizer;
  final List<LocalUser> participants;
  final int maxParticipants;
  final String skillLevel; 
  final bool isPrivate;    
  final List<LocalUser> pendingParticipants;
  

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.sport,
    required this.dateTime,
    required this.location,
    required this.imageUrl,
    required this.organizer,
    required this.participants,
    required this.maxParticipants,
    required this.skillLevel,
    required this.isPrivate,
    required this.pendingParticipants,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'sport': sport,
        'dateTime': Timestamp.fromDate(dateTime),
        'location': location.toJson(),
        'imageUrl': imageUrl,
        'organizer': organizer.toJson(),
        'participants': participants.map((p) => p.toJson()).toList(),
        'maxParticipants': maxParticipants,
        'skillLevel': skillLevel,
        'isPrivate': isPrivate,
        'pendingParticipants': pendingParticipants.map((p) => p.toJson()).toList(),
        'geo': GeoFirePoint(location.coordinates).data,
      };

  factory Event.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>?; 

    if (data == null) {
      throw "Documento ${snapshot.id} não contém dados!";
    }

    try {
      // Função helper para converter listas de participantes
      List<LocalUser> _parseParticipants(dynamic listData) {
        if (listData is List) {
          return listData
              .map((p) => LocalUser.fromJson(p as Map<String, dynamic>))
              .toList();
        }
        return [];
      }

      final participantsList = _parseParticipants(data['participants']);
      final pendingList = _parseParticipants(data['pendingParticipants']);

      DateTime dateTime;
      if (data['dateTime'] is Timestamp) {
        dateTime = (data['dateTime'] as Timestamp).toDate();
      } else {
        dateTime = DateTime.now();
      }
      
      return Event(
        id: snapshot.id,
        title: _getOrDefault(data, 'title', 'Evento Sem Título'),
        description: _getOrDefault(data, 'description', ''),
        sport: _getOrDefault(data, 'sport', 'Esporte Indefinido'),
        dateTime: dateTime,
        location: Location.fromJson(data['location'] as Map<String, dynamic>?),
        imageUrl: _getOrDefault(data, 'imageUrl', ''),
        organizer: LocalUser.fromJson(data['organizer'] as Map<String, dynamic>?),
        participants: participantsList,
        maxParticipants: _getOrDefault(data, 'maxParticipants', 0),
        skillLevel: _getOrDefault(data, 'skillLevel', 'Todos'), 
        isPrivate: _getOrDefault(data, 'isPrivate', false),     
        pendingParticipants: pendingList,
      );
    } catch (e) {
      debugPrint('ERRO CRÍTICO ao converter o documento ${snapshot.id}: $e');
      rethrow;
    }
  }
}