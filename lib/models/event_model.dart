import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // Para o debugPrint

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

  Location({required this.name, required this.address});

  Map<String, dynamic> toJson() => {
        'name': name,
        'address': address,
      };

  factory Location.fromJson(Map<String, dynamic>? data) {
    if (data == null) {
      throw const FormatException("Erro: dados da Localização nulos.");
    }
    return Location(
      name: data['name'] ?? 'Localização Indisponível',
      address: data['address'] ?? '',
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
      };

  // **MÉTODO ATUALIZADO E MAIS SEGURO**
  factory Event.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>?; // Permite que os dados sejam nulos

    // Verifica se os dados existem antes de tentar aceder-lhes
    if (data == null) {
      throw "Documento ${snapshot.id} não contém dados!";
    }

    try {
      // Converte a lista de participantes de forma segura
      final participantsData = data['participants'] as List<dynamic>? ?? [];
      final participantsList = participantsData
          .map((p) => LocalUser.fromJson(p as Map<String, dynamic>))
          .toList();
      
      // Converte o timestamp de forma segura, usando uma data padrão em caso de erro
      final timestamp = data['dateTime'] as Timestamp?;
      final dateTime = timestamp?.toDate() ?? DateTime.now();

      return Event(
        id: snapshot.id,
        title: data['title'] ?? 'Evento Sem Título',
        description: data['description'] ?? '',
        sport: data['sport'] ?? 'Desporto Indefinido',
        dateTime: dateTime,
        location: Location.fromJson(data['location'] as Map<String, dynamic>?),
        imageUrl: data['imageUrl'] ?? '',
        organizer: LocalUser.fromJson(data['organizer'] as Map<String, dynamic>?),
        participants: participantsList,
        maxParticipants: data['maxParticipants'] ?? 0,
      );
    } catch (e) {
      // Se ocorrer um erro durante a conversão de qualquer campo,
      // esta mensagem detalhada será impressa na consola de depuração.
      debugPrint('Erro ao converter o documento ${snapshot.id}: $e');
      debugPrint('Dados do documento: $data');
      // Lança o erro novamente para que o StreamBuilder possa apanhá-lo
      rethrow;
    }
  }
}