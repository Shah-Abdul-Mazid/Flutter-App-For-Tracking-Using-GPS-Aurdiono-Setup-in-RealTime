// import 'package:flutter/material.dart';
//
// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'TrackMyBus', // Aligned with pubspec.yaml
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         useMaterial3: true,
//       ),
//       home: const HomeScreen(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }
//
// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return BackgroundScaffold(
//       appBar: AppBar(
//         title: const Text('TrackMyBus'),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         foregroundColor: Colors.white,
//       ),
//       overlayOpacity: 0.6,
//       child: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const SizedBox(height: 20),
//             const Text(
//               'Welcome to',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 28,
//                 fontWeight: FontWeight.w300,
//               ),
//             ),
//             const Text(
//               'TrackMyBus',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 40,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 30),
//             _buildFeatureCard(
//               icon: Icons.map,
//               title: 'Campus Map',
//               subtitle: 'Explore our university campus',
//             ),
//             _buildFeatureCard(
//               icon: Icons.directions_bus,
//               title: 'Track Bus',
//               subtitle: 'Live bus tracking',
//             ),
//             _buildFeatureCard(
//               icon: Icons.event,
//               title: 'Events',
//               subtitle: 'See upcoming events',
//             ),
//             const Spacer(),
//             Center(
//               child: ElevatedButton(
//                 onPressed: () {},
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blue[700],
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(30),
//                   ),
//                 ),
//                 child: const Text(
//                   'Get Started',
//                   style: TextStyle(fontSize: 18),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 30),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildFeatureCard({
//     required IconData icon,
//     required String title,
//     required String subtitle,
//   }) {
//     return Card(
//       color: Colors.white.withOpacity(0.1),
//       margin: const EdgeInsets.only(bottom: 15),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(15),
//       ),
//       child: ListTile(
//         contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//         leading: Icon(icon, color: Colors.white, size: 30),
//         title: Text(
//           title,
//           style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//         ),
//         subtitle: Text(
//           subtitle,
//           style: TextStyle(color: Colors.white70),
//         ),
//         trailing: Icon(Icons.arrow_forward, color: Colors.white70),
//         onTap: () {},
//       ),
//     );
//   }
// }
//
// class BackgroundScaffold extends StatelessWidget {
//   final Widget child;
//   final double overlayOpacity;
//   final PreferredSizeWidget? appBar;
//
//   const BackgroundScaffold({
//     super.key,
//     required this.child,
//     this.overlayOpacity = 0.4,
//     this.appBar,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: appBar,
//       extendBodyBehindAppBar: true,
//       body: Stack(
//         fit: StackFit.expand,
//         children: [
//           // Background using WBMP
//           SizedBox.expand(
//             child: Image.asset(
//               'assets/aust.wbmp', // Fixed: Added comma
//               fit: BoxFit.fill, // Stretches to both width & height
//               errorBuilder: (context, error, stackTrace) {
//                 // Fallback for missing/corrupted WBMP
//                 return Container(
//                   color: Colors.grey[800],
//                   child: const Center(
//                     child: Text(
//                       'Failed to load background image',
//                       style: TextStyle(color: Colors.white),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//
//           // Dark overlay
//           Container(
//             color: Colors.black.withOpacity(overlayOpacity),
//           ),
//
//           // Foreground content
//           SafeArea(child: child),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';

class BackgroundScaffold extends StatelessWidget {
  final Widget child;
  final double overlayOpacity;
  final PreferredSizeWidget? appBar;

  const BackgroundScaffold({
    super.key,
    required this.child,
    this.overlayOpacity = 0.4,
    this.appBar,
  });

  // Map device pixel ratio to the closest density asset
  String _getDensityAsset(double pixelRatio) {
    if (pixelRatio <= 1.0) return 'assets/aust_mdpi.png';      // ~mdpi (1x)
    if (pixelRatio <= 1.5) return 'assets/aust_hdpi.png';      // ~hdpi (1.5x)
    if (pixelRatio <= 2.0) return 'assets/aust_xhdpi.png';     // ~xhdpi (2x)
    if (pixelRatio <= 3.0) return 'assets/aust_xxhdpi.png';    // ~xxhdpi (3x)
    return 'assets/aust_xxxhdpi.png';                          // ~xxxhdpi (4x)
  }

  @override
  Widget build(BuildContext context) {
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    final backgroundAsset = _getDensityAsset(pixelRatio);

    return Scaffold(
      appBar: appBar,
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background using density-specific PNG
          SizedBox.expand(
            child: Image.asset(
              backgroundAsset,
              fit: BoxFit.values[0],
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[800],
                  child: const Center(
                    child: Text(
                      'Failed to load background image',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),

          // Dark overlay
          Container(
            color: Colors.black.withOpacity(overlayOpacity),
          ),

          // Foreground content
          SafeArea(child: child),
        ],
      ),
    );
  }
}