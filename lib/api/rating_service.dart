// lib/api/rating_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/rating_model.dart';

class RatingService {
  final CollectionReference _ratingsCollection =
      FirebaseFirestore.instance.collection('avaliacoes');

  // Adiciona uma nova avaliação (ou atualiza uma existente)
  // Usamos eventId-raterId-ratedId como ID para evitar duplicatas
  Future<void> addOrUpdateRating(Rating rating) async {
    try {
      // Cria um ID único para garantir que um usuário só avalie outro uma vez por evento
      final docId = '${rating.eventId}_${rating.raterUserId}_${rating.ratedUserId}';
      await _ratingsCollection.doc(docId).set(rating.toJson());
    } catch (e) {
      if (kDebugMode) {
        print("Erro ao salvar avaliação: $e");
      }
      rethrow;
    }
  }

  // Busca todas as avaliações que um usuário RECEBEU
  Future<List<Rating>> getRatingsForUser(String ratedUserId) async {
    try {
      final querySnapshot = await _ratingsCollection
          .where('ratedUserId', isEqualTo: ratedUserId)
          .get();
      
      if (querySnapshot.docs.isEmpty) {
        return [];
      }
      
      return querySnapshot.docs
          .map((doc) => Rating.fromSnapshot(doc))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print("Erro ao buscar avaliações: $e");
      }
      return [];
    }
  }

  // Verifica se o usuário logado já avaliou um participante específico neste evento
  Future<bool> hasUserAlreadyRated(String eventId, String raterUserId, String ratedUserId) async {
     final docId = '${eventId}_${raterUserId}_$ratedUserId';
     final doc = await _ratingsCollection.doc(docId).get();
     return doc.exists;
  }
}