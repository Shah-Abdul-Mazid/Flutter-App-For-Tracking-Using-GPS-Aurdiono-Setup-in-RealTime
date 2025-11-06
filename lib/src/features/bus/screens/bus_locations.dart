import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart'; // For formatting datetime
import 'package:TrackMyBus/src/features/bus/services/database_service.dart';
import '../models/bus_location.dart';

class BusLocationsScreen extends StatefulWidget {
  const BusLocationsScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _BusLocationsScreenState createState() => _BusLocationsScreenState();
}

class _BusLocationsScreenState extends State<BusLocationsScreen> {
  final DatabaseService _databaseService = DatabaseService();
  bool _buttonsDisabled = false;
  List<String> _busIds = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadBusIds();
  }

  Future<void> _loadBusIds() async {
    final ids = await _databaseService.getBusIds();
    setState(() {
      _busIds = ids;
      _loading = false;
    });
  }

  void _logout() {
    Navigator.pushReplacementNamed(context, '/');
  }

  void _navigateToBusLocation(String busId) async {
    setState(() {
      _buttonsDisabled = true;
    });

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BusLocationPage(busId: busId),
      ),
    );

    setState(() {
      _buttonsDisabled = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5FF),
      appBar: AppBar(
        title: const Text('Select a Bus'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _busIds.isEmpty
          ? const Center(child: Text("No buses found in database"))
          : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _busIds.map((busId) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: ElevatedButton(
                onPressed: _buttonsDisabled ? null : () => _navigateToBusLocation(busId),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  busId,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class BusLocationPage extends StatelessWidget {
  final String busId;
  final DatabaseService _databaseService = DatabaseService();

  BusLocationPage({required this.busId});

  String formatDhakaTime(String timestamp) {
    try {
      DateTime utcTime = DateTime.parse(timestamp).toUtc();
      // Dhaka is UTC+6
      DateTime dhakaTime = utcTime.add(const Duration(hours: 6));
      return DateFormat('yyyy-MM-dd hh:mm a').format(dhakaTime);
    } catch (e) {
      return timestamp; // fallback if parsing fails
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Location for $busId')),
      body: StreamBuilder<List<BusLocation>>(
        stream: _databaseService.getBusLocationsForBus(busId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No locations found for this bus.'));
          }

          final locations = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: locations.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final location = locations[index];
              return ListTile(
                tileColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                leading: const Icon(Icons.location_pin, color: Colors.red),
                title: Text('Bus ID: ${location.busId}'),
                subtitle: Text(
                  'Latitude: ${location.latitude.toStringAsFixed(6)}\n'
                      'Longitude: ${location.longitude.toStringAsFixed(6)}\n'
                      'Time: ${formatDhakaTime(location.recordedAt)}',
                ),
                isThreeLine: true,
              );
            },
          );
        },
      ),
    );
  }
}
