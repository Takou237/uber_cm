import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // ✅ Nécessaire pour quitter l'app proprement
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../../providers/auth_provider.dart';
import 'add_vehicle_view.dart';

class VehiclePreferenceView extends StatefulWidget {
  const VehiclePreferenceView({super.key});

  @override
  State<VehiclePreferenceView> createState() => _VehiclePreferenceViewState();
}

class _VehiclePreferenceViewState extends State<VehiclePreferenceView> {
  final PageController _pageController = PageController(viewportFraction: 0.9);

  @override
  Widget build(BuildContext context) {
    final authProv = Provider.of<AuthProvider>(context);
    final isFr = authProv.language == "fr";

    // ✅ PopScope permet de gérer le bouton "Retour" physique du téléphone
    return PopScope(
      canPop: false, // Empêche le retour en arrière classique vers l'auth
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        // ✅ Quitte complètement l'application si l'utilisateur fait "Retour"
        SystemNavigator.pop(); 
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          // ✅ Suppression du bouton de retour (leading) ici
          automaticallyImplyLeading: false, 
          title: Text(
            isFr ? "Inscription Chauffeur" : "Driver Registration",
            style: const TextStyle(color: Colors.black, fontSize: 18),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isFr ? "Étape 1 sur 4" : "Step 1 of 4",
                    style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isFr 
                      ? "Dites-nous votre préférence de véhicule" 
                      : "Tell us your vehicle preference",
                    style: const TextStyle(
                      fontSize: 26, 
                      fontWeight: FontWeight.bold, 
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: PageView(
                controller: _pageController,
                children: [
                  _buildPreferenceCard(
                    image: 'assets/images/driver_owner.png', 
                    title: isFr ? "J'ai un véhicule" : "I have a vehicle",
                    description: isFr 
                      ? "Vous possédez un véhicule (voiture, moto, taxi) que vous conduirez."
                      : "You own a vehicle (car, bike, taxi) you will drive.",
                    onTap: () {
                      authProv.setPreference("owner");
                      // ✅ Ici on laisse Navigator.push car on veut pouvoir revenir 
                      // de "AddVehicleView" vers cette page de préférence.
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AddVehicleView()),
                      );
                    },
                  ),

                  _buildPreferenceCard(
                    image: 'assets/images/driver_need.png',
                    title: isFr ? "Besoin d'un véhicule" : "Need a vehicle",
                    description: isFr
                      ? "Vous cherchez un partenaire pour vous confier un véhicule."
                      : "You are looking for a partner to provide a vehicle.",
                    onTap: () {
                      authProv.setPreference("renter");
                      // Logique pour renter...
                    },
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.only(bottom: 40, top: 20),
              child: Center(
                child: SmoothPageIndicator(
                  controller: _pageController,
                  count: 2,
                  effect: const ExpandingDotsEffect(
                    activeDotColor: Color.fromARGB(255, 0, 0, 0),
                    dotHeight: 10,
                    dotWidth: 10,
                    expansionFactor: 3,
                    spacing: 8,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Le widget _buildPreferenceCard reste identique à ton code original...
  Widget _buildPreferenceCard({
    required String image,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.asset(
                  image, 
                  width: double.infinity, 
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.directions_car, size: 50, color: Colors.grey),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title, 
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      description, 
                      style: TextStyle(color: Colors.grey[600], fontSize: 15, height: 1.4),
                    ),
                    const Spacer(),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: FloatingActionButton.small(
                        heroTag: title, 
                        onPressed: onTap,
                        backgroundColor: Colors.black,
                        child: const Icon(Icons.arrow_forward, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
