import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:developer';
import 'dart:async';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/language_provider.dart';

class VerificationView extends StatefulWidget {
  const VerificationView({super.key});

  @override
  State<VerificationView> createState() => _VerificationViewState();
}

class _VerificationViewState extends State<VerificationView> {
  // Liste des contrôleurs pour récupérer le texte de chaque case
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  bool _showError = false;
  Timer? _errorTimer;

  void _handleVerify() {
    // On récupère le code complet
    String fullCode = _controllers.map((c) => c.text).join();
    final authProv = Provider.of<AuthProvider>(context, listen: false);

    if (authProv.verifyOTP(fullCode)) {
      setState(() => _showError = false);
      // Aller à la page suivante (Upload Documents)
      log("Code correct !");
    } else {
      // Afficher l'erreur et démarrer le compte à rebours de 5 secondes
      setState(() => _showError = true);

      _errorTimer?.cancel(); // Annule un timer précédent s'il existe
      _errorTimer = Timer(const Duration(seconds: 5), () {
        if (mounted) {
          setState(() => _showError = false);
        }
      });
    }
  }

  @override
  void dispose() {
    _errorTimer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userEmail = Provider.of<AuthProvider>(context).userEmail;
    final langProv = Provider.of<LanguageProvider>(context);
    final bool isFr = langProv.currentLocale.languageCode == 'fr';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isFr
                  ? "Entrez le code de vérification"
                  : "Enter the verification code",
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A40),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isFr
                  ? "Nous avons envoyé un code à six chiffres à $userEmail"
                  : "We have sent you a six digit code on $userEmail",
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),

            // Cases OTP
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (index) => _otpBox(index)),
            ),

            const SizedBox(height: 25),

            // Message d'erreur dynamique (S'affiche uniquement si _showError est vrai)
            if (_showError)
              Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    isFr
                        ? "Code OTP incorrect, vérifiez et réessayez"
                        : "Incorrect OTP, please check and try again",
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

            const Spacer(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    // Logique renvoyer code
                  },
                  child: Text(
                    isFr ? "Renvoyer le code" : "Resend code",
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: _handleVerify,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 240, 50, 107),
                    foregroundColor: Colors.black,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                  ),
                  child: Text(isFr ? "S'inscrire" : "Sign up"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _otpBox(int index) {
    return Container(
      width: 45,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: _showError ? Colors.red : Colors.black,
            width: 2,
          ),
        ),
      ),
      child: TextField(
        controller: _controllers[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        onChanged: (value) {
          // --- AJOUT ICI : Masque l'erreur dès qu'on modifie le texte ---
          if (_showError) {
            setState(() => _showError = false);
            _errorTimer?.cancel();
          }

          if (value.isNotEmpty && index < 5) {
            FocusScope.of(context).nextFocus();
          } else if (value.isEmpty && index > 0) {
            FocusScope.of(
              context,
            ).previousFocus(); // Retour arrière si on efface
          }
        },
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: _showError ? Colors.red : Colors.black,
        ),
        decoration: const InputDecoration(
          counterText: "",
          border: InputBorder.none,
        ),
      ),
    );
  }
}
