import 'package:flutter/material.dart';
import '../../widgets/appbar.dart';
import '../../services/api_service.dart';

/// Pantalla para registrar un nuevo Rol de usuario.
/// Accesible ANTES del login (no requiere autenticación).
class RoleFormScreen extends StatefulWidget {
  const RoleFormScreen({super.key});

  @override
  State<RoleFormScreen> createState() => _RoleFormScreenState();
}

class _RoleFormScreenState extends State<RoleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final error = await ApiService().addRole(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $error'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Mostrar mensaje de éxito (requisito iv.1)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Rol registrado exitosamente'),
        backgroundColor: Colors.green,
      ),
    );

    // Regresar al login
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Registrar Nuevo Rol',
        showBackButton: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 20),
              // Ícono decorativo
              const Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.badge, size: 45, color: Colors.white),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Completa los datos del nuevo rol',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 24),

              // Campo: Nombre del rol (requerido - requisito iv.2)
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Rol',
                  prefixIcon: Icon(Icons.badge),
                  border: OutlineInputBorder(),
                ), // InputDecoration
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el nombre del rol';
                  }
                  return null;
                },
              ), // TextFormField
              const SizedBox(height: 20),

              // Campo: Descripción (requerido - requisito iv.2)
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ), // InputDecoration
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese una descripción';
                  }
                  return null;
                },
              ), // TextFormField
              const SizedBox(height: 30),

              // Botones Guardar / Cancelar
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.save),
                        label: const Text('Guardar Rol'),
                        onPressed: _register,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                        ),
                      ), // ElevatedButton
                    ), // Expanded
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.cancel),
                        label: const Text('Cancelar'),
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                        ),
                      ), // OutlinedButton
                    ), // Expanded
                  ],
                ), // Row
            ],
          ), // ListView
        ), // Form
      ), // Padding
    ); // Scaffold
  }
}
