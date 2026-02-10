// lib/ui/views/auth/name_registration_view.dart
import 'package:flutter/material.dart';
import 'email_registration_view.dart';

class NameRegistrationView extends StatefulWidget {
  final String lang;
  const NameRegistrationView({super.key, required this.lang});

  @override
  State<NameRegistrationView> createState() => _NameRegistrationViewState();
}

class _NameRegistrationViewState extends State<NameRegistrationView> {
  final TextEditingController _nameController = TextEditingController();
  final Color brandPink = const Color(0xFFE91E63);
  
  bool _hasError = false;

  void _triggerErrorEffect() {
    setState(() => _hasError = true);
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) setState(() => _hasError = false);
    });
  }

  void _validateAndNavigate() {
    if (_nameController.text.trim().isEmpty) {
      _triggerErrorEffect();
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmailRegistrationView(
          lang: widget.lang, 
          userName: _nameController.text.trim(), 
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String title = (widget.lang == "FR") ? "Quel est votre nom ?" : "What's your name?";
    String subtitle = (widget.lang == "FR") 
        ? "Votre nom aide les chauffeurs à vous identifier." 
        : "Your name helps drivers identify you.";
    String errorMsg = (widget.lang == "FR") ? "Veuillez entrer votre nom" : "Please enter your name";
    String nextBtnLabel = (widget.lang == "FR") ? "Suivant" : "Next";
    String hintText = (widget.lang == "FR") ? "ex: Jean Douala" : "e.g. John Doe";

    Color feedbackColor = _hasError ? Colors.red : Colors.black;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center, // Centralisation globale
            children: [
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey[600], fontSize: 16, height: 1.4),
                ),
              ),
              
              const SizedBox(height: 60), // Alignement avec les autres écrans
              
              // --- ZONE NOM CENTRALISÉE ---
              Column(
                children: [
                  TextField(
                    controller: _nameController,
                    autofocus: true,
                    textAlign: TextAlign.center, // Texte saisi centré
                    textCapitalization: TextCapitalization.words,
                    style: TextStyle(
                      fontSize: 22, 
                      color: feedbackColor, 
                      fontWeight: FontWeight.w500
                    ),
                    decoration: InputDecoration(
                      hintText: hintText,
                      hintStyle: TextStyle(color: Colors.grey[400]), 
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (val) {
                      if (_hasError) setState(() => _hasError = false);
                    },
                  ),
                  
                  const SizedBox(height: 20),

                  // --- ZONE ERREUR CENTRALISÉE ---
                  AnimatedOpacity(
                    opacity: _hasError ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center, // Erreur centrée
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          errorMsg,
                          style: const TextStyle(
                            color: Colors.red, 
                            fontSize: 14, 
                            fontWeight: FontWeight.w500
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const Spacer(),

              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: ElevatedButton(
                    onPressed: _validateAndNavigate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _hasError ? Colors.red : brandPink,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          nextBtnLabel,
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.arrow_forward_rounded, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}