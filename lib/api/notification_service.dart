import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'user_service.dart'; 

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final UserService _userService = UserService();

  String? _currentFcmToken;

  Future<void> initNotifications() async {
    await _fcm.requestPermission();

    final token = await _fcm.getToken();
    if (kDebugMode) {
      print("===== FCM TOKEN =====");
      print(token);
      print("=====================");
    }
    _currentFcmToken = token; 

    final user = FirebaseAuth.instance.currentUser;
    if (user != null && token != null) {
      await _saveTokenToFirestore(user.uid, token);
    }

    _fcm.onTokenRefresh.listen((newToken) {
      _currentFcmToken = newToken;
      if (user != null) {
        _saveTokenToFirestore(user.uid, newToken);
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Recebida mensagem em primeiro plano: ${message.notification?.title}');
      }
    });
  }

  Future<void> saveTokenAfterLogin(String userId) async {
    if (_currentFcmToken != null) {
      await _saveTokenToFirestore(userId, _currentFcmToken!);
    }
  }
  
  Future<void> removeTokenOnLogout(String userId) async {
    if (_currentFcmToken != null) {
      await _userService.removeFcmToken(userId, _currentFcmToken!);
      _currentFcmToken = null; 
    }
  }

  Future<void> _saveTokenToFirestore(String userId, String token) async {
    await _userService.addFcmToken(userId, token);
  }
}