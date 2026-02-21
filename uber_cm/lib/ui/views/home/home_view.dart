import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/location_provider.dart'; // Vérifie que le chemin est correct
import 'maps_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    // Utilisation du Provider pour récupérer l'adresse actuelle
    final locationProv = Provider.of<LocationProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // PARTIE SUPÉRIEURE : Header & Barre de recherche
            Container(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05), 
                    blurRadius: 10
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Uber CM", 
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)
                  ),
                  const SizedBox(height: 25),
                  
                  // Barre de recherche interactive
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (_) => const MapsView())
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search, size: 30, color: Colors.black),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Text(
                              // Affiche l'adresse du provider ou le texte par défaut
                              locationProv.currentAddress.isNotEmpty && 
                                      locationProv.currentAddress != "Localisation en cours..."
                                  ? locationProv.currentAddress
                                  : "Où allez-vous ?",
                              style: TextStyle(
                                fontSize: 18, 
                                color: locationProv.currentAddress.isNotEmpty 
                                    ? Colors.black 
                                    : Colors.grey[700], 
                                fontWeight: FontWeight.w500
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // SECTION SERVICES (Icones horizontales)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildServiceCard(context, "Course", Icons.directions_car, Colors.blue[50]!),
                  _buildServiceCard(context, "Colis", Icons.inventory_2, Colors.green[50]!),
                  _buildServiceCard(context, "Réserver", Icons.calendar_month, Colors.orange[50]!),
                ],
              ),
            ),

            // SECTION SUGGESTIONS / FAVORIS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Suggestions", 
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                  ),
                  const SizedBox(height: 15),
                  _buildLocationItem(
                    Icons.history, 
                    "Dernière destination", 
                    "Carrefour Bastos, Yaoundé",
                  ),
                  const Divider(),
                  _buildLocationItem(
                    Icons.home, 
                    "Maison", 
                    "Entrée Simbock",
                  ),
                  const Divider(),
                  _buildLocationItem(
                    Icons.star, 
                    "Lieux enregistrés", 
                    "Gérez vos adresses favorites",
                    isAction: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      
      // BARRE DE NAVIGATION INFÉRIEURE
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Accueil"),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: "Services"),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: "Activité"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Compte"),
        ],
      ),
    );
  }

  // Widget pour les cartes de services (Course, Colis, etc.)
  Widget _buildServiceCard(BuildContext context, String title, IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
        if (title == "Course") {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const MapsView()));
        }
      },
      child: Column(
        children: [
          Container(
            width: 100,
            height: 80,
            decoration: BoxDecoration(
              color: color, 
              borderRadius: BorderRadius.circular(15)
            ),
            child: Icon(icon, size: 35, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // Widget pour les lignes d'adresses favorites
  Widget _buildLocationItem(IconData icon, String title, String subtitle, {bool isAction = false}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: Colors.grey[200],
        child: Icon(icon, color: Colors.black87, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: () {
        // Logique pour sélectionner l'adresse
      },
    );
  }
}
