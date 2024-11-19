import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class LocateProductScreen extends StatefulWidget {
  const LocateProductScreen({super.key, required this.iotUID});

  final String iotUID; // Identificador IoT del producto

  @override
  State<LocateProductScreen> createState() => _LocateProductScreenState();
}

class _LocateProductScreenState extends State<LocateProductScreen> {
  final DatabaseReference dbRef = FirebaseDatabase.instance.ref();
  Map<String, dynamic>? latestLocation;

  @override
  void initState() {
    super.initState();
    fetchLatestLocation();
  }

  void fetchLatestLocation() {
    dbRef.child(widget.iotUID).limitToLast(1).onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data != null) {
        final latestKey = data.keys.last;
        setState(() {
          latestLocation = data[latestKey];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Localizar Producto'),
      ),
      body: latestLocation == null
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(
            latestLocation!['latitude'],
            latestLocation!['longitude'],
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
            markers: [
              Marker(
                point: LatLng(
                  latestLocation!['latitude'],
                  latestLocation!['longitude'],
                ),
                width: 80,
                height: 80,
                child: GestureDetector(
                  onTap: () {
                    // Mostrar información adicional al hacer clic en el marcador
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text("Información del Producto"),
                        content: Text(
                            "Coordenadas: (${latestLocation!['latitude']}, ${latestLocation!['longitude']})"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(ctx).pop();
                            },
                            child: const Text("Cerrar"),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Icon(
                    Icons.location_pin,
                    color: Colors.red,
                    size: 40.0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
