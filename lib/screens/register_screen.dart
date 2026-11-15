import 'package:flutter/material.dart';

import '../services/auth_database.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final created = await AuthDatabase.instance.register(
        username: _usernameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (!mounted) return;
      if (!created) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email tersebut sudah terdaftar.')),
        );
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registrasi berhasil. Silakan login.'),
        ),
      );
      Navigator.of(context).pop();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registrasi gagal: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buat akun')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _usernameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(labelText: 'Nama pengguna'),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Nama pengguna wajib diisi.'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (value) => value == null || !value.contains('@')
                        ? 'Masukkan email yang valid.'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password'),
                    validator: (value) => value == null || value.length < 6
                        ? 'Password minimal 6 karakter.'
                        : null,
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: _isLoading ? null : _register,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Register'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
