import 'package:firebase_database/firebase_database.dart';
import 'package:lock_item/models/location.dart';

class FirebaseService {
  final DatabaseReference dbRef;

  FirebaseService(this.dbRef);

  Stream<List<Location>> getLocations(String iotUID) {
    return dbRef
        .child('positions')
        .child(iotUID)
        .onChildAdded
        .map((event) {
      final data = event.snapshot.value as Map?;
      if (data == null) {
        print("El nodo para $iotUID está vacío.");
        return [];
      }

      try {
        // Convertir cada entrada en un LocationModel
        final locations = [Location.fromMap(data)];

        print("Se encontraron ${locations.length} ubicaciones para $iotUID.");
        return locations;
      } catch (e) {
        print("Error al procesar datos para $iotUID: $e");
        return [];
      }
    });
  }
}
