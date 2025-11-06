import 'package:flutter/material.dart';
import 'package:TrackMyBus/src/utils/screen_wrapper.dart';
import 'package:TrackMyBus/src/features/bus/screens/bus_locations.dart';

class HomeScreen extends StatelessWidget {
  final bool isWelcomeScreen; // Determines if this is a welcome screen (no logout, pushReplacement)

  const HomeScreen({super.key, this.isWelcomeScreen = false});

  @override
  Widget build(BuildContext context) {
    // Configure AppBar based on isWelcomeScreen
    final appBar = AppBar(
      title: const Text('Shuttle Bus Tracker'),
      actions: isWelcomeScreen
          ? null
          : [
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
          },
          tooltip: 'Logout',
        ),
      ],
    );

    return buildScreenWithBackground(
      appBar: appBar,
      overlayOpacity: 0.5,
      content: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.directions_bus,
              size: 100,
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            const Text(
              'Shuttle Bus Tracker',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 16),
              child: Text(
                'View real-time GPS locations of your buses.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (isWelcomeScreen) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => BusLocationsScreen()),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => BusLocationsScreen()),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Get Started', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}