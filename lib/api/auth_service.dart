import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'notification_service.dart'; 

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();

  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserCredential> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String nome,
    required String bio,
    required String genero,
    required List<String> esportes,
  }) async {
    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final String? userId = userCredential.user?.uid;
      final genderValue = (genero == 'Masculino') ? 'boy' : 'girl';

      if (userId != null) {
        await _firestore.collection('usuarios').doc(userId).set({
          'nome': nome,
          'email': email,
          'bio': bio,
          'esportesInteresse': esportes,
          'fotoUrl': '',
          'scoreEsportividade': 5.0,
          'createdAt': FieldValue.serverTimestamp(),
          'fcmTokens': [],
          'genero': genderValue,
        });
        await userCredential.user?.updateDisplayName(nome);
      }
      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null; 
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        if (userCredential.additionalUserInfo?.isNewUser ?? false) {
          await _firestore.collection('usuarios').doc(user.uid).set({
            'nome': user.displayName ?? 'Usuário Google',
            'email': user.email ?? '',
            'fotoUrl': user.photoURL ?? '',
            'bio': '', 
            'esportesInteresse': [], 
            'scoreEsportividade': 5.0,
            'createdAt': FieldValue.serverTimestamp(),
            'fcmTokens': [],
            'genero': 'boy', 
          });
        }
      }
      return userCredential;
    } catch (e) {
      if (kDebugMode) {
        print("Erro no Login com Google: $e");
      }
      rethrow;
    }
  }

  Future<void> signOut() async {
    final user = _auth.currentUser;
    if (user != null) {
      await _notificationService.removeTokenOnLogout(user.uid);
    }
    await _googleSignIn.signOut(); 
    await _auth.signOut(); 
  }
}