import 'package:flutter/material.dart';

class DestinationView extends StatefulWidget {
  final String lang;
  final String currentAddress;

  const DestinationView({
    super.key,
    required this.lang,
    this.currentAddress = "",
  });

  @override
  State<DestinationView> createState() => _DestinationViewState();
}

class _DestinationViewState extends State<DestinationView> {
  late TextEditingController _pickupController;
  final TextEditingController _destinationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialisation avec l'adresse reçue de HomeView
    _pickupController = TextEditingController(text: widget.currentAddress);
  }

  // MISE À JOUR : Permet de mettre à jour le champ si l'adresse change pendant que la vue est ouverte
  @override
  void didUpdateWidget(covariant DestinationView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentAddress != widget.currentAddress) {
      _pickupController.text = widget.currentAddress;
    }
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isFR = widget.lang.toUpperCase() == "FR";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isFR ? "Destination" : "Destination",
          style: const TextStyle(
            color: Color(0xFF111727),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: Stack(
              children: [
                Positioned(
                  left: 19,
                  top: 35,
                  bottom: 35,
                  child: Container(width: 1, color: Colors.grey[300]),
                ),
                Column(
                  children: [
                    _buildInputBox(
                      controller: _pickupController,
                      icon: Icons.circle,
                      iconColor: const Color(0xFF111727),
                      hint: isFR ? "Lieu de départ" : "Pick up location",
                      enabled:
                          false, // Empêche la modification manuelle pour rester sur le GPS
                    ),
                    const SizedBox(height: 12),
                    _buildInputBox(
                      controller: _destinationController,
                      icon: Icons.square,
                      iconColor: Colors.blue,
                      hint: isFR ? "Où allez-vous ?" : "Where to ?",
                      isDestination: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              children: [
                _buildFavoriteAction(
                  Icons.home,
                  isFR ? "Ajouter Maison" : "Add Home",
                ),
                _buildFavoriteAction(
                  Icons.work,
                  isFR ? "Ajouter Travail" : "Add Work",
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  child: Divider(),
                ),
                _buildHistoryTile(
                  "FKC Joint",
                  "2972 Westheimer Rd. Santa Ana, Illinois",
                  Icons.history,
                ),
                _buildHistoryTile(
                  "Eneo Office",
                  "6391 poste centrale, Delaware 10299",
                  Icons.history,
                ),
                _buildHistoryTile(
                  "Mimba Jouvance",
                  "Yaoundé, Cameroun",
                  Icons.location_on,
                ),
              ],
            ),
          ),
          _buildBottomMapButton(
            isFR ? "Choisir sur la carte" : "Set location on the map",
          ),
        ],
      ),
    );
  }

  Widget _buildInputBox({
    required TextEditingController controller,
    required IconData icon,
    required Color iconColor,
    required String hint,
    bool isDestination = false,
    bool enabled = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: enabled
            ? Colors.grey[100]
            : Colors.grey[50], // Plus clair si désactivé
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        autofocus: isDestination,
        style: TextStyle(
          color: enabled ? Colors.black87 : Colors.grey[600],
          fontSize: 15,
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: iconColor, size: 14),
          suffixIcon: isDestination
              ? const Icon(Icons.add, size: 20, color: Colors.black)
              : null,
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildFavoriteAction(IconData icon, String title) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(6),
        decoration: const BoxDecoration(
          color: Color(0xFFF04B5E),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: () {},
    );
  }

  Widget _buildHistoryTile(
    String title,
    String subtitle,
    IconData leadingIcon,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          shape: BoxShape.circle,
        ),
        child: Icon(leadingIcon, color: Colors.grey[600], size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.grey, fontSize: 13),
      ),
      onTap: () {},
    );
  }

  Widget _buildBottomMapButton(String label) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: const BoxDecoration(
          color: Color(0xFF111727),
          borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.person_pin_circle_outlined,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
