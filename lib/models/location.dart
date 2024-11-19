class Location {
  final double latitude;
  final double longitude;
  final String date;

  Location({
    required this.latitude,
    required this.longitude,
    required this.date,
  });

  // Método para convertir desde el mapa de Firebase
  factory Location.fromMap(Map<dynamic, dynamic> map) {
    if (map['latitude'] == null || map['longitude'] == null) {
      throw Exception('Datos inválidos: latitude o longitude es null.');
    }
    return Location(
      latitude: (map['latitude'] as num).toDouble(), // Asegura que sea double
      longitude: (map['longitude'] as num).toDouble(), // Asegura que sea double
      date: map['date'] ?? 'Fecha no disponible', // Maneja fecha nula
    );
  }

  // Método para convertir a un mapa (si es necesario)
  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'date': date,
    };
  }
}
