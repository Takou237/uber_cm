import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/auth_provider.dart';
import 'document_selection_view.dart'; // ✅ Assure-toi que le chemin est correct

class AddVehicleView extends StatefulWidget {
  const AddVehicleView({super.key});

  @override
  State<AddVehicleView> createState() => _AddVehicleViewState();
}

class _AddVehicleViewState extends State<AddVehicleView> {
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _plateController = TextEditingController();

  bool _isFormValid = false;
  bool _showOtherColorField = false;

  final List<String> _brands = [
    "Toyota", "Mercedes-Benz", "Hyundai", "Suzuki", "Honda", "Nissan", "Kia", 
    "Mitsubishi", "Volkswagen", "BMW", "Audi", "Ford", "Mazda", "Chevrolet", 
    "Peugeot", "Renault", "Dacia", "Land Rover", "Lexus", "Jeep", "Volvo", 
    "Fiat", "Opel", "Citroën", "Skoda", "Porsche", "Subaru", "Isuzu", "Chery", 
    "Changan", "Geely", "BYD", "Great Wall", "Dongfeng", "Sinotruk", "Iveco", 
    "DAF", "Man", "Scania", "Bajaj", "TVS"
  ];

  final Map<String, Map<String, String>> _colorTranslations = {
    "Black": {"fr": "Noir", "en": "Black"},
    "White": {"fr": "Blanc", "en": "White"},
    "Silver": {"fr": "Argent", "en": "Silver"},
    "Gray": {"fr": "Gris", "en": "Gray"},
    "Blue": {"fr": "Bleu", "en": "Blue"},
    "Red": {"fr": "Rouge", "en": "Red"},
    "Brown": {"fr": "Marron", "en": "Brown"},
    "Yellow": {"fr": "Jaune", "en": "Yellow"},
    "Green": {"fr": "Vert", "en": "Green"},
  };

  @override
  void initState() {
    super.initState();
    _brandController.addListener(_validate);
    _modelController.addListener(_validate);
    _yearController.addListener(_validate);
    _colorController.addListener(_validate);
    _plateController.addListener(_validate);
  }

  void _validate() {
    setState(() {
      _isFormValid = _brandController.text.isNotEmpty &&
          _modelController.text.isNotEmpty &&
          _yearController.text.isNotEmpty &&
          _colorController.text.isNotEmpty &&
          _plateController.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _colorController.dispose();
    _plateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProv = Provider.of<AuthProvider>(context);
    final isFr = authProv.language == "fr";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isFr ? "Inscription Chauffeur" : "Driver Registration",
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isFr ? "Étape 2 sur 4" : "Step 2 of 4", 
                 style: const TextStyle(color: Colors.grey, fontSize: 16)),
            const SizedBox(height: 8),
            Text(
              isFr ? "Ajoutez votre véhicule" : "Add your vehicle",
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 30),

            _buildLabel(isFr ? "Marque" : "Brand"),
            _buildAutocompleteField(_brands, _brandController, isFr ? "ex: Toyota ou tapez la vôtre" : "e.g. Toyota or type yours"),

            const SizedBox(height: 20),

            _buildLabel(isFr ? "Modèle" : "Model"),
            _buildTextField(_modelController, isFr ? "ex: Corolla" : "e.g. Corolla"),

            const SizedBox(height: 20),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel(isFr ? "Année" : "Year"),
                      _buildTextField(_yearController, "2016", keyboardType: TextInputType.number),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel(isFr ? "Couleur" : "Color"),
                      _buildColorDropdown(isFr),
                    ],
                  ),
                ),
              ],
            ),

            if (_showOtherColorField) ...[
              const SizedBox(height: 20),
              _buildLabel(isFr ? "Précisez la couleur" : "Specify color"),
              _buildTextField(_colorController, isFr ? "ex: Orange" : "e.g. Orange"),
            ],

            const SizedBox(height: 20),

            _buildLabel(isFr ? "Numéro d'immatriculation" : "Licence plate number"),
            _buildTextField(_plateController, "e.g. LT 000 AA"),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isFormValid ? () {
                  // ✅ Navigation vers l'étape 3 en passant les données
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DocumentSelectionView(
                        vehicleData: {
                          "brand": _brandController.text,
                          "model": _modelController.text,
                          "year": _yearController.text,
                          "color": _colorController.text,
                          "plate": _plateController.text,
                        },
                      ),
                    ),
                  );
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isFormValid ? Colors.black : const Color(0xFFF2F2F2),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(
                  isFr ? "Continuer" : "Continue",
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
    );
  }

  // --- WIDGETS DE CONSTRUCTION ---

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }

  Widget _buildColorDropdown(bool isFr) {
    String currentLang = isFr ? "fr" : "en";
    String? selectedValue;
    
    if (_colorTranslations.containsKey(_colorController.text)) {
      selectedValue = _colorController.text;
    } else if (_showOtherColorField) {
      selectedValue = "Other";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: selectedValue,
          hint: Text(isFr ? "Sélectionner" : "Select"),
          items: [
            ..._colorTranslations.keys.map((key) {
              return DropdownMenuItem(
                value: key,
                child: Text(_colorTranslations[key]![currentLang]!),
              );
            }),
            DropdownMenuItem(
              value: "Other", 
              child: Text(isFr ? "Autre..." : "Other...")
            ),
          ],
          onChanged: (val) {
            setState(() {
              if (val == "Other") {
                _showOtherColorField = true;
                _colorController.clear();
              } else {
                _showOtherColorField = false;
                _colorController.text = val!;
              }
            });
          },
        ),
      ),
    );
  }

  Widget _buildAutocompleteField(List<String> options, TextEditingController controller, String hint) {
    return RawAutocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text == '') return options;
        return options.where((String option) => option.toLowerCase().contains(textEditingValue.text.toLowerCase()));
      },
      onSelected: (String selection) => controller.text = selection,
      fieldViewBuilder: (context, fieldController, focusNode, onFieldSubmitted) {
        if (fieldController.text != controller.text && controller.text.isNotEmpty) {
           fieldController.text = controller.text;
        }
        fieldController.addListener(() => controller.text = fieldController.text);
        return _buildTextField(fieldController, hint, focusNode: focusNode);
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            child: SizedBox(
              height: 200,
              width: MediaQuery.of(context).size.width - 48,
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options.elementAt(index);
                  return ListTile(
                    title: Text(option),
                    onTap: () => onSelected(option),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {TextInputType keyboardType = TextInputType.text, FocusNode? focusNode}) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.grey)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
      ),
    );
  }
}