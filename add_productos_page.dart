import 'package:flutter/material.dart';
import 'package:dulceria/services/firebase_service.dart';

class AddProductosPage extends StatefulWidget {
  const AddProductosPage({super.key});

  @override
  _AddProductosPageState createState() => _AddProductosPageState();
}

class _AddProductosPageState extends State<AddProductosPage> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _imagenUrlController = TextEditingController();

  Future<void> _agregarProducto() async {
    if (_validarDatos()) {
      try {
        await agregarProducto(
          _nombreController.text,
          double.parse(_precioController.text),
          _descripcionController.text,
          _imagenUrlController.text,
        );
        _limpiarCampos();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Producto agregado exitosamente')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al agregar el producto: $e')),
        );
      }
    }
  }

  bool _validarDatos() {
    if (_nombreController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('El nombre es obligatorio')));
      return false;
    }
    if (_precioController.text.isEmpty ||
        double.tryParse(_precioController.text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Introduce un precio válido')));
      return false;
    }
    if (_descripcionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('La descripción es obligatoria')));
      return false;
    }
    if (_imagenUrlController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('La URL de la imagen es obligatoria')));
      return false;
    }
    return true;
  }

  void _limpiarCampos() {
    _nombreController.clear();
    _precioController.clear();
    _descripcionController.clear();
    _imagenUrlController.clear();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _precioController.dispose();
    _descripcionController.dispose();
    _imagenUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Producto'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField(
                _nombreController, 'Nombre del Producto', Icons.label),
            const SizedBox(height: 20),
            _buildTextField(_precioController, 'Precio', Icons.attach_money,
                inputType: TextInputType.number),
            const SizedBox(height: 20),
            _buildTextField(
                _descripcionController, 'Descripción', Icons.description),
            const SizedBox(height: 20),
            _buildTextField(
                _imagenUrlController, 'URL de la Imagen', Icons.image),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _agregarProducto,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    vertical: 16.0, horizontal: 40.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text('Agregar Producto',
                  style: TextStyle(fontSize: 18.0)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {TextInputType inputType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }
}
