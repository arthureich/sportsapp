import 'package:cloud_firestore/cloud_firestore.dart';

class Rating {
  final String id;
  final String eventId;       
  final String raterUserId;   
  final String ratedUserId;   
  final double score;        
  final String? comment;      
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

  Map<String, dynamic> toJson() => {
        'eventId': eventId,
        'raterUserId': raterUserId,
        'ratedUserId': ratedUserId,
        'score': score,
        'comment': comment,
        'createdAt': createdAt,
      };

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