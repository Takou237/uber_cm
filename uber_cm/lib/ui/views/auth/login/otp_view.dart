import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpView extends StatefulWidget {
  const OtpView({super.key});

  @override
  State<OtpView> createState() => _OtpViewState();
}

class _OtpViewState extends State<OtpView> {
  final Color brandPink = const Color(0xFFE91E63); // Rose harmonisé
  final Color pBlue = const Color(0xFF1A237E); // Bleu pour les traits remplis

  final List<TextEditingController> _controllers = List.generate(4, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (index) => FocusNode());

  bool _isError = false;

  @override
  void dispose() {
    for (var c in _controllers) c.dispose();
    for (var f in _focusNodes) f.dispose();
    super.dispose();
  }

  void _validateOtp() {
    String code = _controllers.map((e) => e.text).join();
    if (code.length < 4) {
      setState(() {
        _isError = true;
      });
    } else {
      setState(() {
        _isError = false;
      });
      // Navigation vers la suite (ex: NameRegistrationView)
      print("Code validé: $code");
    }
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Titre centré en rose
                Text(
                  "Vérification",
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
                  "Saisissez le code à 4 chiffres envoyé sur votre mobile",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                const SizedBox(height: 50),
                
                // Ligne des traits OTP CENTRÉE
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: _buildOtpUnderline(index),
                    );
                  }),
                ),

                // Message d'erreur centré
                if (_isError)
                  const Padding(
                    padding: EdgeInsets.only(top: 25),
                    child: Text(
                      "Code incomplet.",
                      style: TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),

                const SizedBox(height: 40),
                
                // Lien Renvoyer le code
                TextButton(
                  onPressed: () {},
                  child: Text(
                    "Je n'ai pas reçu de code",
                    style: TextStyle(color: brandPink, fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(height: 50),

                // Bouton Confirmer Arrondi (Stadium)
                SizedBox(
                  width: 200,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _validateOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brandPink,
                      shape: const StadiumBorder(),
                      elevation: 0,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Confirmer",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, color: Colors.white),
                      ],
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

  Widget _buildOtpUnderline(int index) {
    bool hasText = _controllers[index].text.isNotEmpty;

    return Container(
      width: 50,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: _isError ? Colors.red : (hasText ? pBlue : Colors.black),
            width: 3, 
          ),
        ),
      ),
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        inputFormatters: [
          LengthLimitingTextInputFormatter(1),
          FilteringTextInputFormatter.digitsOnly,
        ],
        onChanged: (v) {
          if (_isError) setState(() => _isError = false);

          if (v.length == 1 && index < 3) {
            _focusNodes[index + 1].requestFocus();
          } else if (v.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
          setState(() {}); 
        },
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}