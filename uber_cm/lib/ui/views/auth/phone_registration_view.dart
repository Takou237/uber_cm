// lib/ui/views/auth/phone_registration_view.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'otp_verification_view.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PhoneRegistrationView extends StatefulWidget {
  final String lang;
  final String userName;
  final String userEmail;

  const PhoneRegistrationView({
    super.key,
    required this.lang,
    required this.userName,
    required this.userEmail,
  });

  @override
  State<PhoneRegistrationView> createState() => _PhoneRegistrationViewState();
}

class _PhoneRegistrationViewState extends State<PhoneRegistrationView> {
  final Color brandPink = const Color(0xFFE91E63);
  final TextEditingController _phoneController = TextEditingController();
  String _currentValue = "";
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(() {
      setState(() {
        _currentValue = _phoneController.text;
        if (_hasError) _hasError = false; 
      });
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _triggerErrorEffect() {
    setState(() => _hasError = true);
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) setState(() => _hasError = false);
    });
  }

  // --- LOGIQUE DE NAVIGATION ---
  void _navigateToOtp(String phone) {
    Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => OtpVerificationView(
          lang: widget.lang, 
          phoneNumber: phone
        )
      )
    );
  }

  // --- APPEL API ---
  Future<void> _sendOtpRequest(String method) async {
    final String phoneNumber = "+237${_phoneController.text.trim()}";
    
    if (Navigator.canPop(context)) Navigator.pop(context); 

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Color(0xFFE91E63))),
    );

    try {
      // --- ÉTAPE 1 : ON ENREGISTRE D'ABORD L'UTILISATEUR ---
      final registerResponse = await http.post(
        Uri.parse('https://uberbackend-production-e8ea.up.railway.app/api/auth/register'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "phone": phoneNumber,
          "name": widget.userName,
          "email": widget.userEmail,
        }),
      );

      // Si le code est 201 (créé) ou 400 (déjà existant), on peut continuer vers l'OTP
      if (registerResponse.statusCode == 201 || registerResponse.statusCode == 400) {
        
        // --- ÉTAPE 2 : ON DEMANDE L'OTP ---
        final otpResponse = await http.post(
          Uri.parse('https://uberbackend-production-e8ea.up.railway.app/api/auth/request-otp'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"phone": phoneNumber}),
        );

        if (!mounted) return;
        Navigator.pop(context); // Fermer le loader

        if (otpResponse.statusCode == 200) {
          _navigateToOtp(phoneNumber);
        } else {
          _handleRequestFailure(phoneNumber, "Erreur OTP (${otpResponse.statusCode})");
        }
      } else {
        if (!mounted) return;
        Navigator.pop(context);
        _handleRequestFailure(phoneNumber, "Erreur Inscription (${registerResponse.statusCode})");
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      _handleRequestFailure(phoneNumber, "Erreur de connexion");
    }
  }

  // --- GESTION DES ERREURS D'APPEL ---
  void _handleRequestFailure(String phone, String reason) {
    _triggerErrorEffect();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$reason. Voulez-vous passer en mode test ?"),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: "OUI",
          textColor: Colors.white,
          onPressed: () => _navigateToOtp(phone),
        ),
        backgroundColor: Colors.black87,
      ),
    );
  }

  // --- SÉLECTEUR DE MÉTHODE STYLÉ ---
  void _showMethodSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
              ),
              Text(
                widget.lang == "FR" ? "Recevoir le code via" : "Receive code via",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _methodTile(Icons.sms, "SMS", Colors.blue, "sms"),
              const Divider(),
              _methodTile(Icons.message, "WhatsApp", Colors.green, "whatsapp"),
              const Divider(),
              _methodTile(Icons.email, "Email", Colors.red, "email"),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _methodTile(IconData icon, String title, Color color, String method) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      onTap: () => _sendOtpRequest(method),
    );
  }

  @override
  Widget build(BuildContext context) {
    String title = (widget.lang == "FR") ? "Votre numéro ?" : "Mobile number ?";
    String subtitle = (widget.lang == "FR") 
        ? "Nous allons vous envoyer un code de vérification." 
        : "We'll send a verification code.";
    String errorMsg = (widget.lang == "FR") ? "Numéro incorrect" : "Incorrect number";
    String nextBtnLabel = (widget.lang == "FR") ? "Suivant" : "Next";

    Color feedbackColor = _hasError ? Colors.red : Colors.black;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, 
        elevation: 0, 
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black), 
          onPressed: () => Navigator.pop(context)
        )
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
                        child: Text(title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold))
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 16, height: 1.4))
                      ),
                      
                      const SizedBox(height: 60),
                      
                      // ZONE SAISIE
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("🇨🇲 +237", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: feedbackColor)),
                          const SizedBox(width: 15),
                          SizedBox(
                            width: 185, 
                            child: Stack(
                              alignment: Alignment.centerLeft,
                              children: [
                                TextField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  autofocus: true,
                                  maxLength: 9,
                                  showCursor: false,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  style: const TextStyle(color: Colors.transparent),
                                  decoration: const InputDecoration(counterText: "", border: InputBorder.none),
                                ),
                                IgnorePointer(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: List.generate(9, (index) {
                                      bool hasChar = _currentValue.length > index;
                                      return Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            hasChar ? _currentValue[index] : "",
                                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: feedbackColor),
                                          ),
                                          const SizedBox(height: 4),
                                          AnimatedContainer(
                                            duration: const Duration(milliseconds: 300),
                                            width: 16,
                                            height: 3,
                                            color: _hasError ? Colors.red : (hasChar ? Colors.black : Colors.grey[200]),
                                          ),
                                        ],
                                      );
                                    }),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 25),

                      AnimatedOpacity(
                        opacity: _hasError ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red, size: 16),
                            const SizedBox(width: 6),
                            Text(errorMsg, style: const TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),

                      const Spacer(),

                      Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 20.0, top: 20),
                          child: ElevatedButton(
                            onPressed: () {
                              if (_phoneController.text.trim().length < 9) {
                                _triggerErrorEffect(); 
                                return;
                              }
                              _showMethodSelector();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _hasError ? Colors.red : brandPink,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(nextBtnLabel, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
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