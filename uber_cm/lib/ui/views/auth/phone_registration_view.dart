import 'package:flutter/material.dart';
import 'otp_verification_view.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as dev;

class PhoneRegistrationView extends StatelessWidget {
  final String lang;
  final String userName;
  final String userEmail;

  final TextEditingController _phoneController = TextEditingController();

  PhoneRegistrationView({
    super.key,
    required this.lang,
    required this.userName,
    required this.userEmail,
  });

  // --- LA MÉTHODE QUI MANQUAIT ---
  Future<void> _sendOtpRequest(BuildContext context, String method) async {
    final String phoneNumber = "+237${_phoneController.text.trim()}";

    try {
      // On ferme d'abord le dialogue de choix
      Navigator.pop(context);

      // On affiche un indicateur de chargement
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator(color: Color(0xFFE91E63))),
      );

      final response = await http.post(
        Uri.parse('http://172.30.7.48:5000/api/auth/request-otp'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "phone": phoneNumber,
          "name": userName,
          "email": userEmail,
          "method": method, // 'whatsapp' ou 'email'
        }),
      );

      if (!context.mounted) return;
      
      // On ferme l'indicateur de chargement
      Navigator.pop(context);

      if (response.statusCode == 200) {
        // Succès : on passe à l'écran de vérification en envoyant le numéro
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpVerificationView(
              lang: lang,
              phoneNumber: phoneNumber,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur lors de l'envoi du code")),
        );
      }
    } catch (e) {
      dev.log("Erreur : $e");
      if (context.mounted) {
        Navigator.pop(context); // Fermer le chargement en cas d'erreur
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur de connexion au serveur")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String title = (lang == "FR") ? "Votre numéro ?" : "Mobile number ?";
    String subtitle = (lang == "FR") 
        ? "Nous allons vous envoyer un code de vérification" 
        : "We'll send a verification code on this number";
    String nextBtn = (lang == "FR") ? "Suivant ->" : "Next ->";

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
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(30)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("🇨🇲 +237", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 10),
                      Container(width: 1, height: 25, color: Colors.grey[300]),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(hintText: "657 97 28 21", border: InputBorder.none),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: 200, height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_phoneController.text.trim().length < 9) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Numéro invalide")),
                        );
                        return;
                      }

                      showDialog(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          title: Text(lang == "FR" ? "Recevoir le code via" : "Receive code via", textAlign: TextAlign.center),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: const Icon(Icons.sms, color: Colors.blue),
                                title: const Text("SMS"),
                                subtitle: Text(lang == "FR" ? "(Indisponible)" : "(Unavailable)"),
                                onTap: null, // Désactivé
                              ),
                              ListTile(
                                leading: const Icon(Icons.message, color: Colors.green),
                                title: const Text("WhatsApp"),
                                onTap: () => _sendOtpRequest(context, "whatsapp"),
                              ),
                              ListTile(
                                leading: const Icon(Icons.email, color: Colors.red),
                                title: const Text("Email"),
                                onTap: () => _sendOtpRequest(context, "email"),
                              ),
                            ],
                          ),
                        ),
                      );
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
