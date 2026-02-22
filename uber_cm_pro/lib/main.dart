import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'ui/views/driver_home_view.dart';

void main() async {
  // 1. On s'assure que les liens avec le code natif sont prêts
  WidgetsFlutterBinding.ensureInitialized();

  // 2. On initialise Firebase
  await Firebase.initializeApp();

  // 3. On lance l'application
  runApp(const UberCMPro());
}

class UberCMPro extends StatelessWidget {
  const UberCMPro({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Uber CM Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF111727)),
        useMaterial3: true,
      ),
      home:
          const DriverHomeView(), // C'est ici qu'on appellera notre vue principale
    );
  }
}
