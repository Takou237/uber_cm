import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/constants/app_colors.dart';
import 'data/providers/auth_provider.dart';
import 'data/providers/location_provider.dart';
import 'data/providers/order_provider.dart';
import 'data/providers/user_provider.dart';
import 'data/providers/driver_provider.dart'; // NOUVEAU : Pour les infos Railway
import 'ui/views/auth/welcome_view.dart';
import 'ui/views/home/home_view.dart';

void main() async {
  // 1. Indispensable pour les services natifs (GPS, Firebase)
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialisation de Firebase
  await Firebase.initializeApp();

  // 3. Chargement des données locales
  final userProvider = UserProvider();
  await userProvider.loadUserData();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(
          create: (_) => DriverProvider(),
        ), // AJOUT : Gestion du chauffeur Railway
        ChangeNotifierProvider.value(value: userProvider),
      ],
      child: const UberCMApp(),
    ),
  );
}

class UberCMApp extends StatelessWidget {
  const UberCMApp({super.key});

  @override
  Widget build(BuildContext context) {
    // On écoute le UserProvider pour savoir où rediriger l'utilisateur
    final userProv = Provider.of<UserProvider>(context);

    return MaterialApp(
      title: 'Uber CM',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primaryRed,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryRed),
        useMaterial3: true,
      ),
      // LOGIQUE DE DÉMARRAGE :
      home: userProv.name != "Utilisateur"
          ? const HomeView()
          : const WelcomeView(),
    );
  }
}
