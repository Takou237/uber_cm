import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/user_provider.dart';
import '../auth/welcome_view.dart'; // Import indispensable pour la redirection

class AccountView extends StatelessWidget {
  const AccountView({super.key});

  @override
  Widget build(BuildContext context) {
    final userProv = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Compte", 
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.black12,
                    child: Icon(Icons.person, size: 50, color: Colors.black54),
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userProv.name, 
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)
                      ),
                      const SizedBox(height: 5),
                      Text(
                        userProv.phone.isNotEmpty ? userProv.phone : "Aucun numéro",
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      _buildRatingBadge(),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(),

            _buildMenuItem(Icons.wallet, "Paiement", "Espèces, Orange Money, MoMo"),
            _buildMenuItem(Icons.history, "Mes trajets", "Consultez l'historique"),
            _buildMenuItem(Icons.card_giftcard, "Promotions", "Codes promos et parrainage"),
            _buildMenuItem(Icons.help, "Support", "Aide et assistance en ligne"),
            _buildMenuItem(Icons.settings, "Paramètres", "Langue, mode sombre, confidentialité"),
            
            const SizedBox(height: 30),
            
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                "Déconnexion", 
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)
              ),
              onTap: () => _showLogoutDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, size: 14, color: Colors.black),
          SizedBox(width: 4),
          Text("5.0", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 13)),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: () {},
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Déconnexion"),
        content: const Text("Voulez-vous vraiment vous déconnecter ? Cela effacera vos données de session."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text("ANNULER", style: TextStyle(color: Colors.grey))
          ),
          TextButton(
            onPressed: () async {
              // 1. Fermer la boîte de dialogue
              Navigator.pop(context);
              
              // 2. Appeler la déconnexion via le Provider
              await Provider.of<UserProvider>(context, listen: false).logout();
              
              // 3. Rediriger vers WelcomeView et vider la pile de navigation
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context, 
                  MaterialPageRoute(builder: (context) => const WelcomeView()),
                  (route) => false, // Efface tout l'historique
                );
              }
            }, 
            child: const Text("OUI, DÉCONNEXION", style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );
  }
}