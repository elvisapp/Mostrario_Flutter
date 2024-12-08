import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Productos Agrícolas',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ProductListScreen(),
    );
  }
}

class ProductListScreen extends StatefulWidget {
  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<Product> products = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    const apiUrl =
        'https://a3a4-2804-6a84-1057-a800-ca9-9f82-f60a-2f7c.ngrok-free.app/agricola';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      print('Código de estado: ${response.statusCode}');
      print('Encabezados: ${response.headers}');
      print('Cuerpo de la respuesta: ${response.body}');

      if (response.statusCode == 200) {
        final contentType = response.headers['content-type'];
        if (contentType != null && contentType.contains('application/json')) {
          try {
            final List<dynamic> jsonData = json.decode(response.body);
            setState(() {
              products =
                  jsonData.map((data) => Product.fromJson(data)).toList();
              isLoading = false;
            });
            print('Productos obtenidos: $products');
          } catch (e) {
            setState(() {
              isLoading = false;
              errorMessage = 'Error al analizar el JSON: $e';
            });
            print('Error al analizar el JSON: $e');
          }
        } else {
          setState(() {
            isLoading = false;
            errorMessage = 'El servidor no devolvió JSON válido.';
          });
          print('Error: El servidor no devolvió JSON válido.');
        }
      } else {
        setState(() {
          isLoading = false;
          errorMessage =
              'Error: La API devolvió el código ${response.statusCode}.';
        });
        print('Error: Código de estado ${response.statusCode}.');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error al obtener los productos: $e';
      });
      print('Error al obtener los productos: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Productos Agrícolas'),
        backgroundColor: Colors.red,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Text(
                    errorMessage!,
                    style: TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return ProductCard(product: product);
                  },
                ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;

  ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            product.foto != null
                ? Image.memory(
                    Base64Decoder().convert(product.foto!),
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey,
                    child: Icon(Icons.image_not_supported, size: 50),
                  ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.nombre,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text(product.descripcion),
                  SizedBox(height: 5),
                  Text(
                    'Precio: \$${product.precio.toStringAsFixed(2)}',
                    style: TextStyle(
                        color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Product {
  final String nombre;
  final String descripcion;
  final double precio;
  final String? foto;

  Product({
    required this.nombre,
    required this.descripcion,
    required this.precio,
    this.foto,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      nombre: json['Nombre'] as String,
      descripcion: json['Descripcion'] as String,
      precio: (json['Precio'] as num).toDouble(),
      foto: json['Foto'] as String?,
    );
  }
}
