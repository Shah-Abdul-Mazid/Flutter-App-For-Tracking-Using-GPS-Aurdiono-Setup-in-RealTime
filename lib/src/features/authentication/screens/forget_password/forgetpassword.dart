import 'dart:math';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class ForgetPasswordPage extends StatefulWidget {
  const ForgetPasswordPage({super.key});

  @override
  State<ForgetPasswordPage> createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
  final emailController = TextEditingController();
  final otpController = TextEditingController();
  final newPasswordController = TextEditingController();

  String? userIdForReset;
  String? userEmailForReset;
  String? tokenIdForReset;
  bool isLoading = false;
  bool otpSent = false;

  // --- Send OTP ---
  Future<void> sendOtp() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your registered email')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Find user by email
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (snapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email not found')),
        );
        return;
      }

      userIdForReset = snapshot.docs.first.id;
      userEmailForReset = snapshot.docs.first['email'];

      // Generate OTP and tokenId
      final generatedOtp = (Random().nextInt(900000) + 100000).toString();
      tokenIdForReset = const Uuid().v4();

      // Store OTP in resetTokens collection
      print('Creating reset token with ID: $tokenIdForReset for user: $userIdForReset');
      await FirebaseFirestore.instance
          .collection('resetTokens')
          .doc(tokenIdForReset)
          .set({
        'otp': generatedOtp,
        'userId': userIdForReset,
        'email': userEmailForReset,
        'createdAt': FieldValue.serverTimestamp(),
        'used': false,
        'expiresAt': Timestamp.fromDate(DateTime.now().add(const Duration(minutes: 5))),
      });

      // Send OTP to user via email
      await sendOtpEmail(userEmailForReset!, generatedOtp);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP sent to your email')),
      );

      // Set OTP sent state and show dialog
      setState(() {
        otpSent = true;
      });

      _showOtpDialog();
    } catch (e) {
      print('Error in sendOtp: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send OTP: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // --- Send OTP Email with SMTP ---
  Future<void> sendOtpEmail(String email, String otp) async {
    try {
      const String username = 'ezanshah58@gmail.com';
      const String password = 'dgpv zfzs vvhq ealg';

      final smtpServer = gmail(username, password);

      final message = Message()
        ..from = Address(username, 'Your App Name')
        ..recipients.add(email)
        ..subject = 'Password Reset OTP - Your App Name'
        ..html = """
          <!DOCTYPE html>
          <html>
          <head>
            <meta charset="utf-8">
            <style>
              body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
              .container { max-width: 600px; margin: 0 auto; padding: 20px; }
              .header { background: #007bff; color: white; padding: 20px; text-align: center; }
              .content { background: #f9f9f9; padding: 30px; border-radius: 5px; }
              .otp-code { 
                font-size: 32px; 
                font-weight: bold; 
                color: #007bff; 
                text-align: center;
                margin: 20px 0;
                letter-spacing: 5px;
              }
              .footer { 
                text-align: center; 
                margin-top: 30px; 
                color: #666; 
                font-size: 12px;
              }
            </style>
          </head>
          <body>
            <div class="container">
              <div class="header">
                <h1>Password Reset Request</h1>
              </div>
              <div class="content">
                <p>Hello,</p>
                <p>You requested to reset your password. Use the OTP code below to complete the process:</p>
                
                <div class="otp-code">$otp</div>
                
                <p>This OTP will expire in <strong>5 minutes</strong>.</p>
                <p>If you didn't request this password reset, please ignore this email or contact support if you have concerns.</p>
                
                <p>Best regards,<br>Your App Team</p>
              </div>
              <div class="footer">
                <p>This is an automated message. Please do not reply to this email.</p>
                <p>&copy; 2025 Your App Name. All rights reserved.</p>
              </div>
            </div>
          </body>
          </html>
        """;

      print('Connection opened: ${DateTime.now()}');
      final sendReport = await send(message, smtpServer);
      print('Message sent: ${sendReport.toString()}');
      print('Sending finished: ${DateTime.now()}');
    } catch (e) {
      print('Error sending email: $e');
      rethrow;
    }
  }

  // --- OTP & New Password Dialog ---
  void _showOtpDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Enter the OTP sent to your email and your new password',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'OTP Code',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.password),
                  hintText: 'Minimum 6 characters',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: resetPassword,
            child: const Text('Reset Password'),
          ),
        ],
      ),
    );
  }

  // --- Reset Password ---
  Future<void> resetPassword() async {
    final enteredOtp = otpController.text.trim();
    final newPassword = newPasswordController.text.trim();

    if (enteredOtp.isEmpty || newPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    if (newPassword.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      if (userIdForReset == null || tokenIdForReset == null || userEmailForReset == null) {
        throw Exception('Reset request not initialized');
      }

      // Validate OTP
      print('Validating reset token: $tokenIdForReset');
      final tokenDoc = await FirebaseFirestore.instance
          .collection('resetTokens')
          .doc(tokenIdForReset)
          .get();

      if (!tokenDoc.exists) {
        throw Exception('Invalid or expired OTP');
      }

      final tokenData = tokenDoc.data()!;
      print('Token data: $tokenData');
      if (tokenData['used'] == true ||
          tokenData['otp'] != enteredOtp ||
          DateTime.now().isAfter(tokenData['expiresAt'].toDate())) {
        throw Exception('Invalid or expired OTP');
      }

      // Hash the password
      final hashedPassword = sha256.convert(utf8.encode(newPassword)).toString();

      // Update password with tokenId and OTP for rule validation (not stored)
      print('Updating user: $userIdForReset with tokenId: $tokenIdForReset and OTP: $enteredOtp');
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userIdForReset)
          .update({
        'password': hashedPassword,
        'tokenId': tokenIdForReset,  // For rule validation, not stored
        'otp': enteredOtp,           // For rule validation, not stored
      });

      // Mark OTP token as used
      print('Marking reset token as used: $tokenIdForReset');
      await FirebaseFirestore.instance
          .collection('resetTokens')
          .doc(tokenIdForReset)
          .update({'used': true});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset successfully')),
      );

      // Close the dialog and reset state
      Navigator.pop(context);
      emailController.clear();
      otpController.clear();
      newPasswordController.clear();
      setState(() {
        userIdForReset = null;
        userEmailForReset = null;
        tokenIdForReset = null;
        isLoading = false;
        otpSent = false;
      });
    } catch (e) {
      print('Error in resetPassword: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to reset password: $e')),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Enter your email address to receive a password reset OTP',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
                hintText: 'Enter your registered email',
              ),
            ),
            const SizedBox(height: 20),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (!otpSent)
              ElevatedButton(
                onPressed: sendOtp,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text(
                  'Send OTP',
                  style: TextStyle(fontSize: 16),
                ),
              )
            else
              Column(
                children: [
                  ElevatedButton(
                    onPressed: _showOtpDialog,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: const Text(
                      'Enter OTP',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: sendOtp,
                    child: const Text('Resend OTP'),
                  ),
                ],
              ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back to Login'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    otpController.dispose();
    newPasswordController.dispose();
    super.dispose();
  }
}