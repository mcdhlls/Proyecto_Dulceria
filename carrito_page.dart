import 'package:flutter/material.dart';
import 'package:dulceria/services/firebase_service.dart';

class CarritoPage extends StatefulWidget {
  const CarritoPage({super.key});

  @override
  _CarritoPageState createState() => _CarritoPageState();
}

class _CarritoPageState extends State<CarritoPage> {
  late Future<List<Map<String, dynamic>>> _carrito;

  @override
  void initState() {
    super.initState();
    _carrito = _getCarrito();
  }

  Future<List<Map<String, dynamic>>> _getCarrito() async {
    try {
      return await getCarrito();
    } catch (e) {
      throw Exception('Error al obtener el carrito: $e');
    }
  }

  Future<void> _refreshCarrito() async {
    setState(() {
      _carrito = _getCarrito();
    });
  }

  Future<void> _finalizarCompra() async {
    try {
      await finalizarCompra();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Compra finalizada exitosamente')),
      );
      _refreshCarrito();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al finalizar la compra: $e')),
      );
    }
  }

  Future<void> _eliminarProductoDelCarrito(String uid) async {
    try {
      await removeProductoDelCarrito(uid);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto eliminado del carrito')),
      );
      _refreshCarrito();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar producto del carrito: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrito'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshCarrito,
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _carrito,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar el carrito.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('El carrito está vacío.'));
          } else {
            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final producto = snapshot.data![index];
                return Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  child: ListTile(
                    leading: producto['imagenUrl'] != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              producto['imagenUrl'],
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.image_not_supported),
                            ),
                          )
                        : const Icon(Icons.image, size: 60),
                    title: Text(
                      producto['nombre'] ?? 'Producto sin nombre',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      '\$${producto['precio']?.toString() ?? '0.00'} x ${producto['cantidad']}',
                      style: const TextStyle(fontSize: 16, color: Colors.green),
                    ),
                    trailing: Wrap(
                      spacing: 12,
                      children: <Widget>[
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () =>
                              _eliminarProductoDelCarrito(producto['uid']),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () =>
                              _agregarProductoAlCarrito(producto, context),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _finalizarCompra,
          style: ElevatedButton.styleFrom(
            padding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 40.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          child:
              const Text('Finalizar Compra', style: TextStyle(fontSize: 18.0)),
        ),
      ),
    );
  }

  Future<void> _agregarProductoAlCarrito(
      Map<String, dynamic> producto, BuildContext context) async {
    try {
      await agregarAlCarrito(producto);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('${producto['nombre']} ha sido agregado al carrito')),
      );
      _refreshCarrito();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Error al agregar ${producto['nombre']} al carrito: $e')),
      );
    }
  }
}
