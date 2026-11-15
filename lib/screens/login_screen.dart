import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/auth_database.dart';
import '../theme/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    required this.onAuthenticated,
    required this.onRegisterTap,
    super.key,
  });

  final ValueChanged<String> onAuthenticated;
  final VoidCallback onRegisterTap;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _hidePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final username = await AuthDatabase.instance.login(
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (!mounted) return;
      if (username == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email atau password tidak sesuai.')),
        );
        return;
      }
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString('session_username', username);
      widget.onAuthenticated(username);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Login gagal: $error')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.blur_circular_rounded,
                    size: 54,
                    color: AppColors.olive,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Welcome back',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: AppColors.olive,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Login untuk menjelajahi karakter Rick and Morty.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
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
                    obscureText: _hidePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      suffixIcon: IconButton(
                        onPressed: () =>
                            setState(() => _hidePassword = !_hidePassword),
                        icon: Icon(
                          _hidePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                      ),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Password wajib diisi.'
                        : null,
                    onFieldSubmitted: (_) => _login(),
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: _isLoading ? null : _login,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Login'),
                  ),
                  TextButton(
                    onPressed: _isLoading ? null : widget.onRegisterTap,
                    child: const Text('Belum punya akun? Register'),
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
