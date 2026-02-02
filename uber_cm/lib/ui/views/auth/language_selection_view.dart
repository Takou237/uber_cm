import 'package:flutter/material.dart';
import 'name_registration_view.dart';

class LanguageSelectionView extends StatefulWidget {
  const LanguageSelectionView({super.key});

  @override
  State<LanguageSelectionView> createState() => _LanguageSelectionViewState();
}

class _LanguageSelectionViewState extends State<LanguageSelectionView> {
  // Langue sélectionnée par défaut
  String selectedLang = "FR";

  @override
  Widget build(BuildContext context) {
    // Textes dynamiques pour cette page
    String title = (selectedLang == "FR")
        ? "Choisissez votre langue"
        : "Choose your language";
    String subtitle = (selectedLang == "FR")
        ? "Sélectionnez la langue pour continuer"
        : "Select the language to continue";
    String nextBtn = (selectedLang == "FR") ? "Suivant ->" : "Next ->";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        // Flèche retour vers WelcomeView
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE91E63),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                ),
                const SizedBox(height: 40),

                // OPTION : FRANÇAIS
                _buildLanguageOption("Français", "FR", "🇫🇷"),

                const SizedBox(height: 15),

                // OPTION : ENGLISH
                _buildLanguageOption("English", "EN", "🇺🇸"),

                const SizedBox(height: 50),

                // BOUTON SUIVANT (CENTRE)
                SizedBox(
                  width: 200,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              NameRegistrationView(lang: selectedLang),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE91E63),
                      shape: const StadiumBorder(),
                      elevation: 0,
                    ),
                    child: Text(
                      nextBtn,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget pour créer les lignes de sélection de langue
  Widget _buildLanguageOption(String label, String code, String flag) {
    bool isSelected = selectedLang == code;
    return GestureDetector(
      onTap: () => setState(() => selectedLang = code),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFE91E63).withOpacity(0.05)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? const Color(0xFFE91E63) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 15),
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? const Color(0xFFE91E63) : Colors.black87,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle, color: Color(0xFFE91E63)),
          ],
        ),
      ),
    );
  }
}
