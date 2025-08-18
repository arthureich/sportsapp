// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/home/home_screen.dart';
//import '/screens/home/home_screen.dart'; // Importa a tela principal

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Esporte na Vizinhança',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Paleta de cores que discutimos
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
        fontFamily: 'Poppins', // Use uma fonte moderna como Poppins ou Lato

        // Tema para os Cards
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),

        // Tema para o Botão Flutuante
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.orangeAccent,
          foregroundColor: Colors.white,
        ),

        // Tema para a Barra de Aplicativo
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
      home: const NewHomeScreen(),
    );
  }
}