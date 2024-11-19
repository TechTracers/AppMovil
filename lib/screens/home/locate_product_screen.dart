import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:lock_item/models/location.dart';
import 'package:lock_item/shared/utils/location.dart';
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
  Location? productLocation;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    listenToLocations();
  }

  void listenToLocations() {
    firebaseService.getLocations(widget.iotUID).listen((locations) {
      setState(() {
        productLocation = locations;
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
          : productLocation == null
              ? const Center(
                  child: Text(
                    'No se encontraron ubicaciones válidas.',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : FutureBuilder<Position>(
                  future: determineCurrentPosition(),
                  builder:
                      (BuildContext context, AsyncSnapshot<Position> snapshot) {
                    if (snapshot.hasError || snapshot.connectionState != ConnectionState.done || snapshot.data == null) {
                      return const Center(
                        child: CircularProgressIndicator(
                        ),
                      );
                    }
                    if(snapshot.connectionState == ConnectionState.done && snapshot.data == null) {
                      // return algo para indicar que paso algo
                    }

                    final position = snapshot.data!;
                    return FlutterMap(
                      options: MapOptions(
                        initialCenter: LatLng(
                          productLocation!.latitude,
                          productLocation!.longitude,
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
                              point: LatLng(productLocation!.latitude,
                                  productLocation!.longitude),
                              width: 80,
                              height: 80,
                              child: const Icon(
                                Icons.location_pin,
                                color: Colors.red,
                                size: 40.0,
                              ),
                            ),
                            Marker(
                              point:
                                  LatLng(position.latitude, position.longitude),
                              width: 80,
                              height: 80,
                              child: const Icon(
                                Icons.location_pin,
                                color: Colors.green,
                                size: 40.0,
                              ),
                            )
                          ],
                        ),
                      ],
                    );
                  },
                ),
    );
  }
}
