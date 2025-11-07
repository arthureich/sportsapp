import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/home/home_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'api/notification_service.dart';
import 'api/user_service.dart';
import 'models/user_model.dart';
import 'screens/profile/edit_profile_screen.dart';
import 'firebase_options.dart';
import 'screens/auth/login_screen.dart';

final NotificationService _notificationService = NotificationService();
final UserService _userService = UserService();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "api.env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await _notificationService.initNotifications();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Joga-Mais',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
        fontFamily: 'Poppins', 

        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),

        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.orangeAccent,
          foregroundColor: Colors.white,
        ),

        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.grey[800]),
          titleTextStyle: TextStyle(
            color: Colors.grey[800],
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(), 
        builder: (context, authSnapshot) {
          if (authSnapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator())); 
          }
          if (authSnapshot.hasData) {
            _notificationService.saveTokenAfterLogin(authSnapshot.data!.uid);

            return StreamBuilder<UserModel?>(
              stream: _userService.getUserStream(authSnapshot.data!.uid),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(body: Center(child: CircularProgressIndicator()));
                }
              
                if (!userSnapshot.hasData || userSnapshot.data == null) {
                  return const Scaffold(body: Center(child: CircularProgressIndicator()));
                }

                final userModel = userSnapshot.data!;

                if (userModel.esportesInteresse.isEmpty) {
                  return EditProfileScreen(userId: userModel.id);
                } else {
                  return const NewHomeScreen(); 
                }
              },
            );
          }
          return const LoginScreen(); 
        },
      ),
    );
  }
}