import 'package:flutter/material.dart';

class HomeView extends StatelessWidget {
  final String lang;

  const HomeView({super.key, required this.lang});

  @override
  Widget build(BuildContext context) {
    // Textes selon la langue
    String welcomeMsg = (lang == "FR") ? "Bienvenue !" : "Welcome !";
    String subtitle = (lang == "FR") 
        ? "Vous êtes connecté avec succès." 
        : "You are successfully logged in.";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Yobiz", // Nom de ton app
          style: TextStyle(color: const Color(0xFFE91E63), fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Petit design sympa pour meubler le vide
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFE91E63).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, size: 80, color: Color(0xFFE91E63)),
            ),
            const SizedBox(height: 24),
            Text(
              welcomeMsg,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            const SizedBox(height: 40),
            // Bouton de déconnexion pour tester le retour
            TextButton(
              onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
              child: Text(
                lang == "FR" ? "Se déconnecter" : "Logout",
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}