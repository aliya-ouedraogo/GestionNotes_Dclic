import 'package:flutter/material.dart';
import 'views/ecran_connexion.dart';
import 'views/couleurs.dart';

void main() {
  runApp(const AppNotesApp());
}

class AppNotesApp extends StatelessWidget {
  const AppNotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AppNotes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
