// lib/ui/views/auth/welcome_view.dart
import 'package:flutter/material.dart';
import 'name_registration_view.dart'; 
import 'login/login_view.dart'; 

class WelcomeView extends StatefulWidget {
  const WelcomeView({super.key});

  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView> {
  String _currentLang = 'FR';

  @override
  Widget build(BuildContext context) {
    const Color brandPink = Color(0xFFE91E63);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/onboarding-hero.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.4),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.9),
                ],
                stops: const [0.0, 0.4, 1.0],
              ),
            ),
          ),

          Positioned(
            top: 50,
            right: 20,
            child: PopupMenuButton<String>(
              onSelected: (String lang) {
                setState(() {
                  _currentLang = lang;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.language,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'FR', child: Text("🇫🇷 Français")),
                const PopupMenuItem(value: 'EN', child: Text("🇺🇸 English")),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 60.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentLang == 'FR' 
                      ? "Restez en sécurité\ntout au long de\nvotre trajet."
                      : "Stay safe\nall along\nyour journey.",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _currentLang == 'FR'
                      ? "Faites-vous de l’argent en aidant les passagers à arriver à leur destination."
                      : "Earn money by helping passengers reach their destination.",
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NameRegistrationView(
                            lang: _currentLang, 
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brandPink,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _currentLang == 'FR' ? "Créer un compte" : "Create account",
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Center(
                  child: TextButton(
                    onPressed: () {
                      // --- CORRECTION ICI ---
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          // On enlève 'const' et on ajoute 'lang'
                          builder: (context) => LoginView(lang: _currentLang),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _currentLang == 'FR' ? "Vous avez déjà un compte ? " : "Already have an account? ",
                          style: const TextStyle(color: Colors.white70, fontSize: 15),
                        ),
                        Text(
                          _currentLang == 'FR' ? "Connexion" : "Login",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ],
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