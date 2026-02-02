import 'package:flutter/material.dart';
// VERIFIE BIEN CET IMPORT : le nom du fichier doit être exactement celui-là
import 'email_registration_view.dart';

class NameRegistrationView extends StatefulWidget {
  final String lang;
  const NameRegistrationView({super.key, required this.lang});

  @override
  State<NameRegistrationView> createState() => _NameRegistrationViewState();
}

class _NameRegistrationViewState extends State<NameRegistrationView> {
  // On ajoute un contrôleur pour récupérer le texte (optionnel mais recommandé)
  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Traductions basées sur la variable lang passée en paramètre
    String title = (widget.lang == "FR")
        ? "Quel est votre nom ?"
        : "What is your name ?";
    String subtitle = (widget.lang == "FR")
        ? "Votre nom aide les chauffeurs à vous identifier"
        : "Your name helps drivers to identify you";
    String nextBtn = (widget.lang == "FR") ? "Suivant ->" : "Next ->";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextField(
                    controller: _nameController,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: widget.lang == "FR"
                          ? "ex: Jean Douala"
                          : "e.g. John Doe",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // LE BOUTON AVEC LA NAVIGATION CORRIGÉE
                SizedBox(
                  width: 200,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      // ACTION DE NAVIGATION
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EmailRegistrationView(lang: widget.lang),
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
}
