import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/auth_provider.dart';
import 'otp_verification_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});
  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authProv = Provider.of<AuthProvider>(context);
    final isFr = authProv.language == "fr";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, 
        elevation: 0, 
        iconTheme: const IconThemeData(color: Colors.black)
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isFr ? "Bon retour !" : "Welcome back!", 
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 10),
            Text(
              isFr ? "Entrez votre email pour vous connecter" : "Enter your email to log in",
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: "Email", 
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.email_outlined),
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
                onPressed: authProv.isLoading ? null : () async {
                  // Capture des services avant l'appel asynchrone
                  final messenger = ScaffoldMessenger.of(context);
                  final navigator = Navigator.of(context);
                  final email = _emailController.text.trim();

                  if (email.isEmpty) return;

                  bool success = await authProv.loginChauffeur(email);
                  
                  // Sécurité anti-crash (async gap)
                  if (!mounted) return;

                  if (success) {
                    navigator.push(
                      MaterialPageRoute(builder: (context) => const OtpVerificationView(isLogin: true))
                    );
                  } else {
                    messenger.showSnackBar(
                      SnackBar(content: Text(isFr ? "Compte introuvable" : "Account not found"))
                    );
                  }
                },
                child: authProv.isLoading 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : Text(isFr ? "Suivant" : "Next", style: const TextStyle(color: Colors.white, fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }
}