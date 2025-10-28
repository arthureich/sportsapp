// lib/api/user_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart'; // Importe seu UserModel

class UserService {
  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('usuarios');

  // Busca os dados de um usuário específico pelo ID
  Future<UserModel?> getUser(String userId) async {
    try {
      final userDoc = await _usersCollection.doc(userId).get();
      if (userDoc.exists) {
        return UserModel.fromSnapshot(userDoc);
      } else {
        debugPrint('Usuário com ID $userId não encontrado no Firestore.');
        return null; // Retorna null se não encontrar
      }
    } catch (e) {
      debugPrint("Erro ao buscar usuário: $e");
      return null; // Retorna null em caso de erro
    }
  }

   // Busca os dados de um usuário como Stream (para atualizações em tempo real)
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


  // Atualiza os dados de um usuário
  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      await _usersCollection.doc(userId).update(data);
    } catch (e) {
      debugPrint("Erro ao atualizar usuário: $e");
      rethrow; // Re-lança o erro para ser tratado na UI
    }
  }

    Future<List<UserModel>> getAllUsers() async {
    try {
      final querySnapshot = await _usersCollection.get();
      return querySnapshot.docs
          .map((doc) => UserModel.fromSnapshot(doc))
          .toList();
    } catch (e) {
      debugPrint("Erro ao buscar todos os usuários: $e");
      return [];
    }
  }
  // Você pode adicionar mais métodos aqui conforme necessário (ex: buscar todos os usuários, etc.)
}