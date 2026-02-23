import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../providers/auth_provider.dart';
import 'registration_success_view.dart';

class DocumentSelectionView extends StatefulWidget {
  // ✅ On reçoit les données du véhicule ici
  final Map<String, String> vehicleData;

  const DocumentSelectionView({super.key, required this.vehicleData});

  @override
  State<DocumentSelectionView> createState() => _DocumentSelectionViewState();
}

class _DocumentSelectionViewState extends State<DocumentSelectionView> {
  final ImagePicker _picker = ImagePicker();
  
  final Map<String, File?> _files = {
    "license": null,
    "insurance": null,
    "id_card": null,
    "vehicle_photo": null,
  };

  Future<void> _pickImage(String key, ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source, imageQuality: 70);
    if (pickedFile != null) {
      setState(() {
        _files[key] = File(pickedFile.path);
      });
    }
  }

  // Fonction pour envoyer les données au backend
  Future<void> _handleUpload(AuthProvider authProv, bool isFr) async {
    final success = await authProv.completeVehicleRegistration(
      brand: widget.vehicleData['brand']!,
      model: widget.vehicleData['model']!,
      year: widget.vehicleData['year']!,
      color: widget.vehicleData['color']!,
      plate: widget.vehicleData['plate']!,
      files: _files,
    );

    if (success) {
      // ✅ Aller vers l'étape 4 ou l'accueil
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isFr ? "Inscription réussie !" : "Registration successful!")),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const RegistrationSuccessView()),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isFr ? "Erreur lors de l'envoi" : "Upload failed")),
        );
      }
    }
  }

  void _showImageSourceSheet(String key, bool isFr) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(isFr ? "Sélectionner la source" : "Select Source", 
                 style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.black),
              title: Text(isFr ? "Appareil photo" : "Camera"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(key, ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.black),
              title: Text(isFr ? "Galerie photo" : "Photo Gallery"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(key, ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProv = Provider.of<AuthProvider>(context);
    final isFr = authProv.language == "fr";

    bool allUploaded = _files.values.every((f) => f != null);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(isFr ? "Documents" : "Documents", 
             style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isFr ? "Étape 3 sur 4" : "Step 3 of 4", style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 10),
            Text(isFr ? "Vérification du profil" : "Profile Verification",
                 style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),

            _buildDocumentTile(
              keyName: "license",
              title: isFr ? "Permis de conduire" : "Driver's License",
              subtitle: isFr ? "Photo recto nette du permis" : "Clear front photo of license",
              file: _files["license"],
              isFr: isFr,
            ),
            _buildDocumentTile(
              keyName: "insurance",
              title: isFr ? "Assurance" : "Insurance",
              subtitle: isFr ? "Document d'assurance valide" : "Valid insurance document",
              file: _files["insurance"],
              isFr: isFr,
            ),
            _buildDocumentTile(
              keyName: "vehicle_photo",
              title: isFr ? "Photo du véhicule" : "Vehicle Photo",
              subtitle: isFr ? "Vue d'ensemble avec plaque" : "Full view with plate",
              file: _files["vehicle_photo"],
              isFr: isFr,
            ),
            _buildDocumentTile(
              keyName: "id_card",
              title: isFr ? "Une photo de vous" : "A photo of you",
              subtitle: isFr ? "Une photo de phase et pas de profile" : "A photo of the phase, not a profile.",
              file: _files["id_card"],
              isFr: isFr,
            ),
            

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: (allUploaded && !authProv.isLoading) 
                    ? () => _handleUpload(authProv, isFr) 
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: allUploaded ? Colors.black : Colors.grey[200],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: authProv.isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      isFr ? "Continuer" : "Continue",
                      style: TextStyle(
                        color: allUploaded ? Colors.white : Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 16
                      ),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentTile({
    required String keyName,
    required String title,
    required String subtitle,
    required File? file,
    required bool isFr,
  }) {
    bool hasFile = file != null;

    return GestureDetector(
      onTap: () => _showImageSourceSheet(keyName, isFr),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: hasFile ? Colors.green : Colors.grey.shade300, width: 1.5),
          color: hasFile ? Colors.green.withValues(alpha: 0.02) : Colors.white,
        ),
        child: Row(
          children: [
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
                image: hasFile ? DecorationImage(image: FileImage(file), fit: BoxFit.cover) : null,
              ),
              child: !hasFile ? const Icon(Icons.camera_enhance_outlined, color: Colors.grey) : null,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                ],
              ),
            ),
            Icon(
              hasFile ? Icons.check_circle : Icons.add_circle_outline,
              color: hasFile ? Colors.green : Colors.black,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }
}