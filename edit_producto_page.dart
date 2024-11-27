import 'package:flutter/material.dart';
import 'package:dulceria/services/firebase_service.dart';

class EditProducto extends StatefulWidget {
  final Map<String, dynamic> producto;

  const EditProducto({super.key, required this.producto});

  @override
  State<EditProducto> createState() => _EditProductoState();
}

class _EditProductoState extends State<EditProducto> {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController precioController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();
  final TextEditingController imagenUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    nombreController.text = widget.producto['nombre'];
    precioController.text = widget.producto['precio'].toString();
    descripcionController.text = widget.producto['descripcion'];
    imagenUrlController.text = widget.producto['imagenUrl'];
  }

  Future<void> _editProducto() async {
    if (_validarDatos()) {
      try {
        await editProducto(
          widget.producto['uid'],
          nombreController.text,
          double.parse(precioController.text),
          descripcionController.text,
          imagenUrlController.text,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Producto actualizado exitosamente')),
        );
        Navigator.pop(context);
        _limpiarCampos();
      } catch (e) {
        _mostrarMensaje('Error al actualizar producto: $e');
      }
    }
  }

  bool _validarDatos() {
    if (nombreController.text.isEmpty) {
      _mostrarMensaje('El nombre del producto es obligatorio');
      return false;
    }
    if (precioController.text.isEmpty) {
      _mostrarMensaje('El precio del producto es obligatorio');
      return false;
    }
    if (double.tryParse(precioController.text) == null) {
      _mostrarMensaje('El precio debe ser un número válido');
      return false;
    }
    if (descripcionController.text.isEmpty) {
      _mostrarMensaje('La descripción del producto es obligatoria');
      return false;
    }
    if (imagenUrlController.text.isEmpty) {
      _mostrarMensaje('La URL de la imagen del producto es obligatoria');
      return false;
    }
    return true;
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  void _limpiarCampos() {
    nombreController.clear();
    precioController.clear();
    descripcionController.clear();
    imagenUrlController.clear();
  }

  @override
  void dispose() {
    nombreController.dispose();
    precioController.dispose();
    descripcionController.dispose();
    imagenUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Producto'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField(
              controller: nombreController,
              label: 'Nombre del producto',
              icon: Icons.label,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: precioController,
              label: 'Precio',
              icon: Icons.attach_money,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: descripcionController,
              label: 'Descripción',
              icon: Icons.description,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: imagenUrlController,
              label: 'URL de la imagen',
              icon: Icons.image,
              onChanged: (value) {
                setState(() {});
              },
            ),
            const SizedBox(height: 20),
            _buildImagePreview(),
            const SizedBox(height: 40),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    void Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      onChanged: onChanged,
    );
  }

  Widget _buildImagePreview() {
    return imagenUrlController.text.isNotEmpty
        ? ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.network(
              imagenUrlController.text,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.image_not_supported, size: 200),
            ),
          )
        : const SizedBox.shrink();
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _editProducto,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 40.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      child: const Text(
        'Guardar Cambios',
        style: TextStyle(fontSize: 18.0),
      ),
    );
  }
}
