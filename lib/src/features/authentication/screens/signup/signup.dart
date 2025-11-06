import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:TrackMyBus/src/utils/screen_wrapper.dart';
import '../../models/user_model.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController altEmailController = TextEditingController();

  bool _isLoading = false;

  Future<void> signupUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userRef = FirebaseFirestore.instance.collection('users').doc();

      final user = UserModel(
        id: userRef.id,
        username: usernameController.text.trim(),
        password: passwordController.text.trim(),
        email: emailController.text.trim(),
        role: 'user',
        status: 'active',
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        dateOfBirth: dobController.text.trim(),
        contact: contactController.text.trim(),
        altEmail: altEmailController.text.trim().isEmpty ? null : altEmailController.text.trim(),
        emailVerified: false,
        contactVerified: false,
      );

      await userRef.set(user.toJson());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created. Please log in.')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.3),
        border: const OutlineInputBorder(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(title: const Text('Create Account'));

    return buildScreenWithBackground(
      appBar: appBar,
      overlayOpacity: 0.5,
      content: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Text(
                  'Create Account',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: usernameController,
                  label: 'Username',
                  validator: (v) => v == null || v.isEmpty ? 'Enter a username' : null,
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  controller: emailController,
                  label: 'Email',
                  validator: (v) => v == null || !v.contains('@') ? 'Enter a valid email' : null,
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  controller: passwordController,
                  label: 'Password',
                  obscureText: true,
                  validator: (v) => v == null || v.length < 6 ? 'Min 6 characters' : null,
                ),
                const SizedBox(height: 10),
                _buildTextField(controller: firstNameController, label: 'First Name'),
                const SizedBox(height: 10),
                _buildTextField(controller: lastNameController, label: 'Last Name'),
                const SizedBox(height: 10),
                _buildTextField(controller: dobController, label: 'Date of Birth (YYYY-MM-DD)'),
                const SizedBox(height: 10),
                _buildTextField(controller: contactController, label: 'Contact Number'),
                const SizedBox(height: 10),
                _buildTextField(controller: altEmailController, label: 'Alt Email (Optional)'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isLoading ? null : signupUser,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Sign Up'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
