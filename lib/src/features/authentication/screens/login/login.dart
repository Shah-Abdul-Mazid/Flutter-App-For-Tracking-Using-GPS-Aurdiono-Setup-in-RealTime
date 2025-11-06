// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:gradient_borders/box_borders/gradient_box_border.dart';
// import 'package:TrackMyBus/src/common_widgets/background_scaffold.dart';
// import '../../models/user_model.dart';
// import '../admin/admin_panel.dart';
//
// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});
//
//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }
//
// class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
//   final _formKey = GlobalKey<FormState>();
//   final emailController = TextEditingController();
//   final passwordController = TextEditingController();
//
//   bool isLoading = false;
//   bool hidePassword = true;
//
//   late AnimationController _formController;
//   late Animation<double> _fadeIn;
//   late Animation<Offset> _slideInTitle;
//   late Animation<Offset> _slideInEmail;
//   late Animation<Offset> _slideInPassword;
//
//   late AnimationController _buttonController;
//
//   @override
//   void initState() {
//     super.initState();
//
//     _formController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 800),
//     );
//
//     _fadeIn = CurvedAnimation(parent: _formController, curve: Curves.easeIn);
//     _slideInTitle = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
//         .animate(CurvedAnimation(parent: _formController, curve: Curves.easeOut));
//     _slideInEmail = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
//         .animate(CurvedAnimation(parent: _formController, curve: const Interval(0.3, 0.7)));
//     _slideInPassword = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
//         .animate(CurvedAnimation(parent: _formController, curve: const Interval(0.5, 0.9)));
//
//     _buttonController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 300),
//     );
//
//     _formController.forward();
//   }
//
//   @override
//   void dispose() {
//     emailController.dispose();
//     passwordController.dispose();
//     _formController.dispose();
//     _buttonController.dispose();
//     super.dispose();
//   }
//
//   Future<void> loginUser() async {
//     if (!_formKey.currentState!.validate()) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please fill in all fields')),
//       );
//       return;
//     }
//
//     final email = emailController.text.trim();
//     final password = passwordController.text.trim();
//
//     setState(() => isLoading = true);
//     await _buttonController.forward();
//
//     try {
//       final snapshot = await FirebaseFirestore.instance
//           .collection('users')
//           .where('email', isEqualTo: email)
//           .where('password', isEqualTo: password)
//           .get();
//
//       if (snapshot.docs.isEmpty) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Invalid email or password')),
//         );
//         return;
//       }
//
//       final doc = snapshot.docs.first;
//       final user = UserModel.fromJson(doc.id, doc.data());
//
//       if (user.role == 'admin') {
//         final panelDoc = await FirebaseFirestore.instance
//             .collection('config')
//             .doc('panelStatus')
//             .get();
//
//         if (!panelDoc.exists || panelDoc.data()?['activePanel'] != true) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Admin panel is currently inactive.')),
//           );
//           return;
//         }
//
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => AdminPanel(user: user)),
//         );
//       } else {
//         Navigator.pushReplacementNamed(context, '/home', arguments: user);
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Login error: $e')),
//       );
//     } finally {
//       setState(() => isLoading = false);
//       await _buttonController.reverse();
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return BackgroundScaffold(
//       child: FadeTransition(
//         opacity: _fadeIn,
//         child: ListView(
//           padding: const EdgeInsets.all(20),
//           children: [
//             const SizedBox(height: 40),
//
//             // Title
//             SlideTransition(
//               position: _slideInTitle,
//               child: ShaderMask(
//                 shaderCallback: (bounds) => const LinearGradient(
//                   colors: [Colors.deepOrange, Colors.redAccent],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ).createShader(bounds),
//                 child: const Text(
//                   'Welcome Back',
//                   style: TextStyle(
//                     fontSize: 34,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                     letterSpacing: 1,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 40),
//
//             Form(
//               key: _formKey,
//               child: Column(
//                 children: [
//                   // Email field
//                   SlideTransition(
//                     position: _slideInEmail,
//                     child: _buildTextField(
//                       controller: emailController,
//                       label: 'Email',
//                       icon: Icons.email_outlined,
//                       validator: (val) {
//                         if (val == null || val.isEmpty) return 'Enter your email';
//                         final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
//                         return regex.hasMatch(val) ? null : 'Enter a valid email';
//                       },
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//
//                   // Password field
//                   SlideTransition(
//                     position: _slideInPassword,
//                     child: _buildTextField(
//                       controller: passwordController,
//                       label: 'Password',
//                       icon: Icons.lock_outline,
//                       isPassword: true,
//                       obscureText: hidePassword,
//                       suffixIcon: IconButton(
//                         icon: Icon(
//                           hidePassword ? Icons.visibility_off : Icons.visibility,
//                           color: Colors.white70,
//                         ),
//                         onPressed: () =>
//                             setState(() => hidePassword = !hidePassword),
//                       ),
//                       validator: (val) =>
//                       val == null || val.isEmpty ? 'Enter your password' : null,
//                     ),
//                   ),
//                   const SizedBox(height: 35),
//
//                   // Login button
//                   LayoutBuilder(
//                     builder: (context, constraints) {
//                       return AnimatedBuilder(
//                         animation: _buttonController,
//                         builder: (_, __) {
//                           final targetWidth = isLoading ? 60.0 : constraints.maxWidth;
//                           return GestureDetector(
//                             onTap: () => loginUser(),
//                             child: AnimatedContainer(
//                               duration: const Duration(milliseconds: 300),
//                               width: targetWidth,
//                               height: 55,
//                               decoration: BoxDecoration(
//                                 gradient: const LinearGradient(
//                                   colors: [Colors.deepOrange, Colors.redAccent],
//                                   begin: Alignment.topLeft,
//                                   end: Alignment.bottomRight,
//                                 ),
//                                 borderRadius: BorderRadius.circular(30),
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Colors.black.withOpacity(0.3),
//                                     blurRadius: 10,
//                                     offset: const Offset(0, 5),
//                                   ),
//                                 ],
//                               ),
//                               alignment: Alignment.center,
//                               child: isLoading
//                                   ? const SizedBox(
//                                 width: 24,
//                                 height: 24,
//                                 child: CircularProgressIndicator(
//                                   color: Colors.white,
//                                   strokeWidth: 2,
//                                 ),
//                               )
//                                   : const Text(
//                                 'Login',
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 18,
//                                   letterSpacing: 1,
//                                 ),
//                               ),
//                             ),
//                           );
//                         },
//                       );
//                     },
//                   ),
//                   const SizedBox(height: 25),
//
//                   // Signup button (outlined gradient)
//                   GestureDetector(
//                     onTap: () => Navigator.pushNamed(context, '/signup'),
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                           vertical: 12, horizontal: 20),
//                       margin: const EdgeInsets.only(top: 10),
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(20),
//                         border: GradientBoxBorder(
//                           gradient: const LinearGradient(
//                             colors: [Colors.deepOrange, Colors.redAccent],
//                           ),
//                           width: 1.5,
//                         ),
//                         color: Colors.black.withOpacity(0.2),
//                       ),
//                       child: const Center(
//                         child: Text(
//                           "Don't have an account? Sign up",
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.w600,
//                             fontSize: 15,
//                             letterSpacing: 0.5,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String label,
//     required IconData icon,
//     bool isPassword = false,
//     bool obscureText = false,
//     Widget? suffixIcon,
//     String? Function(String?)? validator,
//   }) {
//     return TextFormField(
//       controller: controller,
//       obscureText: obscureText,
//       validator: validator,
//       decoration: InputDecoration(
//         labelText: label,
//         labelStyle: const TextStyle(color: Colors.white70),
//         filled: true,
//         fillColor: Colors.black.withOpacity(0.25),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(18),
//         ),
//         prefixIcon: Icon(icon, color: Colors.white70),
//         suffixIcon: suffixIcon,
//       ),
//       style: const TextStyle(color: Colors.white),
//     );
//   }
// }
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:TrackMyBus/src/common_widgets/background_scaffold.dart';
import '../../models/user_model.dart';
import '../admin/admin_panel.dart';
import 'package:TrackMyBus/src/features/authentication/screens/forget_password/forgetpassword.dart';
import 'package:TrackMyBus/src/features/authentication/screens/signup/signup.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool hidePassword = true;

  late AnimationController _formController;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideInTitle;
  late Animation<Offset> _slideInEmail;
  late Animation<Offset> _slideInPassword;

  late AnimationController _buttonController;

  @override
  void initState() {
    super.initState();

    _formController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeIn = CurvedAnimation(parent: _formController, curve: Curves.easeIn);
    _slideInTitle = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _formController, curve: Curves.easeOut));
    _slideInEmail = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
        .animate(CurvedAnimation(parent: _formController, curve: const Interval(0.3, 0.7)));
    _slideInPassword = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
        .animate(CurvedAnimation(parent: _formController, curve: const Interval(0.5, 0.9)));

    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _formController.forward();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    _formController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  Future<void> loginUser() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    setState(() => isLoading = true);
    await _buttonController.forward();

    try {
      // Find user by email
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (snapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid email or password')),
        );
        return;
      }

      final doc = snapshot.docs.first;
      final user = UserModel.fromJson(doc.id, doc.data());

      // Hash entered password
      final hashedPassword = sha256.convert(utf8.encode(password)).toString();

      // Check hashed password
      if (doc['password'] != hashedPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid email or password')),
        );
        return;
      }

      if (user.role == 'admin') {
        final panelDoc = await FirebaseFirestore.instance
            .collection('config')
            .doc('panelStatus')
            .get();

        if (!panelDoc.exists || panelDoc.data()?['activePanel'] != true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Admin panel is currently inactive.')),
          );
          return;
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => AdminPanel(user: user)),
        );
      } else {
        Navigator.pushReplacementNamed(context, '/home', arguments: user);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login error: $e')),
      );
    } finally {
      setState(() => isLoading = false);
      await _buttonController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      child: FadeTransition(
        opacity: _fadeIn,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 40),
            SlideTransition(
              position: _slideInTitle,
              child: const Text(
                'Welcome Back',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 40),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  SlideTransition(
                    position: _slideInEmail,
                    child: _buildTextField(
                      controller: emailController,
                      label: 'Email',
                      icon: Icons.email_outlined,
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Enter your email';
                        final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                        return regex.hasMatch(val) ? null : 'Enter a valid email';
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  SlideTransition(
                    position: _slideInPassword,
                    child: _buildTextField(
                      controller: passwordController,
                      label: 'Password',
                      icon: Icons.lock_outline,
                      isPassword: true,
                      obscureText: hidePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          hidePassword ? Icons.visibility_off : Icons.visibility,
                          color: Colors.white70,
                        ),
                        onPressed: () => setState(() => hidePassword = !hidePassword),
                      ),
                      validator: (val) =>
                      val == null || val.isEmpty ? 'Enter your password' : null,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ForgetPasswordPage()),
                      ),
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: Colors.yellowAccent,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildLoginButton(),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignupPage()),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      margin: const EdgeInsets.only(top: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: GradientBoxBorder(
                          gradient: const LinearGradient(
                            colors: [Colors.deepOrange, Colors.redAccent],
                          ),
                          width: 1.5,
                        ),
                        color: Colors.black.withOpacity(0.2),
                      ),
                      child: const Center(
                        child: Text(
                          "Don't have an account? Create Account",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return AnimatedBuilder(
          animation: _buttonController,
          builder: (_, __) {
            final targetWidth = isLoading ? 60.0 : constraints.maxWidth;
            return GestureDetector(
              onTap: loginUser,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: targetWidth,
                height: 55,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.deepOrange, Colors.redAccent],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: isLoading
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Text(
                  'Login',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    letterSpacing: 1,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.black.withOpacity(0.25),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        prefixIcon: Icon(icon, color: Colors.white70),
        suffixIcon: suffixIcon,
      ),
      style: const TextStyle(color: Colors.white),
    );
  }
}
