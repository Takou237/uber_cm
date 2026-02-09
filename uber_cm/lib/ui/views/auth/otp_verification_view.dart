import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as dev;

class OtpVerificationView extends StatefulWidget {
  final String lang;
  // On récupère le téléphone pour savoir quel utilisateur vérifier au backend
  final String? phoneNumber; 

  const OtpVerificationView({super.key, required this.lang, this.phoneNumber});

  @override
  State<OtpVerificationView> createState() => _OtpVerificationViewState();
}

class _OtpVerificationViewState extends State<OtpVerificationView> {
  bool hasError = false;
  bool isLoading = false;

  // Liste pour stocker les chiffres saisis dans les 6 cases
  final List<String> _otpValues = List.filled(6, "");

  // Fonction pour envoyer le code au serveur Node.js
  Future<void> _verifyOtp() async {
    // On rassemble les chiffres (on prend les 4 premiers car ton backend génère 4 chiffres)
    String codeSaisi = _otpValues.join("").substring(0, 4);

    if (codeSaisi.length < 4) {
      setState(() => hasError = true);
      return;
    }

    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final response = await http.post(
        Uri.parse('http://172.30.7.48:5000/api/auth/verify-otp'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "phone": widget.phoneNumber ?? "", // Le numéro envoyé depuis la page précédente
          "code": codeSaisi
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        // SUCCÈS : Navigation vers l'accueil (à créer)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.lang == "FR" ? "Connexion réussie !" : "Login successful!")),
        );
        // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => HomeView()), (route) => false);
      } else {
        setState(() => hasError = true);
      }
    } catch (e) {
      dev.log("Erreur de vérification OTP: $e");
      setState(() => hasError = true);
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    String title = (widget.lang == "FR") ? "Vérification" : "Verification";
    String subtitle = (widget.lang == "FR")
        ? "Entrez le code envoyé au ${widget.phoneNumber ?? '+237...'}"
        : "Enter the code sent to ${widget.phoneNumber ?? '+237...'}";
    String verifyBtn = (widget.lang == "FR") ? "Vérifier" : "Verify";
    String resendBtn = (widget.lang == "FR") ? "Renvoyer le code" : "Resend code";
    String errorMsg = (widget.lang == "FR")
        ? "Code incorrect. Veuillez réessayer."
        : "Invalid code. Please try again.";

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
                Text(title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFFE91E63))),
                const SizedBox(height: 10),
                Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 40),

                // LIGNE DES 6 TIRETS
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(6, (index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: _buildOtpDigitField(index),
                    );
                  }),
                ),

                const SizedBox(height: 20),
                if (hasError)
                  Text(errorMsg, style: const TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.w500)),

                const SizedBox(height: 40),

                // BOUTON VÉRIFIER
                SizedBox(
                  width: 200,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _verifyOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE91E63),
                      shape: const StadiumBorder(),
                      elevation: 0,
                    ),
                    child: isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(verifyBtn, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),

                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => setState(() => hasError = false),
                  child: Text(resendBtn, style: const TextStyle(color: Colors.grey, decoration: TextDecoration.underline, fontWeight: FontWeight.w500)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOtpDigitField(int index) {
    return SizedBox(
      width: 30,
      child: TextField(
        autofocus: index == 0,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: hasError ? Colors.red : Colors.black,
        ),
        decoration: InputDecoration(
          counterText: "",
          contentPadding: EdgeInsets.zero,
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: hasError ? Colors.red : Colors.grey, width: 2),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: hasError ? Colors.red : const Color(0xFFE91E63), width: 2),
          ),
        ),
        onChanged: (value) {
          // ON ENREGISTRE LA VALEUR
          _otpValues[index] = value;

          if (value.length == 1 && index < 5) {
            FocusScope.of(context).nextFocus();
          } else if (value.isEmpty && index > 0) {
            FocusScope.of(context).previousFocus();
          }
          if (hasError) setState(() => hasError = false);
        },
      ),
    );
  }
}
