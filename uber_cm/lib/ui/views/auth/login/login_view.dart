// lib/ui/views/auth/login/login_view.dart
import 'package:flutter/material.dart';
import 'otp_view.dart'; 

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

  // --- SÉLECTEUR DE MÉTHODE CORRIGÉ ---
  void _showMethodSelector() {
    String title = widget.lang == "FR" ? "Recevoir le code via" : "Receive code via";
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white, 
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20), // Correction EdgeInsets
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.sms, color: Colors.blue),
                title: const Text("SMS", style: TextStyle(fontWeight: FontWeight.w500)),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToOtp();
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.chat, color: Colors.green),
                title: const Text("WhatsApp", style: TextStyle(fontWeight: FontWeight.w500)),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToOtp();
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _navigateToOtp() {
    Navigator.push(
      context, 
      MaterialPageRoute(builder: (context) => OtpView(lang: widget.lang))
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
    String subtitle = (widget.lang == "FR") 
        ? "Saisissez votre numéro pour vous connecter." 
        : "Enter your number to log in.";
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
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
                child: Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 16))
              ),
              
              const SizedBox(height: 60),

              Column(
                children: [
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
                                        color: _hasError 
                                            ? Colors.red 
                                            : (hasChar ? Colors.black : Colors.grey[200]),
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
                        Text(
                          errorMsg,
                          style: const TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.w500),
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
                    onPressed: _handleNextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _hasError ? Colors.red : brandPink,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      elevation: 0,
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