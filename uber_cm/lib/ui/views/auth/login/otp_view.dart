import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:provider/provider.dart';
import '../../../../data/providers/user_provider.dart';
import '../../home/home_view.dart'; 

class OtpView extends StatefulWidget {
  final String lang;
  final String phone;

  const OtpView({super.key, required this.lang, required this.phone});

  @override
  State<OtpView> createState() => _OtpViewState();
}

class _OtpViewState extends State<OtpView> {
  final Color brandPink = const Color(0xFFE91E63);
  final TextEditingController _otpController = TextEditingController();
  String _currentValue = "";
  bool _hasError = false;
  bool _isLoading = false;
  Timer? _timer;
  int _start = 30;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _otpController.addListener(() {
      setState(() {
        _currentValue = _otpController.text;
        if (_hasError) _hasError = false;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _startTimer() {
    setState(() { _canResend = false; _start = 30; });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start == 0) {
        if (mounted) setState(() { timer.cancel(); _canResend = true; });
      } else {
        if (mounted) setState(() { _start--; });
      }
    });
  }

  void _triggerErrorEffect() {
    setState(() => _hasError = true);
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) setState(() => _hasError = false);
    });
  }

  // --- AJOUT DE LA FONCTION DE RENVOI ---
  Future<void> _resendCode() async {
    if (!_canResend || _isLoading) return;
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('https://uberbackend-production-e8ea.up.railway.app/api/auth/request-otp'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"phone": widget.phone}),
      ).timeout(const Duration(seconds: 15));

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.lang == "FR" ? "Code renvoyé !" : "Code resent !"), backgroundColor: Colors.green),
        );
        _startTimer();
      } else {
        _triggerErrorEffect();
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      _triggerErrorEffect();
    }
  }

  Future<void> _validateOtp() async {
    if (_otpController.text.length < 4) {
      _triggerErrorEffect();
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('https://uberbackend-production-e8ea.up.railway.app/api/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': widget.phone,
          'code': _otpController.text.trim(),
        }),
      ).timeout(const Duration(seconds: 15));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final userData = data['user'];
        
        // Extraction des données
        final String id = userData?['id']?.toString() ?? "";
        final String name = userData?['name'] ?? "Utilisateur Uber";
        final String phone = userData?['phone'] ?? widget.phone;

        // ✅ CORRECTION : Ajout de l'ID en premier argument
        await Provider.of<UserProvider>(context, listen: false)
            .setUser(id, name, phone);

        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context, 
          MaterialPageRoute(builder: (context) => const HomeView()),
          (route) => false,
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

  @override
  Widget build(BuildContext context) {
    String title = (widget.lang == "FR") ? "Vérification" : "Verification";
    String subtitle = (widget.lang == "FR")
        ? "Saisissez le code envoyé au ${widget.phone}"
        : "Enter the code sent to ${widget.phone}";
    String resendText = (widget.lang == "FR") ? "Renvoyer le code" : "Resend code";
    String confirmBtn = (widget.lang == "FR") ? "Confirmer" : "Confirm";
    Color feedbackColor = _hasError ? Colors.red : Colors.black;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Align(alignment: Alignment.centerLeft, child: Text(title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold))),
              const SizedBox(height: 12),
              Align(alignment: Alignment.centerLeft, child: Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 16))),
              const SizedBox(height: 60),
              Stack(
                alignment: Alignment.center,
                children: [
                  TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    maxLength: 4,
                    showCursor: false,
                    style: const TextStyle(color: Colors.transparent),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(counterText: "", border: InputBorder.none),
                  ),
                  IgnorePointer(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(4, (index) {
                        bool hasChar = _currentValue.length > index;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Column(
                            children: [
                              Text(hasChar ? _currentValue[index] : "", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: feedbackColor)),
                              const SizedBox(height: 8),
                              Container(width: 40, height: 3, color: _hasError ? Colors.red : (hasChar ? Colors.black : Colors.grey[200])),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              
              // --- CORRECTION DU BOUTON ICI ---
              TextButton(
                onPressed: (_isLoading || !_canResend) ? null : _resendCode, // <-- Appel à _resendCode
                child: Text(
                  _canResend ? resendText : "$resendText ($_start s)",
                  style: TextStyle(
                    color: _canResend ? brandPink : Colors.grey, 
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),

              const Spacer(),
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _validateOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _hasError ? Colors.red : brandPink,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: _isLoading 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Row(mainAxisSize: MainAxisSize.min, children: [Text(confirmBtn, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)), const SizedBox(width: 10), const Icon(Icons.arrow_forward_rounded, color: Colors.white)]),
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