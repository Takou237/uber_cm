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

  // --- NOUVEAU SÉLECTEUR DE LANGUE STYLÉ ---
  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min, // S'adapte au contenu
            children: [
              // Petite barre grise en haut pour le style "swipe down"
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Text(
                _currentLang == 'FR' ? "Choisir la langue" : "Select Language",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              
              // Option Français
              _buildLanguageOption(
                label: "Français",
                code: "FR",
                flag: "🇫🇷",
                isSelected: _currentLang == "FR",
              ),
              const SizedBox(height: 12),
              
              // Option English
              _buildLanguageOption(
                label: "English",
                code: "EN",
                flag: "🇺🇸",
                isSelected: _currentLang == "EN",
              ),
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  // Petit widget helper pour les lignes de langue
  Widget _buildLanguageOption({
    required String label,
    required String code,
    required String flag,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () {
        setState(() => _currentLang = code);
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE91E63).withValues( alpha:0.05) : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? const Color(0xFFE91E63) : Colors.grey[200]!,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? const Color(0xFFE91E63) : Colors.black,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle, color: Color(0xFFE91E63), size: 24),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color brandPink = Color(0xFFE91E63);

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/onboarding-hero.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues( alpha:0.4),
                  Colors.transparent,
                  Colors.black.withValues( alpha:0.9),
                ],
                stops: const [0.0, 0.4, 1.0],
              ),
            ),
          ),

          // BOUTON LANGUE (MODIFIÉ)
          Positioned(
            top: 50,
            right: 20,
            child: GestureDetector(
              onTap: _showLanguagePicker,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues( alpha:0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues( alpha:0.5),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.language, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      _currentLang,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 20),
                  ],
                ),
              ),
            ),
          ),

          // ... Le reste de ton code (Textes et Boutons) est identique ...
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
                          builder: (context) => NameRegistrationView(lang: _currentLang),
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
                      style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginView(lang: _currentLang)),
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
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
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