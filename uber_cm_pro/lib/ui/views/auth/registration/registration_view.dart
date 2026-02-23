import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:developer';
import '../../../../providers/language_provider.dart';
import '../../../../providers/auth_provider.dart'; // Nouveau Provider
import 'verification_view.dart'; // Import de la page OTP

class RegistrationView extends StatefulWidget {
  const RegistrationView({super.key});

  @override
  State<RegistrationView> createState() => _RegistrationViewState();
}

class _RegistrationViewState extends State<RegistrationView> {
  final Color brandPink = const Color(0xFFE91E63);
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  
  String? _selectedCity;
  bool _acceptTerms = false; 
  bool _isFormValid = false;

  final List<String> _cameroonCities = [
    "Douala", "Yaoundé", "Garoua", "Bamenda", "Maroua", 
    "Bafoussam", "Ngaoundéré", "Nkongsamba", "Buéa", "Bertoua"
  ];

  void _validateForm() {
    setState(() {
      _isFormValid = _nameController.text.isNotEmpty &&
          _emailController.text.contains('@') &&
          _emailController.text.length > 5 &&
          _phoneController.text.length >= 9 &&
          _selectedCity != null &&
          _acceptTerms == true;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final langProv = Provider.of<LanguageProvider>(context);
    final authProv = Provider.of<AuthProvider>(context, listen: false);
    final bool isFr = langProv.currentLocale.languageCode == 'fr';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A40)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isFr ? "Créer un Compte" : "Create an Account",
          style: const TextStyle(color: Color(0xFF1A1A40), fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInputField(isFr ? "Nom" : "Name", "e.g. MBARGA Paul", _nameController),
              const SizedBox(height: 20),
              _buildInputField(isFr ? "Adresse Email" : "Email Address", "paulmbarga@gmail.com", _emailController, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 20),
              
              Text(isFr ? "Numéro de téléphone" : "Phone Number", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 25,
                      child: Image.asset(
                        'assets/images/cm_flag.png',
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.flag, size: 20),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text("+237", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        onChanged: (_) => _validateForm(),
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          hintText: "6XX XX XX XX",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              _buildDropdownField(isFr ? "Ville" : "City", isFr ? "Sélectionnez votre ville" : "Select your city"),
              const SizedBox(height: 20),
              _buildInputField(isFr ? "Code de parrainage (Optionnel)" : "Referral Code (Optional)", "e.g. SFGEG4", TextEditingController()),
              
              const SizedBox(height: 25),
              
              // CASE À COCHER
              Row(
                children: [
                  Checkbox(
                    value: _acceptTerms,
                    activeColor: brandPink,
                    onChanged: (value) {
                      setState(() {
                        _acceptTerms = value ?? false;
                        _validateForm();
                      });
                    },
                  ),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(color: Colors.grey, fontSize: 13, height: 1.4),
                        children: [
                          TextSpan(text: isFr ? "J'accepte les " : "I accept the "),
                          TextSpan(
                            text: isFr ? "termes d'utilisation" : "terms of use", 
                            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)
                          ),
                          TextSpan(text: isFr ? " et la " : " and the "),
                          TextSpan(
                            text: isFr ? "politique de confidentialité" : "privacy policy", 
                            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 30),
              
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isFormValid ? () {
                    // SAUVEGARDE DE L'EMAIL ET NAVIGATION
                    authProv.setUserEmail(_emailController.text);
                    log("Email sauvegardé : ${_emailController.text}");
                    
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const VerificationView()),
                    );
                  } : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isFormValid ? brandPink : const Color(0xFFEEEEEE), 
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    isFr ? "Créer un Compte" : "Create an Account",
                    style: TextStyle(
                      color: _isFormValid ? Colors.white : Colors.grey, 
                      fontSize: 18, 
                      fontWeight: FontWeight.bold
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

  Widget _buildInputField(String label, String hint, TextEditingController controller, {TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          onChanged: (_) => _validateForm(),
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: _selectedCity,
              hint: Text(hint, style: const TextStyle(color: Colors.grey, fontSize: 14)),
              items: _cameroonCities.map((String city) {
                return DropdownMenuItem<String>(value: city, child: Text(city));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCity = value;
                  _validateForm();
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}