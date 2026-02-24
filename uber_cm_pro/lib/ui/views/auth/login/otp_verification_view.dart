import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pinput/pinput.dart';
import '../../../../providers/auth_provider.dart';
import '../../Enregistrement/vehicle_preference_view.dart';
import '../../home/home_view.dart';

class OtpVerificationView extends StatefulWidget {
  final bool isLogin;
  const OtpVerificationView({super.key, this.isLogin = false});

  @override
  State<OtpVerificationView> createState() => _OtpVerificationViewState();
}

class _OtpVerificationViewState extends State<OtpVerificationView> {
  final TextEditingController _otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authProv = Provider.of<AuthProvider>(context);
    final isFr = authProv.language == "fr";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isFr ? "Vérification" : "Verification",
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              isFr 
                ? "Entrez le code envoyé à ${authProv.userEmail}" 
                : "Enter the code sent to ${authProv.userEmail}",
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            const SizedBox(height: 40),
            
            Center(
              child: Pinput(
                length: 6,
                controller: _otpController,
                defaultPinTheme: PinTheme(
                  width: 50,
                  height: 60,
                  textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onCompleted: (pin) async {
                  // ✅ 1. Capture du navigator et messenger AVANT le await
                  final navigator = Navigator.of(context);
                  final messenger = ScaffoldMessenger.of(context);

                  bool success = await authProv.verifyDriverOTP(pin);
                  
                  // ✅ 2. Vérification du mounted
                  if (!mounted) return;

                  if (success) {
                    if (authProv.isProfileComplete) {
                      navigator.pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const HomeView()),
                        (route) => false,
                      );
                    } else {
                      navigator.pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const VehiclePreferenceView()),
                        (route) => false,
                      );
                    }
                  } else {
                    messenger.showSnackBar(
                      SnackBar(content: Text(isFr ? "Code incorrect" : "Invalid code")),
                    );
                  }
                },
              ),
            ),
            
            const Spacer(),
            
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: authProv.isLoading ? null : () {
                  // Optionnel: Relancer manuellement la vérification avec le bouton
                },
                child: authProv.isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(isFr ? "Vérifier" : "Verify", style: const TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}