import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Tes imports
import 'core/constants/app_colors.dart';
import 'data/providers/auth_provider.dart';
import 'data/providers/location_provider.dart';
import 'data/providers/order_provider.dart';
import 'ui/views/auth/welcome_view.dart'; // Assure-toi que ce chemin est correct

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
      ],
      child: const UberCMApp(),
    ),
  );
}

class UberCMApp extends StatelessWidget {
  const UberCMApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Uber CM',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primaryRed,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryRed),
        useMaterial3: true,
      ),
      // C'EST ICI QUE ÇA SE PASSE :
      // Remplace "MyHomePage(...)" par "WelcomeView()"
      home: const WelcomeView(),
    );
  }
}
