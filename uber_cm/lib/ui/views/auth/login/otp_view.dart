import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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

  void _navigateToHome() {
    Navigator.pushAndRemoveUntil(
      context, 
      MaterialPageRoute(builder: (context) => HomeView(lang: widget.lang)),
      (route) => false,
    );
  }

  Future<void> _validateOtp() async {
    if (_otpController.text.length < 4) {
      _triggerErrorEffect();
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('https://uberbackend-production-e8ea.up.railway.app/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': widget.phone,
          'code': _otpController.text,
        }),
      );

      if (!mounted) return;

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        _navigateToHome();
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
    String confirmBtn = (widget.lang == "FR") ? "Confirmer" : "Confirm";
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
                            Container(width: 40, height: 3, color: _hasError ? Colors.red : (hasChar ? Colors.black : Colors.grey[200])),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _validateOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _hasError ? Colors.red : brandPink,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: _isLoading 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(confirmBtn, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}