import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProductosPage extends StatelessWidget {
  const ProductosPage({super.key});

  Future<void> agregarAlCarrito(
      Map<String, dynamic> producto, BuildContext context) async {
    try {
      final carrito = FirebaseFirestore.instance.collection('carrito');
      await carrito.add(producto);
      if (!context.mounted) return; // Verificación de mounted
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('${producto['nombre']} ha sido agregado al carrito')),
      );
    } catch (e) {
      if (!context.mounted) return; // Verificación de mounted
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Error al agregar ${producto['nombre']} al carrito: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final productos = FirebaseFirestore.instance.collection('productos');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => Navigator.pushNamed(context, '/carrito'),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: productos.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child:
                    Text('Error al cargar los productos: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No hay productos disponibles'));
          } else {
            final docs = snapshot.data!.docs;
            return ListView.builder(
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final producto = docs[index].data() as Map<String, dynamic>;
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  elevation: 5,
                  child: ListTile(
                    title: Text(producto['nombre']),
                    subtitle: Text('\$${producto['precio']}'),
                    leading: producto['imagenUrl'] != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              producto['imagenUrl'],
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.image_not_supported),
                            ),
                          )
                        : const Icon(Icons.image_not_supported),
                    trailing: IconButton(
                      icon: const Icon(Icons.add_shopping_cart),
                      onPressed: () => agregarAlCarrito(producto, context),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
