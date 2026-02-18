import 'package:flutter/material.dart';
import 'otp_view.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginView extends StatefulWidget {
  final String lang;
  const LoginView({super.key, required this.lang});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final Color brandPink = const Color(0xFFE91E63);
  final TextEditingController _phoneController = TextEditingController();
  String _currentValue = "";
  bool _hasError = false;
  bool _isLoading = false; 

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

  // --- APPEL API POUR ENVOYER L'OTP ---
  Future<void> _sendOtpAndNavigate() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);
    final String phoneNumber = "+237${_phoneController.text.trim()}";
    
    try {
      final response = await http.post(
        Uri.parse('https://uberbackend-production-e8ea.up.railway.app/auth/request-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': phoneNumber,
          'email': 'daviladutau@gmail.com', // Email de test configuré sur ton Brevo
          'name': 'Utilisateur Uber CM' 
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        Navigator.push(
          context, 
          MaterialPageRoute(
            builder: (context) => OtpView(lang: widget.lang, phone: phoneNumber)
          )
        );
      } else {
        _triggerErrorEffect();
      }
    } catch (e) {
      _triggerErrorEffect();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

void _showMethodSelector() {
    String title = widget.lang == "FR" ? "Recevoir le code via" : "Receive code via";
    String emailLabel = widget.lang == "FR" ? "Email" : "Email";

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white, 
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 20),
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              
              // Option SMS
              ListTile(
                leading: const Icon(Icons.sms, color: Colors.blue),
                title: const Text("SMS"),
                onTap: () { Navigator.pop(context); _sendOtpAndNavigate(); },
              ),
              const Divider(),

              // Option WhatsApp
              ListTile(
                leading: const Icon(Icons.chat, color: Colors.green),
                title: const Text("WhatsApp"),
                onTap: () { Navigator.pop(context); _sendOtpAndNavigate(); },
              ),
              const Divider(),

              // NOUVELLE OPTION : EMAIL
              ListTile(
                leading: Icon(Icons.email, color: brandPink),
                title: Text(emailLabel),
                onTap: () { 
                  Navigator.pop(context); 
                  _sendOtpAndNavigate(); // Appelle la même logique car ton backend gère déjà l'email
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  void _handleNextStep() {
    String val = _phoneController.text.trim();
    if (val.length < 9 || !val.startsWith('6')) {
      _triggerErrorEffect();
      return;
    }
    _showMethodSelector();
  }

  @override
  Widget build(BuildContext context) {
    String title = (widget.lang == "FR") ? "Votre numéro ?" : "Mobile number ?";
    String nextBtnLabel = (widget.lang == "FR") ? "Suivant" : "Next";
    Color feedbackColor = _hasError ? Colors.red : Colors.black;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black)),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Align(alignment: Alignment.centerLeft, child: Text(title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold))),
            const SizedBox(height: 60),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("🇨🇲 +237", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: feedbackColor)),
                const SizedBox(width: 15),
                SizedBox(
                  width: 185, 
                  child: Stack(
                    children: [
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        autofocus: true,
                        maxLength: 9,
                        showCursor: false,
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
                                Text(hasChar ? _currentValue[index] : "", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: feedbackColor)),
                                Container(width: 16, height: 3, color: _hasError ? Colors.red : (hasChar ? Colors.black : Colors.grey[200])),
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
            const Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleNextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _hasError ? Colors.red : brandPink,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: _isLoading 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(nextBtnLabel, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}