import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'providers/auth_provider.dart';
import 'providers/language_provider.dart';
import 'providers/user_provider.dart';

import 'ui/views/auth/onboarding_pro_view.dart';
import 'ui/views/Enregistrement/vehicle_preference_view.dart';
// ✅ 1. AJOUTE CET IMPORT (Vérifie bien le chemin vers ta HomeView)
import 'ui/views/home/home_view.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Erreur d'initialisation Firebase : $e");
  }

  final userProvider = UserProvider();
  await userProvider.loadUserData();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider.value(value: userProvider),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Uber CM Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE91E63)),
        useMaterial3: true,
      ),
      home: Consumer2<AuthProvider, UserProvider>(
        builder: (context, auth, user, _) {
          // 1. Si pas connecté -> Onboarding
          if (!auth.isLoggedIn) {
            return const OnboardingProView();
          }

          // ✅ 2. CORRECTION DU WARNING : On vérifie si l'ID est vide 
          // au lieu de vérifier s'il est nul (si ton provider initialise à "")
          if (user.id == "" || user.id == "null") {
             return const VehiclePreferenceView();
          }

          // ✅ 3. L'ERREUR DISPARAÎT car HomeView est maintenant importé
          return const HomeView(); 
        },
      ),
    );
  }
}