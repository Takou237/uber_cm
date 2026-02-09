import 'package:flutter/material.dart';
import 'phone_registration_view.dart';

class EmailRegistrationView extends StatelessWidget {
  final String lang;
  final String userName; // Reçu de la page précédente
  
  final TextEditingController _emailController = TextEditingController();

  EmailRegistrationView({super.key, required this.lang, required this.userName});

  @override
  Widget build(BuildContext context) {
    String title = (lang == "FR") ? "Quel est votre Email ?" : "What is your Email ?";
    String subtitle = (lang == "FR") ? "Cela nous permet de vous envoyer vos reçus" : "An email address lets us share trip receipts";
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
                Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFFE91E63))),
                const SizedBox(height: 10),
                Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 16)),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(color: Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(30)),
                  child: TextField(
                    controller: _emailController, // Assigné ici
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                    decoration: InputDecoration(
                      hintText: "e.g. abc@gmail.com",
                      hintStyle: const TextStyle(color: Colors.grey, fontSize: 16),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: 200, height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      // CONDITION DE BLOCAGE
                      if (_emailController.text.trim().isEmpty || !_emailController.text.contains('@')) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(lang == "FR" ? "Email invalide" : "Invalid email")),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PhoneRegistrationView(
                              lang: lang,
                              userName: userName, // Transmission continue
                              userEmail: _emailController.text.trim(), // Transmission de l'email
                            ),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE91E63), shape: const StadiumBorder(), elevation: 0),
                    child: Text(nextBtn, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
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
