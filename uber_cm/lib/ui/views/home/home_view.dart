import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/location_provider.dart';
import 'maps_view.dart';
import '../account/account_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _currentIndex = 0;

  // Liste des différentes vues pour la navigation
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomeMainContent(), // Contenu principal de l'accueil
      const DevelopmentPlaceholder(title: "Services"),
      const DevelopmentPlaceholder(title: "Activité"),
      const AccountView(), // Page compte que nous avons créée
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: "Accueil",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view),
            label: "Services",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: "Activité",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Compte"),
        ],
      ),
    );
  }
}

// --- CONTENU PRINCIPAL DE L'ACCUEIL ---
class HomeMainContent extends StatelessWidget {
  const HomeMainContent({super.key});

  @override
  Widget build(BuildContext context) {
    final locationProv = Provider.of<LocationProvider>(context);

    return SingleChildScrollView(
      child: Column(
        children: [
          // Header & Recherche
          Container(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Uber CM",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 25),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MapsView()),
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
                            locationProv.currentAddress.isNotEmpty &&
                                    locationProv.currentAddress !=
                                        "Localisation en cours..."
                                ? locationProv.currentAddress
                                : "Où allez-vous ?",
                            style: TextStyle(
                              fontSize: 18,
                              color: locationProv.currentAddress.isNotEmpty
                                  ? Colors.black
                                  : Colors.grey[700],
                              fontWeight: FontWeight.w500,
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

          // Services
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildServiceCard(
                  context,
                  "Course",
                  Icons.directions_car,
                  Colors.blue[50]!,
                ),
                _buildServiceCard(
                  context,
                  "Colis",
                  Icons.inventory_2,
                  Colors.green[50]!,
                ),
                _buildServiceCard(
                  context,
                  "Réserver",
                  Icons.calendar_month,
                  Colors.orange[50]!,
                ),
              ],
            ),
          ),

          // Suggestions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Suggestions",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                _buildLocationItem(
                  Icons.history,
                  "Dernière destination",
                  "Carrefour Bastos, Yaoundé",
                ),
                const Divider(),
                _buildLocationItem(Icons.home, "Maison", "Entrée Simbock"),
                const Divider(),
                _buildLocationItem(
                  Icons.star,
                  "Lieux enregistrés",
                  "Gérez vos favoris",
                  isAction: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
  ) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MapsView()),
      ),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 80,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, size: 35, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildLocationItem(
    IconData icon,
    String title,
    String subtitle, {
    bool isAction = false,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: Colors.grey[200],
        child: Icon(icon, color: Colors.black87, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right, size: 20),
    );
  }
}

// --- WIDGET POUR LES PAGES EN DÉVELOPPEMENT ---
class DevelopmentPlaceholder extends StatelessWidget {
  final String title;
  const DevelopmentPlaceholder({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 20),
            Text(
              "Section $title",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "En cours de développement...",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
