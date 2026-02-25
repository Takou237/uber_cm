import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart'; // ✅ Obligatoire

import 'providers/auth_provider.dart';
import 'providers/language_provider.dart';
import '/providers/user_provider.dart'; // ✅ NOUVEAU : Import de ton UserProvider

import 'ui/views/auth/onboarding_pro_view.dart';
import 'ui/views/Enregistrement/vehicle_preference_view.dart';

// ✅ Change le main en "Future<void>" et ajoute "async"
void main() async {
  // ✅ 1. Indispensable pour Firebase et les services natifs
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ 2. Initialise Firebase avant de lancer l'app
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Erreur d'initialisation Firebase : $e");
  }

  // ✅ 3. Initialisation et chargement des données du chauffeur connecté
  final userProvider = UserProvider();
  await userProvider.loadUserData();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // ✅ 4. On ajoute le UserProvider à l'application
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
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          // Si l'utilisateur est connecté, on va vers le choix du véhicule (puis vers la HomeView)
          if (auth.isLoggedIn) {
            return const VehiclePreferenceView();
          }
          // Sinon, écran de bienvenue
          return const OnboardingProView();
        },
      ),
    );
  }
}
