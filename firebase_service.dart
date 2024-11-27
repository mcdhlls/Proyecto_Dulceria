import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;

/// Obtener la lista de productos desde Firestore
Future<List<Map<String, dynamic>>> getProductos() async {
  try {
    QuerySnapshot snapshot = await firestore.collection('productos').get();
    return snapshot.docs
        .map((doc) => {
              'uid': doc.id,
              'nombre': doc['nombre'],
              'precio': doc['precio'],
              'descripcion': doc['descripcion'],
              'imagenUrl': doc['imagenUrl']
            })
        .toList();
  } catch (e) {
    throw Exception('Error al obtener los productos: $e');
  }
}

/// Agregar un nuevo producto a Firestore
Future<void> agregarProducto(
    String nombre, double precio, String descripcion, String imagenUrl) async {
  try {
    await firestore.collection('productos').add({
      'nombre': nombre,
      'precio': precio,
      'descripcion': descripcion,
      'imagenUrl': imagenUrl
    });
  } catch (e) {
    throw Exception('Error al agregar el producto: $e');
  }
}

/// Editar un producto existente en Firestore
Future<void> editProducto(String id, String nombre, double precio,
    String descripcion, String imagenUrl) async {
  try {
    await firestore.collection('productos').doc(id).update({
      'nombre': nombre,
      'precio': precio,
      'descripcion': descripcion,
      'imagenUrl': imagenUrl
    });
  } catch (e) {
    throw Exception('Error al editar el producto: $e');
  }
}

/// Eliminar un producto de Firestore
Future<void> deleteProducto(String id) async {
  try {
    await firestore.collection('productos').doc(id).delete();
  } catch (e) {
    throw Exception('Error al eliminar el producto: $e');
  }
}

/// Obtener la lista de productos en el carrito desde Firestore
Future<List<Map<String, dynamic>>> getCarrito() async {
  try {
    QuerySnapshot snapshot = await firestore.collection('carrito').get();
    return snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  } catch (e) {
    throw Exception('Error al obtener el carrito: $e');
  }
}

/// Agregar un producto al carrito en Firestore
Future<void> agregarAlCarrito(Map<String, dynamic> producto) async {
  try {
    await firestore.collection('carrito').add(producto);
  } catch (e) {
    throw Exception('Error al agregar el producto al carrito: $e');
  }
}

/// Eliminar un producto del carrito en Firestore
Future<void> removeProductoDelCarrito(String id) async {
  try {
    await firestore.collection('carrito').doc(id).delete();
  } catch (e) {
    throw Exception('Error al eliminar el producto del carrito: $e');
  }
}

/// Finalizar la compra (vaciar el carrito) en Firestore
Future<void> finalizarCompra() async {
  try {
    QuerySnapshot snapshot = await firestore.collection('carrito').get();
    for (DocumentSnapshot doc in snapshot.docs) {
      await doc.reference.delete();
    }
  } catch (e) {
    throw Exception('Error al finalizar la compra: $e');
  }
}
