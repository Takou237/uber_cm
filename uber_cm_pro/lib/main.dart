import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart'; // ✅ Obligatoire
import 'providers/auth_provider.dart';
import 'ui/views/auth/onboarding_pro_view.dart';
import 'ui/views/Enregistrement/vehicle_preference_view.dart';
import 'providers/language_provider.dart';

// ✅ Change le main en "Future<void>" et ajoute "async"
void main() async {
  // ✅ 1. Indispensable pour Firebase et les services natifs
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ 2. Initialise Firebase avant de lancer l'app
  // Note : Si tu n'as pas encore de fichier google-services.json, 
  // cela peut encore générer une erreur, mais c'est la structure correcte.
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Erreur d'initialisation Firebase : $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
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
          // Si l'utilisateur est connecté, on va vers le choix du véhicule
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