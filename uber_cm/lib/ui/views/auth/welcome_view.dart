// lib/ui/views/auth/welcome_view.dart
import 'package:flutter/material.dart';
import 'language_selection_view.dart';
// Importation de TON dossier login
import 'login/login_view.dart'; 

class WelcomeView extends StatelessWidget {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    // Couleur rose/rouge du bouton selon ton design
    const Color brandPink = Color(0xFFE91E63);

    return Scaffold(
      body: Stack(
        children: [
          // Image d'arrière-plan
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/onboarding-hero.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Dégradé noir pour assurer la lisibilité du texte blanc
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.8),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 60.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Restez en sécurité\ntout au long de\nvotre trajet.",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Faites-vous de l’argent en aidant les passagers à arriver à leur destination.",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 40),

                // BOUTON : Créer un compte
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LanguageSelectionView(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brandPink,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Créer un compte",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // LIEN : Connexion (SANS TRAIT EN BAS)
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginView(),
                        ),
                      );
                    },
                    child: RichText(
                      text: const TextSpan(
                        text: "Vous avez déjà un compte ? ",
                        style: TextStyle(color: Colors.white, fontSize: 15),
                        children: [
                          TextSpan(
                            text: "Connexion ->",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              // Le trait de décoration a été supprimé ici
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}