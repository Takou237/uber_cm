import 'package:flutter/material.dart';
import 'phone_registration_view.dart'; // Import de la prochaine étape

class EmailRegistrationView extends StatelessWidget {
  final String lang;
  const EmailRegistrationView({super.key, required this.lang});

  @override
  Widget build(BuildContext context) {
    // Traductions
    String title = (lang == "FR")
        ? "Quel est votre Email ?"
        : "What is your Email ?";
    String subtitle = (lang == "FR")
        ? "Cela nous permet de vous envoyer vos reçus"
        : "An email address lets us share trip receipts";
    String nextBtn = (lang == "FR") ? "S'inscrire ->" : "Signup ->";

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
                // Titre Rouge/Rose
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
                // Sous-titre Gris
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                ),
                const SizedBox(height: 40),

                // Champ Email sans barre
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextField(
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: "e.g. abc@xyz.com",
                      border: InputBorder.none,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Bouton Signup Centré
                SizedBox(
                  width: 200,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PhoneRegistrationView(lang: lang),
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
