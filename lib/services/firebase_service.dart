import 'package:firebase_database/firebase_database.dart';
import 'package:lock_item/models/location.dart';

class FirebaseService {
  final DatabaseReference dbRef;

  FirebaseService(this.dbRef);

  Stream<Location?> getLocations(String iotUID) {
    return dbRef.child('positions').child(iotUID).onChildAdded.map((event) {
      final data = event.snapshot.value as Map?;
      if (data == null) {
        print("El nodo para $iotUID está vacío.");
        return null;
      }

      try {
        return Location.fromMap(data);
      } catch (e) {
        print("Error al procesar datos para $iotUID: $e");
        return null;
      }
    });
  }
}
