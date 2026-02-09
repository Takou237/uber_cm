// lib/ui/views/auth/phone_registration_view.dart
import 'package:flutter/material.dart';
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

  // --- LOGIQUE DU FLASH ROUGE TEMPORAIRE ---
  void _triggerErrorEffect() {
    setState(() => _hasError = true);
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        setState(() => _hasError = false);
      }
    });
  }

  Future<void> _sendOtpRequest(String method) async {
    final String phoneNumber = "+237${_phoneController.text.trim()}";
    Navigator.pop(context); 

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Color(0xFFE91E63))),
    );

    try {
      final response = await http.post(
        Uri.parse('http://172.30.7.48:5000/api/auth/request-otp'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "phone": phoneNumber,
          "name": widget.userName,
          "email": widget.userEmail,
          "method": method,
        }),
      );

      if (!mounted) return;
      Navigator.pop(context); 

      if (response.statusCode == 200) {
        Navigator.push(
          context, 
          MaterialPageRoute(builder: (context) => OtpVerificationView(lang: widget.lang, phoneNumber: phoneNumber))
        );
      } else {
        _triggerErrorEffect();
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      _triggerErrorEffect();
    }
  }

  void _showMethodSelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.lang == "FR" ? "Recevoir le code via" : "Receive code via",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.sms, color: Colors.blue),
                title: const Text("SMS"),
                subtitle: Text(widget.lang == "FR" ? "(Bientôt disponible)" : "(Coming soon)"),
                onTap: null, 
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.message, color: Colors.green),
                title: const Text("WhatsApp"),
                onTap: () => _sendOtpRequest("whatsapp"),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.email, color: Colors.red),
                title: const Text("Email"),
                onTap: () => _sendOtpRequest("email"),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 16)),
              const SizedBox(height: 40),
              
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Text("🇨🇲 +237", 
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: feedbackColor)),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            TextField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              autofocus: true,
                              maxLength: 9,
                              showCursor: false,
                              style: const TextStyle(color: Colors.transparent),
                              decoration: const InputDecoration(
                                counterText: "", 
                                border: InputBorder.none,
                              ),
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
                                        style: TextStyle(
                                          fontSize: 22, 
                                          fontWeight: FontWeight.bold,
                                          color: feedbackColor,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      AnimatedContainer(
                                        duration: const Duration(milliseconds: 300),
                                        width: 20, 
                                        height: 3,
                                        color: _hasError 
                                            ? Colors.red 
                                            : (hasChar ? Colors.black : Colors.grey[300]),
                                      ),
                                    ],
                                  );
                                }),
                              ),
                            ),
                          ],
                        ),
                        
                        // --- MESSAGE D'ERREUR AVEC POINT D'EXCLAMATION ---
                        const SizedBox(height: 10),
                        AnimatedOpacity(
                          opacity: _hasError ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 300),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: Colors.red, size: 16),
                              const SizedBox(width: 4),
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
                  ),
                ],
              ),

              const Spacer(),

              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: ElevatedButton(
                    onPressed: () {
                      if (_phoneController.text.trim().length < 9 || !_phoneController.text.trim().startsWith('6')) {
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
  }
}