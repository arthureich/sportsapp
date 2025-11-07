import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReportService {
  final CollectionReference _reportsCollection =
      FirebaseFirestore.instance.collection('reports');
  
  Future<void> submitReport({
    required String type, 
    required String description,
    String? reportedUserId,
    String? reportedLocationName,
    String? reportedEventId,
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception('Usuário não autenticado.');
    }
    
    await _reportsCollection.add({
      'reporterUserId': currentUser.uid,
      'reporterEmail': currentUser.email,
      'type': type,
      'description': description,
      'reportedUserId': reportedUserId,
      'reportedLocationName': reportedLocationName,
      'reportedEventId': reportedEventId,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'pending', 
    });
  }
}