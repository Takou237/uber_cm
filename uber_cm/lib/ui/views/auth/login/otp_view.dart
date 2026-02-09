// lib/ui/views/auth/login/otp_view.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpView extends StatefulWidget {
  final String lang;
  const OtpView({super.key, required this.lang});

  @override
  State<OtpView> createState() => _OtpViewState();
}

class _OtpViewState extends State<OtpView> {
  final Color brandPink = const Color(0xFFE91E63);
  final TextEditingController _otpController = TextEditingController();
  String _currentValue = "";
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _otpController.addListener(() {
      setState(() {
        _currentValue = _otpController.text;
        if (_hasError) _hasError = false;
      });
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _triggerErrorEffect() {
    setState(() => _hasError = true);
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) setState(() => _hasError = false);
    });
  }

  void _validateOtp() {
    if (_otpController.text.length < 4) {
      _triggerErrorEffect();
    } else {
      print("OTP Validé: ${_otpController.text}");
    }
  }

  @override
  Widget build(BuildContext context) {
    String title = (widget.lang == "FR") ? "Vérification" : "Verification";
    String subtitle = (widget.lang == "FR") 
        ? "Saisissez le code à 4 chiffres envoyé sur votre mobile" 
        : "Enter the 4-digit code sent to your mobile";
    String resendText = (widget.lang == "FR") ? "Je n'ai pas reçu de code" : "I didn't receive a code";
    String confirmBtn = (widget.lang == "FR") ? "Confirmer" : "Confirm";
    String errorMsg = (widget.lang == "FR") ? "Code incorrect" : "Invalid code";

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
              Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 16, height: 1.4)),
              const SizedBox(height: 40),

              // ZONE OTP CENTRÉE
              Stack(
                alignment: Alignment.centerLeft,
                children: [
                  TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    maxLength: 4,
                    showCursor: false,
                    style: const TextStyle(color: Colors.transparent),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      counterText: "",
                      border: InputBorder.none,
                    ),
                  ),
                  IgnorePointer(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center, // CENTRE LES BARRES
                      children: List.generate(4, (index) {
                        bool hasChar = _currentValue.length > index;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0), // ESPACE ENTRE BARRES
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                hasChar ? _currentValue[index] : "",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: feedbackColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: 45, 
                                height: 3,
                                color: _hasError 
                                    ? Colors.red 
                                    : (hasChar ? Colors.black : Colors.grey[300]),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              // MESSAGE D'ERREUR (ALIGNE AVEC LE RESTE)
              AnimatedOpacity(
                opacity: _hasError ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Center( // On centre aussi le message d'erreur pour suivre les barres
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
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
              ),

              const SizedBox(height: 25),

              Center( // On centre le bouton "Renvoyer"
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    resendText,
                    style: TextStyle(color: brandPink, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ),

              const Spacer(),

              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: ElevatedButton(
                    onPressed: _validateOtp,
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
                        Text(confirmBtn, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
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