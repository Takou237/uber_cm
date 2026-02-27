import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:developer';
import 'dart:async';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/language_provider.dart';
import '../../../../providers/user_provider.dart';
import '../../Enregistrement/vehicle_preference_view.dart';

class VerificationView extends StatefulWidget {
  const VerificationView({super.key});

  @override
  State<VerificationView> createState() => _VerificationViewState();
}

class _VerificationViewState extends State<VerificationView> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  bool _showError = false;
  Timer? _errorTimer;

  // --- ✅ FONCTION MISE À JOUR ---
  Future<void> _handleVerify() async {
    String fullCode = _controllers.map((c) => c.text).join();
    if (fullCode.length < 6) return;

    final authProv = Provider.of<AuthProvider>(context, listen: false);
    final driverData = await authProv.verifyDriverOTP(fullCode);

    // ✅ SÉCURITÉ : On vérifie si le widget est toujours "mounted" avant de continuer
    if (!mounted) return;

    if (driverData != null) {
      final userProv = Provider.of<UserProvider>(context, listen: false);
      await userProv.saveUserData(
        id: driverData['id'].toString(),
        name: driverData['name'] ?? "Chauffeur",
        phone: driverData['phone'] ?? "",
        plate: driverData['plate'] ?? "",
      );

      // ✅ Re-vérification après le deuxième await
      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const VehiclePreferenceView()),
        (route) => false,
      );
    } else {
      setState(() => _showError = true);
    }
  }

  @override
  void dispose() {
    _errorTimer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProv = Provider.of<AuthProvider>(context);
    final userEmail = authProv.userEmail;
    final langProv = Provider.of<LanguageProvider>(context);
    final bool isFr = langProv.currentLocale.languageCode == 'fr';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: authProv.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFE91E63)),
            )
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isFr
                        ? "Entrez le code de vérification"
                        : "Enter the verification code",
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A40),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isFr
                        ? "Nous avons envoyé un code à six chiffres à $userEmail"
                        : "We have sent you a six digit code on $userEmail",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 40),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, (index) => _otpBox(index)),
                  ),

                  const SizedBox(height: 25),

                  if (_showError)
                    Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isFr
                                ? "Code OTP incorrect, vérifiez et réessayez"
                                : "Incorrect OTP, please check and try again",
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),

                  const Spacer(),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => log("Renvoi du code..."),
                        child: Text(
                          isFr ? "Renvoyer le code" : "Resend code",
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _handleVerify,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE91E63),
                          foregroundColor: Colors.white,
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                        ),
                        child: Text(
                          isFr ? "S'inscrire" : "Sign up",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _otpBox(int index) {
    return Container(
      width: 40,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: _showError ? Colors.red : Colors.black,
            width: 2,
          ),
        ),
      ),
      child: TextField(
        controller: _controllers[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        onChanged: (value) {
          if (_showError) setState(() => _showError = false);
          if (value.isNotEmpty && index < 5) {
            FocusScope.of(context).nextFocus();
          } else if (value.isEmpty && index > 0) {
            FocusScope.of(context).previousFocus();
          }
        },
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: _showError ? Colors.red : Colors.black,
        ),
        decoration: const InputDecoration(
          counterText: "",
          border: InputBorder.none,
        ),
      ),
    );
  }
}
