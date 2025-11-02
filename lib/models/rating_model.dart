import 'package:cloud_firestore/cloud_firestore.dart';

class Rating {
  final String id;
  final String eventId;       // ID do evento avaliado
  final String raterUserId;   // ID de quem deu a nota
  final String ratedUserId;   // ID de quem recebeu a nota
  final double score;         // A nota (ex: 1 a 5)
  final String? comment;       // Comentário opcional
  final Timestamp createdAt;

  Rating({
    required this.id,
    required this.eventId,
    required this.raterUserId,
    required this.ratedUserId,
    required this.score,
    this.comment,
    required this.createdAt,
  });

  // Converte para JSON para salvar no Firestore
  Map<String, dynamic> toJson() => {
        'eventId': eventId,
        'raterUserId': raterUserId,
        'ratedUserId': ratedUserId,
        'score': score,
        'comment': comment,
        'createdAt': createdAt,
      };

  // Cria a partir de um snapshot do Firestore
  factory Rating.fromSnapshot(DocumentSnapshot snap) {
    final data = snap.data() as Map<String, dynamic>;
    return Rating(
      id: snap.id,
      eventId: data['eventId'],
      raterUserId: data['raterUserId'],
      ratedUserId: data['ratedUserId'],
      score: (data['score'] as num).toDouble(),
      comment: data['comment'],
      createdAt: data['createdAt'],
    );
  }
}