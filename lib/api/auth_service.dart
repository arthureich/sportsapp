import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'notification_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();
  static const List<String> _scopes = <String>[
    'email',
    'profile',
  ];

  Future<void> _initializeGoogleSignIn() async {
    try {
      await GoogleSignIn.instance.initialize(
      );
    } catch (e) {
      if (kDebugMode) {
        print("Erro ao inicializar Google Sign In: $e");
      }
    }
  }

  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
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
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
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
      await _initializeGoogleSignIn();

      if (!GoogleSignIn.instance.supportsAuthenticate()) {
        throw Exception('Plataforma não suporta autenticação Google');
      }
 
      final GoogleSignInAccount googleUser =
          await GoogleSignIn.instance.authenticate();

      final GoogleSignInClientAuthorization authorization =
          await googleUser.authorizationClient.authorizeScopes(_scopes);

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: authorization.accessToken,
        idToken: null, 
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        if (userCredential.additionalUserInfo?.isNewUser ?? false) {
          await _firestore.collection('usuarios').doc(user.uid).set({
            'nome': user.displayName ?? 'Usuário Google',
            'email': user.email ?? '',
            'fotoUrl': user.photoURL ?? '',
            'bio': '', 
            'esportesInteresse': [], 
            'scoreEsportividade': null,
            'createdAt': FieldValue.serverTimestamp(),
            'fcmTokens': [],
            'genero': 'boy', 
          });
        }
      }

      return userCredential;
    } on GoogleSignInException catch (e) {
      if (kDebugMode) {
        print("GoogleSignInException: ${e.code} - ${e.description}");
      }

      final errorMessage = switch (e.code) {
        GoogleSignInExceptionCode.canceled => 'Login cancelado pelo usuário',
        GoogleSignInExceptionCode.unknownError => 'Erro de conexão',
        GoogleSignInExceptionCode.interrupted => 'Login necessário',
        _ => 'Erro no login: ${e.description}',
      };

      throw Exception(errorMessage);
    } catch (e) {
      if (kDebugMode) {
        print("Erro no Login com Google: $e");
      }
      rethrow;
    }
  }

  Future<UserCredential?> signInWithGoogleOAuth() async {
    try {
      await _initializeGoogleSignIn();

      if (!GoogleSignIn.instance.supportsAuthenticate()) {
        throw Exception('Plataforma não suporta autenticação Google');
      }

      final GoogleSignInAccount googleUser =
          await GoogleSignIn.instance.authenticate();
      final GoogleSignInClientAuthorization authorization =
          await googleUser.authorizationClient.authorizeScopes(_scopes);

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: authorization.accessToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      final User? user = userCredential.user;
      if (user != null &&
          (userCredential.additionalUserInfo?.isNewUser ?? false)) {
        await _firestore.collection('usuarios').doc(user.uid).set({
          'nome': user.displayName ?? 'Usuário Google',
          'email': user.email ?? '',
          'fotoUrl': user.photoURL ?? '',
          'bio': '',
          'esportesInteresse': [],
          'scoreEsportividade': null,
          'createdAt': FieldValue.serverTimestamp(),
          'fcmTokens': [],
          'genero': 'boy',
        });
      }

      return userCredential;
    } catch (e) {
      if (kDebugMode) {
        print("Erro no Login com Google (OAuth): $e");
      }
      rethrow;
    }
  }

  Future<UserCredential?> signInWithGoogleScopes(List<String> scopes) async {
    try {
      await _initializeGoogleSignIn();

      if (!GoogleSignIn.instance.supportsAuthenticate()) {
        throw Exception('Plataforma não suporta autenticação Google');
      }

      final GoogleSignInAccount googleUser =
          await GoogleSignIn.instance.authenticate();
      final GoogleSignInClientAuthorization authorization =
          await googleUser.authorizationClient.authorizeScopes(scopes);
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: authorization.accessToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;
      if (user != null &&
          (userCredential.additionalUserInfo?.isNewUser ?? false)) {
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

      return userCredential;
    } catch (e) {
      if (kDebugMode) {
        print("Erro no Login com Google (scopes): $e");
      }
      rethrow;
    }
  }
  Future<bool> hasGoogleAuthorization(List<String> scopes) async {
    try {
      await _initializeGoogleSignIn();

      final GoogleSignInAccount googleUser =
          await GoogleSignIn.instance.authenticate();

      final GoogleSignInClientAuthorization? authorization =
          await googleUser.authorizationClient.authorizationForScopes(scopes);

      return authorization != null;
    } catch (e) {
      if (kDebugMode) {
        print("Erro ao verificar autorização: $e");
      }
      return false;
    }
  }
  Future<String?> getGoogleServerAuthCode(List<String> scopes) async {
    try {
      await _initializeGoogleSignIn();

      final GoogleSignInAccount googleUser =
          await GoogleSignIn.instance.authenticate();

      final GoogleSignInServerAuthorization? serverAuth =
          await googleUser.authorizationClient.authorizeServer(scopes);

      return serverAuth?.serverAuthCode;
    } catch (e) {
      if (kDebugMode) {
        print("Erro ao obter Server Auth Code: $e");
      }
      return null;
    }
  }
  Future<Map<String, String>?> getAuthorizationHeaders(
      List<String> scopes) async {
    try {
      await _initializeGoogleSignIn();

      final GoogleSignInAccount googleUser =
          await GoogleSignIn.instance.authenticate();
      await googleUser.authorizationClient.authorizeScopes(scopes);
      final Map<String, String>? headers =
          await googleUser.authorizationClient.authorizationHeaders(scopes);

      return headers;
    } catch (e) {
      if (kDebugMode) {
        print("Erro ao obter headers de autorização: $e");
      }
      return null;
    }
  }
  Future<void> signOut() async {
    final user = _auth.currentUser;
    if (user != null) {
      await _notificationService.removeTokenOnLogout(user.uid);
    }
    await GoogleSignIn.instance.disconnect();
    await _auth.signOut();
  }
  Future<void> signOutWithoutDisconnect() async {
    final user = _auth.currentUser;
    if (user != null) {
      await _notificationService.removeTokenOnLogout(user.uid);
    }
    await GoogleSignIn.instance.signOut();
    await _auth.signOut();
  }
}