// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:green_table/api/auth_api.dart';
import 'package:green_table/screens/auth/otp_verification_screen.dart';
// ignore: unused_import
import 'package:shared_preferences/shared_preferences.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});  // Add constructor
  
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _selectedRole = 'consumer';
  bool _isLoading = false;

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final response = await AuthAPI.register(
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          role: _selectedRole,
        );
        
        if (response['success']) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => OTPVerificationScreen(
                email: _emailController.text,
                password: _passwordController.text,
              ),
            ),
          );
        } else {
          // Debug log to inspect full backend response
          print('Backend Response: $response');
          
          final errorMessage = response['error']?['message'] ??  // Changed to match backend error structure
                             response['message'] ??
                             'Registration failed';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(title: Text('Register')),
          body: Padding(
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Name'),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(labelText: 'Email'),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  DropdownButtonFormField<String>(
                    value: _selectedRole,
                    items: ['consumer', 'restaurant']
                        .map((role) => DropdownMenuItem(
                              value: role,
                              child: Text(role.toUpperCase()),
                            ))
                        .toList(),
                    onChanged: (value) => setState(() => _selectedRole = value!),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await _register();
                    },
                    child: Text('Register'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/login'),
                    child: Text('Already have an account? Login'),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_isLoading)
          Container(
            color: Colors.black54,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}