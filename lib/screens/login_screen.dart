import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          TextField(
          controller: _emailController,
          decoration: const InputDecoration(labelText: 'Email'),
        ),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Password'),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () async {
            try {
              await authProvider.login(
                _emailController.text,
                _passwordController.text,
              );
              Navigator.pushReplacementNamed(context, '/home');
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(e.toString())),
              );
            }
          },
          child: const Text('Login'),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, '/register');
          },
          child: const Text("Don't have an account? Register here."),
          ),
          ],
        ),
      ),
    );
  }
}
