import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:TrackMyBus/src/features/authentication/models/user_model.dart';
import 'package:TrackMyBus/src/features/bus/screens/bus_locations.dart'; // Add this
import 'firebase_options.dart';

// Screens
import 'package:TrackMyBus/src/features/authentication/screens/login/login.dart';
import 'package:TrackMyBus/src/features/authentication/screens/signup/signup.dart';
import 'package:TrackMyBus/src/features/authentication/screens/admin/admin_panel.dart';
import 'package:TrackMyBus/src/features/authentication/screens/welcome/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bus Tracking App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name == '/admin') {
          final user = settings.arguments as UserModel;
          return MaterialPageRoute(builder: (_) => AdminPanel(user: user));
        } else if (settings.name == '/home') {
          // ignore: unused_local_variable
          final user = settings.arguments as UserModel;
          return MaterialPageRoute(builder: (_) => HomeScreen());
        } else if (settings.name == '/bus_locations') {
          return MaterialPageRoute(builder: (_) => BusLocationsScreen());
        }

        final routes = {
          '/': (context) => const LoginPage(),
          '/signup': (context) => const SignupPage(),
          '/bus_locations': (context) => BusLocationsScreen(),
        };

        final builder = routes[settings.name];
        if (builder != null) {
          return MaterialPageRoute(builder: builder);
        }

        return MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Center(child: Text('404 - Page Not Found')),
          ),
        );
      },
    );
  }
}