import 'package:flutter/material.dart';

class OtpVerificationView extends StatefulWidget {
  final String lang;
  const OtpVerificationView({super.key, required this.lang});

  @override
  State<OtpVerificationView> createState() => _OtpVerificationViewState();
}

class _OtpVerificationViewState extends State<OtpVerificationView> {
  // Variable pour gérer l'état d'erreur
  bool hasError = false;

  @override
  Widget build(BuildContext context) {
    // Traductions
    String title = (widget.lang == "FR") ? "Vérification" : "Verification";
    String subtitle = (widget.lang == "FR")
        ? "Entrez le code envoyé au +237..."
        : "Enter the code sent to +237...";
    String verifyBtn = (widget.lang == "FR") ? "Vérifier" : "Verify";
    String resendBtn = (widget.lang == "FR")
        ? "Renvoyer le code"
        : "Resend code";
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
                Text(
                  title,
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
                  style: const TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 40),

                // LIGNE DES 6 TIRETS RAPPROCHÉS
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(6, (index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: _buildOtpDigitField(index),
                    );
                  }),
                ),

                // INDICATEUR D'ERREUR
                const SizedBox(height: 20),
                if (hasError)
                  Text(
                    errorMsg,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                const SizedBox(height: 40),

                // BOUTON VÉRIFIER
                SizedBox(
                  width: 200,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      // TEST : Active l'erreur pour voir le design
                      setState(() => hasError = true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE91E63),
                      shape: const StadiumBorder(),
                      elevation: 0,
                    ),
                    child: Text(
                      verifyBtn,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // BOUTON RENVOYER LE CODE
                TextButton(
                  onPressed: () {
                    // Logique pour renvoyer le SMS
                    setState(
                      () => hasError = false,
                    ); // On reset l'erreur quand on renvoie
                  },
                  child: Text(
                    resendBtn,
                    style: const TextStyle(
                      color: Colors.grey,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.w500,
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

  Widget _buildOtpDigitField(int index) {
    return SizedBox(
      width: 30,
      child: TextField(
        autofocus: index == 0,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        // Si erreur, le texte devient rouge
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: hasError ? Colors.red : Colors.black,
        ),
        decoration: InputDecoration(
          counterText: "",
          contentPadding: EdgeInsets.zero,
          // La ligne devient rouge si hasError est vrai
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: hasError ? Colors.red : Colors.grey,
              width: 2,
            ),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: hasError ? Colors.red : const Color(0xFFE91E63),
              width: 2,
            ),
          ),
        ),
        onChanged: (value) {
          if (value.length == 1 && index < 5) {
            FocusScope.of(context).nextFocus();
          } else if (value.isEmpty && index > 0) {
            FocusScope.of(context).previousFocus();
          }
          // On cache l'erreur dès que l'utilisateur recommence à taper
          if (hasError) setState(() => hasError = false);
        },
      ),
    );
  }
}
