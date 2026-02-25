import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pinput/pinput.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/user_provider.dart'; // Assure-toi que ce chemin correspond à ton dossier data/providers
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

  // ✅ NOUVEAU : On centralise la logique de vérification ici pour l'utiliser à 2 endroits
  Future<void> _verifyCode(
    String pin,
    AuthProvider authProv,
    UserProvider userProv,
    bool isFr,
  ) async {
    if (pin.length < 6) return; // Sécurité si le code est trop court

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    // 1. On reçoit les données depuis Railway
    final driverData = await authProv.verifyDriverOTP(pin);

    if (!mounted) return;

    if (driverData != null) {
      // 2. On sauvegarde l'ID pour que la carte (HomeView) sache qui est connecté !
      await userProv.saveUserData(
        id: driverData['id'].toString(),
        name: driverData['name'] ?? "Chauffeur",
        phone: driverData['phone'] ?? "",
        plate: driverData['plate'] ?? "",
      );

      // 3. Redirection intelligente
      if (authProv.isProfileComplete) {
        navigator.pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeView()),
          (route) => false,
        );
      } else {
        navigator.pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const VehiclePreferenceView(),
          ),
          (route) => false,
        );
      }
    } else {
      messenger.showSnackBar(
        SnackBar(content: Text(isFr ? "Code incorrect" : "Invalid code")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProv = Provider.of<AuthProvider>(context);
    final userProv = Provider.of<UserProvider>(context, listen: false);
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
                  textStyle: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                // ✅ Appel de notre fonction quand les 6 chiffres sont tapés
                onCompleted: (pin) =>
                    _verifyCode(pin, authProv, userProv, isFr),
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                // ✅ Appel de notre fonction quand on clique sur le bouton !
                onPressed: authProv.isLoading
                    ? null
                    : () => _verifyCode(
                        _otpController.text,
                        authProv,
                        userProv,
                        isFr,
                      ),
                child: authProv.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        isFr ? "Vérifier" : "Verify",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
