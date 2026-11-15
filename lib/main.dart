import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/character_shell.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const RickAndMortyCharacterExplorerApp());
}

class RickAndMortyCharacterExplorerApp extends StatelessWidget {
  const RickAndMortyCharacterExplorerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rick & Morty Character Explorer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const AppGate(),
    );
  }
}

class AppGate extends StatefulWidget {
  const AppGate({super.key});

  @override
  State<AppGate> createState() => _AppGateState();
}

class _AppGateState extends State<AppGate> {
  String? _username;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final preferences = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _username = preferences.getString('session_username');
      _isLoading = false;
    });
  }

  void _authenticated(String username) {
    setState(() => _username = username);
  }

  Future<void> _logout() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove('session_username');
    if (!mounted) return;
    setState(() => _username = null);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_username != null) {
      return CharacterShell(username: _username!, onLogout: _logout);
    }

    return LoginScreen(
      onAuthenticated: _authenticated,
      onRegisterTap: () {
        Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (_) => const RegisterScreen(),
          ),
        );
      },
    );
  }
}
