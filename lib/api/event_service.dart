import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/event_model.dart';

class EventService {
  // Referência para a coleção 'eventos' no Firestore.
  final CollectionReference _eventsCollection =
      FirebaseFirestore.instance.collection('eventos');

  // Método para adicionar um novo evento ao Firestore.
  // Ele recebe um objeto Event, converte para JSON e o envia.
  Future<void> addEvent(Event event) async {
    try {
      await _eventsCollection.add(event.toJson());
    } catch (e) {
      if (kDebugMode) {
        print("Erro ao adicionar evento: $e");
      }
    }
  }

  // Retorna um Stream que "escuta" as mudanças na coleção de eventos.
  // Sempre que um evento for adicionado, alterado ou removido, o Stream
  // emitirá uma nova lista de eventos atualizada.
  Stream<List<Event>> getEvents() {
    return _eventsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Event.fromSnapshot(doc);
      }).toList();
    });
  }
}