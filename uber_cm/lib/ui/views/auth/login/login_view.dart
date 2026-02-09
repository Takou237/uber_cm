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
      if (mounted) {
        setState(() => _hasError = false);
      }
    });
  }

  void _showMethodSelector() {
    String title = widget.lang == "FR" ? "Recevoir le code via" : "Receive code via";
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
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.sms, color: Colors.blue),
                title: const Text("SMS"),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToOtp();
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.chat, color: Colors.green),
                title: const Text("WhatsApp"),
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
      MaterialPageRoute(
        builder: (context) => OtpView(lang: widget.lang),
      ),
    );
  }

  void _handleNextStep() {
    String phoneNumber = _phoneController.text.trim();
    if (phoneNumber.length < 9 || !phoneNumber.startsWith('6')) {
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
                    child: Text("🇨🇲 +237", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: feedbackColor)),
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
                                        width: 22,
                                        height: 3,
                                        color: _hasError ? Colors.red : (hasChar ? Colors.black : Colors.grey[300]),
                                      ),
                                    ],
                                  );
                                }),
                              ),
                            ),
                          ],
                        ),
                        
                        // --- ZONE ERREUR AVEC ICÔNE ---
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
                                style: const TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.w500),
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