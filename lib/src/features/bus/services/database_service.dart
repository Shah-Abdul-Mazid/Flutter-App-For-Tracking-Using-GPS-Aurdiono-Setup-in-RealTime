import 'package:firebase_database/firebase_database.dart';
import '../models/bus_location.dart';

class DatabaseService {
  final DatabaseReference _busLocationsRef =
  FirebaseDatabase.instance.ref().child('bus_locations');

  // Stream all bus locations
  Stream<List<BusLocation>> getBusLocations() {
    return _busLocationsRef.onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null || data is! Map) return [];

      return (data).entries.map((entry) {
        final id = entry.key.toString();
        final map = entry.value as Map<dynamic, dynamic>;
        return BusLocation.fromMap(id, map);
      }).toList();
    });
  }

  // Get list of unique bus IDs
  Future<List<String>> getBusIds() async {
    final snapshot = await _busLocationsRef.once();
    final data = snapshot.snapshot.value;

    if (data == null || data is! Map) return [];

    final Set<String> busIds = {};

    (data).forEach((key, value) {
      if (value is Map && value['bus_id'] != null) {
        busIds.add(value['bus_id'].toString());
      }
    });

    return busIds.toList()..sort(); // sorted alphabetically
  }

  // Stream locations for a specific bus ID
  Stream<List<BusLocation>> getBusLocationsForBus(String busId) {
    return _busLocationsRef.onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null || data is! Map) return [];

      return (data)
          .entries
          .where((entry) {
        final value = entry.value;
        if (value is Map && value['bus_id'] != null) {
          return value['bus_id'].toString() == busId;
        }
        return false;
      })
          .map((entry) {
        final id = entry.key.toString();
        final map = entry.value as Map<dynamic, dynamic>;
        return BusLocation.fromMap(id, map);
      })
          .toList();
    });
  }
}
