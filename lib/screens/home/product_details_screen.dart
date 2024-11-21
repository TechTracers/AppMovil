import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/product.dart';
import '../../services/product_service.dart';
import '../../shared/utils/location.dart';
import 'locate_product_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.product});

  final Product product;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final ProductService productService = ProductService();

  @override
  void initState() {
    super.initState();
  }

  Product get product => widget.product;

  Future<void> _showLocationServicesDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Servicios de localización deshabilitados'),
          content: const Text(
              'Los servicios de localización están deshabilitados. Por favor, habilítalos para continuar.'),
          actions: <Widget>[
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  "Cancelar",
                  style: TextStyle(color: Colors.red),
                )),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                AppSettings.openAppSettings(type: AppSettingsType.location);
              },
              child: const Text('Abrir configuración'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _toLocateProduct() async {
    LocationPermissionStatus status = await requestPositionPermission();

    if (status == LocationPermissionStatus.disabled ||
        status == LocationPermissionStatus.denied ||
        status == LocationPermissionStatus.deniedForever) {
      // Si los servicios están deshabilitados, muestra el diálogo para habilitarlos.
      await _showLocationServicesDialog();
      return;
    } else if (status != LocationPermissionStatus.allowed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No se han concedido los permisos de localización')),
      );
    }
    // Navegar a la pantalla del mapa

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocateProductScreen(
          iotUID: product.iotUID, // Cambia esto por el iotUID
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen del producto
            Center(
              child: CachedNetworkImage(
                imageUrl: product.imageUrl.isNotEmpty ? product.imageUrl : '',
                height: 500,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) =>
                    const Icon(Icons.broken_image, size: 100),
              ),
            ),
            const SizedBox(height: 20),
            // Nombre del producto
            Text(
              product.name.isNotEmpty ? product.name : 'Unknown',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            // Descripción del producto
            Text(
              product.description.isNotEmpty
                  ? product.description
                  : 'No description available.',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            // Precio del producto
            Text(
              '\$${product.price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 20),
            // Botón "Locate"
            Center(
              child: ElevatedButton(
                onPressed: () => _toLocateProduct(),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                  backgroundColor: Colors.black,
                ),
                child: const Text(
                  'Locate',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
