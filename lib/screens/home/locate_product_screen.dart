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
  Stream<Position>? _positionStream;
  Location? productLocation;
  Position? position;

  final MapController _mapController = MapController();
  double _currentZoom = 15.0;
  bool _isPositionLoaded = false;
  bool _isProductLoaded = false;

  bool get isLoading => _isPositionLoaded == false || _isProductLoaded == false;

  @override
  void initState() {
    super.initState();
    listenToLocations();
    getCurrentPosition();
  }

  void getCurrentPosition() async {
    final position = await determineCurrentPosition();
    setState(() {
      this.position = position;
      _isPositionLoaded = true;
    });

    // Start listening to location changes
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 1, // Update only if moved by 10 meters
      ),
    );

    _positionStream?.listen((Position position) {
      setState(() {
        this.position = position;
        _centerMap();
        print("Position: Update position");
      });
    });
  }

  void listenToLocations() {
    firebaseService.getLocations(widget.iotUID).listen((locations) {
      setState(() {
        productLocation = locations;
        _isProductLoaded = true;
      });
    }, onError: (error) {
      setState(() {});
      print("Error al escuchar datos de Firebase: $error");
    });
  }

  _changePosition(LatLng position, double zoom) {
    zoom = zoom.clamp(1.0, 21.0);
    _currentZoom = zoom;
    _mapController.move(position, _currentZoom);
  }

  _changeZoom(int value) {
    _changePosition(_mapController.camera.center, _currentZoom + value);
  }

  void _centerMap() {
    if (productLocation != null && position != null) {
      final bounds = LatLngBounds.fromPoints([
        LatLng(productLocation!.latitude, productLocation!.longitude),
        LatLng(position!.latitude, position!.longitude),
      ]);
      _mapController.fitCamera(CameraFit.bounds(
          bounds: bounds, maxZoom: 21, padding: const EdgeInsets.all(20)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Localizar Producto'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: LatLng(
                      productLocation!.latitude,
                      productLocation!.longitude,
                    ),
                    onPositionChanged: (position, gesture) {
                      _currentZoom = position.zoom;
                    },
                    initialZoom: _currentZoom,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      subdomains: const ['a', 'b', 'c'],
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
                              LatLng(position!.latitude, position!.longitude),
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
                ),
                Positioned(
                  bottom: 20,
                  right: 10,
                  child: Column(
                    children: [
                      FloatingActionButton(
                        onPressed: () => _changeZoom(1),
                        child: const Icon(Icons.zoom_in, color: Colors.black),
                      ),
                      const SizedBox(height: 5),
                      FloatingActionButton(
                        onPressed: () => _changeZoom(-1),
                        child: const Icon(
                          Icons.zoom_out,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      FloatingActionButton(
                        onPressed: _centerMap,
                        backgroundColor: Colors.white,
                        child: const Icon(Icons.center_focus_strong,
                            color: Colors.black),
                      )
                    ],
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 10,
                  child: Column(
                    children: [
                      FloatingActionButton(
                          onPressed: () => _changePosition(
                              LatLng(productLocation!.latitude,
                                  productLocation!.longitude),
                              12),
                        child: const Icon(Icons.circle_outlined, color: Colors.red,),
                      ),
                      const SizedBox(height: 5,),
                      FloatingActionButton(
                          onPressed: () => _changePosition(
                              LatLng(position!.latitude, position!.longitude),
                              12),
                        child: const Icon(Icons.circle_outlined, color: Colors.green,),
                      ),
                    ],
                  ),
                )
              ],
            ),
    );
  }
}
