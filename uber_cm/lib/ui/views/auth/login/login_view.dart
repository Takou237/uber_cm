import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'otp_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final Color brandPink = const Color(0xFFE91E63); // Rose comme ton exemple
  final Color pBlue = const Color(0xFF1A237E); // Bleu pour les traits remplis

  final List<TextEditingController> _controllers = List.generate(
    9,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(9, (index) => FocusNode());

  bool _isError = false;
  String _errorMessage = "";

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _validateAndNavigate() {
    String phoneNumber = _controllers.map((e) => e.text).join();

    setState(() {
      if (phoneNumber.length < 9) {
        _isError = true;
        _errorMessage = "Veuillez saisir les 9 chiffres.";
      } else if (!phoneNumber.startsWith('6')) {
        _isError = true;
        _errorMessage = "Le numéro doit commencer par 6.";
      } else {
        _isError = false;
        _errorMessage = "";
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const OtpView()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Center(
        // Centrage vertical total
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Titre centré
                Text(
                  "Votre numéro ?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: brandPink,
                  ),
                ),
                const SizedBox(height: 10),
                // Sous-titre centré
                const Text(
                  "Nous allons vous envoyer un code de vérification",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                const SizedBox(height: 40),

                // Zone de saisie avec le drapeau et les cases
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Indicatif pays stylisé
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Text(
                        "🇨🇲 +237",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Les 9 cases
                    ...List.generate(9, (index) => _buildDigitBox(index)),
                  ],
                ),

                // Message d'erreur centré
                if (_isError)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                const SizedBox(height: 50),

                // Bouton Suivant arrondi (Stadium)
                SizedBox(
                  width: 200,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _validateAndNavigate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brandPink,
                      shape: const StadiumBorder(),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Suivant ->",
                      style: TextStyle(
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

  Widget _buildDigitBox(int index) {
    bool hasText = _controllers[index].text.isNotEmpty;

    return Container(
      width: 22, // Largeur adaptée pour 9 cases sur une ligne
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 3, // Tes traits prononcés
            color: _isError ? Colors.red : (hasText ? pBlue : Colors.black),
          ),
        ),
      ),
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        inputFormatters: [
          LengthLimitingTextInputFormatter(1),
          FilteringTextInputFormatter.digitsOnly,
        ],
        onChanged: (v) {
          if (_isError) setState(() => _isError = false);

          if (v.length == 1 && index < 8) {
            _focusNodes[index + 1].requestFocus();
          } else if (v.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
          setState(() {});
        },
        decoration: const InputDecoration(
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 8),
        ),
      ),
    );
  }
}
