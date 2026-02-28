import 'package:flutter/material.dart';

class HelpSupportView extends StatelessWidget {
  const HelpSupportView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Aide et commentaire", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          const Padding(
            padding: EdgeInsets.all(15),
            child: Text("Pages d'aide", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ),
          _helpTile(Icons.help_center_outlined, "Obtenir de l'aide"),
          _helpTile(Icons.mail_outline, "Nous contacter"),
          _helpTile(Icons.chat_bubble_outline, "Envoyer un commentaire"),
          _helpTile(Icons.report_problem_outlined, "Signaler des problèmes techniques"),
          _helpTile(Icons.privacy_tip_outlined, "Conditions et confidentialité"),
          _helpTile(Icons.info_outline, "Infos de l'application"),
        ],
      ),
    );
  }

  Widget _helpTile(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(title, style: const TextStyle(color: Colors.black)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      onTap: () {
        // Ajouter les liens ici
      },
    );
  }
}