import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:lock_item/models/location.dart';
import '../../services/firebase_service.dart';

class LocateProductScreen extends StatefulWidget {
  const LocateProductScreen({super.key, required this.iotUID});

  final String iotUID;

  @override
  State<LocateProductScreen> createState() => _LocateProductScreenState();
}

class _LocateProductScreenState extends State<LocateProductScreen> {
  final FirebaseService firebaseService =
  FirebaseService(FirebaseDatabase.instance.ref());
  List<Location> locationHistory = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    listenToLocations();
  }

  void listenToLocations() {
    firebaseService.getLocations(widget.iotUID).listen((locations) {
      setState(() {
        locationHistory = locations;
        isLoading = false; // Detener el indicador de carga
      });
    }, onError: (error) {
      setState(() {
        isLoading = false; // Detener el indicador de carga en caso de error
      });
      print("Error al escuchar datos de Firebase: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Localizar Producto'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : locationHistory.isEmpty
          ? const Center(
        child: Text(
          'No se encontraron ubicaciones válidas.',
          style: TextStyle(fontSize: 16),
        ),
      )
          : FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(
            locationHistory.last.latitude,
            locationHistory.last.longitude,
          ),
          initialZoom: 15.0,
        ),
        children: [
          TileLayer(
            urlTemplate:
            "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: locationHistory.map((location) {
              return Marker(
                point: LatLng(location.latitude, location.longitude),
                width: 80,
                height: 80,
                child: const Icon(
                  Icons.location_pin,
                  color: Colors.red,
                  size: 40.0,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
