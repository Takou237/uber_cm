class DriverModel {
  final String id;
  final String name;
  final String vehicle; // Correspond à .vehicle dans MapsView
  final String plate; // Correspond à .plate dans MapsView
  final String? photoUrl; // Correspond à .photoUrl dans MapsView
  final double rating;

  DriverModel({
    required this.id,
    required this.name,
    required this.vehicle,
    required this.plate,
    this.photoUrl,
    this.rating = 4.5,
  });

  // Adaptation des données venant de ta base PostgreSQL (Railway)
  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      id: json['id'].toString(),
      name: json['nom'] ?? "Chauffeur",
      // On combine marque et modèle pour créer le champ 'vehicle'
      vehicle: "${json['marque'] ?? ''} ${json['modele'] ?? ''}".trim(),
      plate: json['immatriculation'] ?? "---",
      // Assure-toi que ta colonne image s'appelle 'photo_url' ou adapte ici
      photoUrl: json['photo_url'],
      rating: (json['note'] ?? 4.5).toDouble(),
    );
  }
}
