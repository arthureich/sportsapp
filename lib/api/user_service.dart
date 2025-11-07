import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart'; 

class UserService {
  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('usuarios');

Future<List<UserModel>> getUsersData(List<String> userIds) async { 
    if (userIds.isEmpty) {
      return [];
    }
    try { 
        final userSnapshots = await _usersCollection.where(FieldPath.documentId, whereIn: userIds).get();
        return userSnapshots.docs.map((doc) => UserModel.fromSnapshot(doc)).toList();
    } catch (e) {
        debugPrint("Erro ao buscar múltiplos usuários: $e");
        return []; 
    }
  }
  Future<UserModel?> getUser(String userId) async {
    try {
      final userDoc = await _usersCollection.doc(userId).get();
      if (userDoc.exists) {
        return UserModel.fromSnapshot(userDoc);
      } else {
        debugPrint('Usuário com ID $userId não encontrado no Firestore.');
        return null; 
      }
    } catch (e) {
      debugPrint("Erro ao buscar usuário: $e");
      return null; 
    }
  }

   Stream<UserModel?> getUserStream(String userId) {
     return _usersCollection.doc(userId).snapshots().map((snapshot) {
       if (snapshot.exists) {
         return UserModel.fromSnapshot(snapshot);
       }
       return null;
     }).handleError((error) {
       debugPrint("Erro ao ouvir usuário: $error");
       return null;
     });
   }


  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      await _usersCollection.doc(userId).update(data);
    } catch (e) {
      debugPrint("Erro ao atualizar usuário: $e");
      rethrow; 
    }
  }

  Future<void> updateUserScore(String userId, double newScore) async {
    try {
      final roundedScore = (newScore * 10).round() / 10;
      await _usersCollection.doc(userId).update({
        'scoreEsportividade': roundedScore,
      });
    } catch (e) {
      debugPrint("Erro ao atualizar score do usuário: $e");
      rethrow;
    }
  }
  Future<void> addFcmToken(String userId, String token) async {
    if (token.isEmpty) return; 
    try {
      await _usersCollection.doc(userId).update({
        'fcmTokens': FieldValue.arrayUnion([token])
      });
    } catch (e) {
      debugPrint("Erro ao salvar token FCM: $e");
      if (e is FirebaseException && e.code == 'not-found') {
        await _usersCollection.doc(userId).set({
          'fcmTokens': [token]
        }, SetOptions(merge: true));
      }
    }
  }

  Future<void> removeFcmToken(String userId, String token) async {
     if (token.isEmpty) return;
     try {
       await _usersCollection.doc(userId).update({
         'fcmTokens': FieldValue.arrayRemove([token])
       });
     } catch (e) {
       debugPrint("Erro ao remover token FCM: $e");
     }
  }
}
