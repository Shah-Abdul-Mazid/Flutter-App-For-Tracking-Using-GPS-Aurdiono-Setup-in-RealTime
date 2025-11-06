class BusLocation {
  final String id;
  final String busId;
  final double latitude;
  final double longitude;
  final String recordedAt;

  BusLocation({
    required this.id,
    required this.busId,
    required this.latitude,
    required this.longitude,
    required this.recordedAt,
  });

  // From Firebase Realtime Database / Firestore
  factory BusLocation.fromMap(String id, Map<dynamic, dynamic> map) {
    return BusLocation(
      id: id,
      busId: map['bus_id'] ?? '',
      latitude: double.tryParse(map['latitude'].toString()) ?? 0.0,
      longitude: double.tryParse(map['longitude'].toString()) ?? 0.0,
      recordedAt: map['recorded_at'] ?? 'N/A',
    );
  }

  // To Firebase
  Map<String, dynamic> toJson() {
    return {
      'bus_id': busId,
      'latitude': latitude,
      'longitude': longitude,
      'recorded_at': recordedAt,
    };
  }

  // Optional: Convert to Dhaka time for display
  String recordedAtDhaka() {
    try {
      DateTime utcTime = DateTime.parse(recordedAt).toUtc();
      DateTime dhakaTime = utcTime.add(const Duration(hours: 6));
      return "${dhakaTime.year}-${dhakaTime.month.toString().padLeft(2,'0')}-${dhakaTime.day.toString().padLeft(2,'0')} "
          "${dhakaTime.hour.toString().padLeft(2,'0')}:${dhakaTime.minute.toString().padLeft(2,'0')}";
    } catch (_) {
      return recordedAt;
    }
  }
}
