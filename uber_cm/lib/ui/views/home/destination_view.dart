import 'package:flutter/material.dart';
import 'package:osm_nominatim/osm_nominatim.dart';
import 'dart:async'; // Nécessaire pour le Timer (Debounce)

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

  List<Place> _suggestions = [];
  bool _isLoading = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _pickupController = TextEditingController(text: widget.currentAddress);
  }

  // LOGIQUE DE RECHERCHE OPTIMISÉE
  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (value.length > 2) {
        setState(() => _isLoading = true);
        try {
          final nominatim = Nominatim(userAgent: 'uber_cm_app');

          final results = await nominatim.searchByName(
            query: value,
            limit: 6,
            addressDetails: true,
            countryCodes: ['cm'],
          );

          setState(() {
            _suggestions = results;
            _isLoading = false;
          });
        } catch (e) {
          setState(() => _isLoading = false);
          debugPrint("Erreur OSM : $e");
        }
      } else {
        setState(() {
          _suggestions = [];
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _destinationController.dispose();
    _debounce?.cancel();
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
                      enabled: false,
                    ),
                    const SizedBox(height: 12),
                    _buildInputBox(
                      controller: _destinationController,
                      icon: Icons.square,
                      iconColor: Colors.blue,
                      hint: isFR ? "Où allez-vous ?" : "Where to ?",
                      isDestination: true,
                      onChanged: _onSearchChanged,
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: Stack(
              children: [
                // 1. Liste des suggestions
                if (_suggestions.isNotEmpty)
                  ListView.builder(
                    itemCount: _suggestions.length,
                    itemBuilder: (context, index) {
                      final place = _suggestions[index];
                      return _buildHistoryTile(
                        place.displayName.split(',')[0],
                        place.displayName,
                        Icons.location_on,
                        onTap: () {
                          // ON RENVOIE L'OBJET PLACE À HOME_VIEW
                          Navigator.pop(context, place);
                        },
                      );
                    },
                  )
                // 2. Liste par défaut (Favoris)
                else if (!_isLoading)
                  ListView(
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
                        padding: EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 5,
                        ),
                        child: Divider(),
                      ),
                      _buildHistoryTile(
                        "FKC Joint",
                        "2972 Westheimer Rd...",
                        Icons.history,
                      ),
                      _buildHistoryTile(
                        "Eneo Office",
                        "6391 poste centrale...",
                        Icons.history,
                      ),
                    ],
                  ),

                // 3. Indicateur de chargement
                if (_isLoading)
                  const Positioned(
                    top: 20,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF111727),
                      ),
                    ),
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

  // --- WIDGETS DE CONSTRUCTION ---
  Widget _buildInputBox({
    required TextEditingController controller,
    required IconData icon,
    required Color iconColor,
    required String hint,
    bool isDestination = false,
    bool enabled = true,
    Function(String)? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: enabled ? Colors.grey[100] : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        autofocus: isDestination,
        onChanged: onChanged,
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
    IconData leadingIcon, {
    VoidCallback? onTap,
  }) {
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
        overflow: TextOverflow.ellipsis,
      ),
      onTap: onTap,
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
