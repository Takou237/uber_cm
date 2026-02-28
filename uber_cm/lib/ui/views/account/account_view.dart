import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/user_provider.dart';
import '../auth/welcome_view.dart';
import 'personal_info_view.dart'; // ✅ Désormais utilisé
import 'help_support_view.dart'; // ✅ Désormais utilisé

class AccountView extends StatelessWidget {
  const AccountView({super.key});

  @override
  Widget build(BuildContext context) {
    final userProv = Provider.of<UserProvider>(context);
    const Color darkPink = Color(0xFFF04B5E);
    const Color bgLight = Colors.white;

    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: bgLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Mon Compte", 
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            Center(
              child: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: darkPink, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: userProv.localImage != null 
                          ? FileImage(userProv.localImage!) as ImageProvider
                          : (userProv.profileImage != null 
                              ? NetworkImage(userProv.profileImage!) 
                              : null),
                      child: (userProv.localImage == null && userProv.profileImage == null)
                          ? const Icon(Icons.person, size: 70, color: Colors.grey) 
                          : null,
                    ),
                  ),
                  Positioned(
                    bottom: 5,
                    right: 5,
                    child: GestureDetector(
                      onTap: () => _showImagePickerOptions(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: darkPink,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),
            Text(
              userProv.name,
              style: const TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            
            const SizedBox(height: 30),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildAccountItem(
                    Icons.person_outline, 
                    "Informations personnelles", 
                    null, 
                    () {
                      // ✅ Décommenté pour activer la navigation
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const PersonalInfoView()));
                    }
                  ),
                  _buildAccountItem(
                    Icons.account_balance_wallet_outlined, 
                    "Méthodes de paiement", 
                    "MoMo / Orange Money", 
                    () {}
                  ),
                  _buildAccountItem(
                    Icons.settings_outlined, 
                    "Paramètres", 
                    null, 
                    () {}
                  ),
                  _buildAccountItem(
                    Icons.help_outline, 
                    "Aide et commentaire", 
                    null, 
                    () {
                      // ✅ Décommenté pour activer la navigation
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpSupportView()));
                    }
                  ),
                  _buildAccountItem(
                    Icons.card_giftcard, 
                    "Parrainage", 
                    "BONUS", 
                    () {},
                    isBonus: true
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            TextButton.icon(
              onPressed: () => _showLogoutDialog(context),
              icon: const Icon(Icons.logout, color: Colors.black54, size: 20),
              label: const Text(
                "Déconnexion",
                style: TextStyle(color: Colors.black54, fontSize: 16),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountItem(IconData icon, String title, String? subtitle, VoidCallback onTap, {bool isBonus = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.black87, size: 22),
        ),
        title: Text(
          title, 
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500)
        ),
        subtitle: subtitle != null 
          ? Text(subtitle, style: const TextStyle(color: Colors.black38, fontSize: 12)) 
          : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isBonus)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF04B5E).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text("BONUS", style: TextStyle(color: Color(0xFFF04B5E), fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            const Icon(Icons.arrow_forward_ios, color: Colors.black26, size: 14),
          ],
        ),
      ),
    );
  }

  // ... (Garde tes méthodes _showImagePickerOptions et _showLogoutDialog identiques)
  void _showImagePickerOptions(BuildContext context) {
    final userProv = Provider.of<UserProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          ListTile(
            leading: const Icon(Icons.camera_alt, color: Colors.black87),
            title: const Text("Prendre une photo"),
            onTap: () {
              Navigator.pop(context);
              userProv.pickAndUploadImage(ImageSource.camera);
            },
          ),
          ListTile(
            leading: const Icon(Icons.image, color: Colors.black87),
            title: const Text("Choisir dans la galerie"),
            onTap: () {
              Navigator.pop(context);
              userProv.pickAndUploadImage(ImageSource.gallery);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Déconnexion"),
        content: const Text("Voulez-vous vraiment vous déconnecter ?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("ANNULER", style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await Provider.of<UserProvider>(context, listen: false).logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context, 
                  MaterialPageRoute(builder: (context) => const WelcomeView()),
                  (route) => false,
                );
              }
            }, 
            child: const Text("DÉCONNEXION", style: TextStyle(color: Color(0xFFF04B5E)))
          ),
        ],
      ),
    );
  }
}