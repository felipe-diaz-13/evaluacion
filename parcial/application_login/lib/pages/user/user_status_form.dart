import 'package:flutter/material.dart';
import '../../widgets/appbar.dart';
import '../../services/api_service.dart';

/// Pantalla para registrar un nuevo Estado de Usuario.
/// Accesible DESPUÉS del login desde UserScreen (requisito iii set2).
class UserStatusFormScreen extends StatefulWidget {
  const UserStatusFormScreen({super.key});

  @override
  State<UserStatusFormScreen> createState() => _UserStatusFormScreenState();
}

class _UserStatusFormScreenState extends State<UserStatusFormScreen> {
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

    final error = await ApiService().addUserStatus(
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

    // Mensaje de éxito (requisito iv.1 set2)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Estado de usuario registrado exitosamente'),
        backgroundColor: Colors.green,
      ),
    );

    if (mounted) Navigator.pop(context, true); // retorna true para recargar
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Nuevo Estado de Usuario',
        showBackButton: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 16),
              const Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.verified_user, size: 45, color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Completa los datos del nuevo estado',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.grey),
              ),
              const SizedBox(height: 24),

              // Campo: Nombre (requerido - requisito iv.2 set2)
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Estado',
                  prefixIcon: Icon(Icons.label),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el nombre del estado';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Campo: Descripción (requerido - requisito iv.2 set2)
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese una descripción';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),

              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.save),
                        label: const Text('Guardar Estado'),
                        onPressed: _register,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.cancel),
                        label: const Text('Cancelar'),
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
