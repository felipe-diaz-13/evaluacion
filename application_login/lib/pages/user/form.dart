import 'package:flutter/material.dart';
import '../../widgets/appbar.dart';
import '../../services/api_service.dart';

class UserFormScreen extends StatefulWidget {
  const UserFormScreen({super.key});

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Las contraseñas no coinciden')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final error = await ApiService().registerUser(
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
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

    // Retornar credenciales al login para rellenar los campos
    final userData = {
      'username': _usernameController.text.trim(),
      'password': _passwordController.text,
      'email': _emailController.text.trim(),
    };

    Navigator.pop(context, userData);
  }

  void _cancel() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Registrar Usuario',
        showBackButton: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Image.asset(
                'assets/img/logos/stamp.webp',
                height: 100,
              ), // Image.asset
              const SizedBox(height: 20),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Usuario',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ), // InputDecoration
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un usuario';
                  }
                  return null;
                },
              ), // TextFormField
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ), // InputDecoration
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un email';
                  }
                  if (!value.contains('@')) {
                    return 'Ingrese un email válido';
                  }
                  return null;
                },
              ), // TextFormField
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ), // InputDecoration
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese una contraseña';
                  }
                  if (value.length < 6) {
                    return 'La contraseña debe tener al menos 6 caracteres';
                  }
                  return null;
                },
              ), // TextFormField
              const SizedBox(height: 20),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirmar Contraseña',
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(),
                ), // InputDecoration
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor confirme su contraseña';
                  }
                  return null;
                },
              ), // TextFormField
              const SizedBox(height: 30),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _register,
                        child: const Text('Registrar'),
                      ), // ElevatedButton
                    ), // Expanded
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _cancel,
                        child: const Text('Cancelar'),
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
