import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/language_provider.dart'; // Vérifie que ce chemin est exact
import 'registration/registration_view.dart';

class OnboardingProView extends StatelessWidget {
  const OnboardingProView({super.key});

  @override
  Widget build(BuildContext context) {
    // Couleurs du projet
    const Color brandPink = Color(0xFFE91E63);
    
    // Accès au Provider de langue
    final langProv = Provider.of<LanguageProvider>(context);
    final bool isFr = langProv.currentLocale.languageCode == 'fr';

    return Scaffold(
      body: Stack(
        children: [
          // 1. Image d'arrière-plan
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/chauffeur.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 2. Gradient pour la lisibilité
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.2),
                  Colors.black.withValues(alpha: 0.85),
                ],
              ),
            ),
          ),

          // 3. Contenu de la page
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HEADER : Logo + Sélecteur de langue
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Uber CM Pro",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      
                      // Icône Globe avec Menu déroulant
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.language, color: Colors.white, size: 28),
                        onSelected: (String code) {
                          langProv.changeLanguage(code);
                        },
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        itemBuilder: (BuildContext context) => [
                          PopupMenuItem(
                            value: 'fr',
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset('assets/images/Français.png', width: 24, 
                                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.flag, size: 20)),
                                const SizedBox(width: 12),
                                const Text("Français"),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'en',
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset('assets/images/English.png', width: 24, 
                                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.flag, size: 20)),
                                const SizedBox(width: 12),
                                const Text("English"),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  const Spacer(),

                  // Titre Principal Traduit
                  Text(
                    isFr
                        ? "Gagnez à votre rythme.\nPrenez la route avec\nUber CM Pro."
                        : "Earn at your own pace.\nHit the road with\nUber CM Pro.",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Sous-titre Traduit
                  Text(
                    isFr
                        ? "Optimisez vos revenus et gérez vos horaires en toute liberté avec la plateforme leader au Cameroun."
                        : "Optimize your income and manage your schedule freely with the leading platform in Cameroon.",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Bouton Devenir Partenaire
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RegistrationView()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: brandPink,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      child: Text(
                        isFr ? "Devenir Partenaire" : "Become a Partner",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Lien Se Connecter
                  Center(
                    child: TextButton(
                      onPressed: () {
                        // Action de connexion à venir
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isFr ? "Déjà partenaire ? " : "Already a partner? ",
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 15),
                          ),
                          Text(
                            isFr ? "Se connecter" : "Log in",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}