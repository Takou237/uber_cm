import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_colors.dart';
import 'data/providers/auth_provider.dart';
import 'data/providers/location_provider.dart';
import 'data/providers/order_provider.dart';
import 'data/providers/user_provider.dart';
import 'ui/views/auth/welcome_view.dart';
import 'ui/views/home/home_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final userProvider = UserProvider();
  await userProvider.loadUserData();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
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
      // Si un nom est déjà enregistré, on va direct à la Home, sinon Welcome.
      home: userProv.name != "Utilisateur" 
          ? const HomeView() 
          : const WelcomeView(),
    );
  }
}
