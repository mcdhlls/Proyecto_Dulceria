import 'package:flutter/material.dart';
import 'package:dulceria/services/firebase_service.dart';
import 'package:dulceria/pages/edit_producto_page.dart';

class ProductosListPage extends StatefulWidget {
  const ProductosListPage({super.key});

  @override
  State<ProductosListPage> createState() => _ProductosListPageState();
}

class _ProductosListPageState extends State<ProductosListPage> {
  late Future<List<Map<String, dynamic>>> _productos;

  @override
  void initState() {
    super.initState();
    _productos = _getProductos();
  }

  Future<List<Map<String, dynamic>>> _getProductos() async {
    try {
      return await getProductos();
    } catch (e) {
      throw Exception('Error al obtener los productos: $e');
    }
  }

  Future<void> _refreshProductos() async {
    setState(() {
      _productos = _getProductos();
    });
  }

  Future<void> _agregarAlCarrito(
      BuildContext context, Map<String, dynamic> producto) async {
    try {
      await agregarAlCarrito(producto);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('${producto['nombre']} ha sido agregado al carrito')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Error al agregar ${producto['nombre']} al carrito: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Lista de Productos',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshProductos,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/add');
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _productos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar los productos.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay productos disponibles.'));
          } else {
            return ListView.builder(
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
                      '\$${producto['precio']?.toString() ?? '0.00'}',
                      style: const TextStyle(fontSize: 16, color: Colors.green),
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) => _onMenuSelected(value, producto),
                      itemBuilder: (BuildContext context) => [
                        const PopupMenuItem(
                          value: 'editar',
                          child: Text('Editar'),
                        ),
                        const PopupMenuItem(
                          value: 'eliminar',
                          child: Text('Eliminar'),
                        ),
                        const PopupMenuItem(
                          value: 'agregar',
                          child: Text('Agregar al carrito'),
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
    );
  }

  void _onMenuSelected(String value, Map<String, dynamic> producto) {
    switch (value) {
      case 'editar':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditProducto(producto: producto),
          ),
        ).then((_) => _refreshProductos());
        break;
      case 'eliminar':
        _eliminarProducto(producto['uid']);
        break;
      case 'agregar':
        _agregarAlCarrito(context, producto);
        break;
    }
  }

  Future<void> _eliminarProducto(String productoId) async {
    try {
      await deleteProducto(productoId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto eliminado exitosamente')),
      );
      _refreshProductos();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar producto: $e')),
      );
    }
  }
}
