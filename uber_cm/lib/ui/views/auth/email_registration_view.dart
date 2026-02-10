// lib/ui/views/auth/email_registration_view.dart
import 'package:flutter/material.dart';
import 'phone_registration_view.dart';

class EmailRegistrationView extends StatefulWidget {
  final String lang;
  final String userName;

  const EmailRegistrationView({super.key, required this.lang, required this.userName});

  @override
  State<EmailRegistrationView> createState() => _EmailRegistrationViewState();
}

class _EmailRegistrationViewState extends State<EmailRegistrationView> {
  final TextEditingController _emailController = TextEditingController();
  final Color brandPink = const Color(0xFFE91E63);
  
  bool _hasError = false;

  void _triggerErrorEffect() {
    setState(() => _hasError = true);
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) setState(() => _hasError = false);
    });
  }

  void _validateAndNavigate() {
    String email = _emailController.text.trim();
    
    if (email.isEmpty || !email.contains('@') || !email.contains('.')) {
      _triggerErrorEffect();
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhoneRegistrationView(
          lang: widget.lang,
          userName: widget.userName,
          userEmail: email,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String title = (widget.lang == "FR") ? "Quel est votre adresse e-mail ?" : "What's your email address?";
    String subtitle = (widget.lang == "FR") 
        ? "Cela nous permet de vous envoyer vos reçus de trajet." 
        : "This allows us to send you your trip receipts.";
    String errorMsg = (widget.lang == "FR") ? "Email incorrect" : "Invalid email";
    String nextBtnLabel = (widget.lang == "FR") ? "Suivant" : "Next";
    String hintText = "email@example.com";

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
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
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
                      
                      const SizedBox(height: 60),
                      
                      // --- ZONE EMAIL CENTRALISÉE ---
                      Column(
                        children: [
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            autofocus: true,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20, 
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
                              mainAxisAlignment: MainAxisAlignment.center,
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
                          padding: const EdgeInsets.only(bottom: 20.0, top: 20.0),
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
          },
        ),
      ),
    );
  }
}