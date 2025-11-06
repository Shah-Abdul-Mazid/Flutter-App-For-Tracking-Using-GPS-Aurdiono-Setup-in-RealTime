
class BusModel {
  final String id;
  final String busId;
  final String busNumber;
  final String busName;
  final String route;
  final int capacity;
  final String driverName;
  final String status;
  final DateTime createdAt;

  BusModel({
    required this.id,
    required this.busId,
    required this.busNumber,
    required this.busName,
    required this.route,
    required this.capacity,
    required this.driverName,
    required this.status,
    required this.createdAt,
  });

  // From JSON / Firebase
  factory BusModel.fromJson(Map<String, dynamic> json, String id) {
    return BusModel(
      id: id,
      busId: json['bus_id'] ?? '',
      busNumber: json['busNumber'] ?? '',
      busName: json['busName'] ?? '',
      route: json['route'] ?? '',
      capacity: json['capacity'] ?? 0,
      driverName: json['driverName'] ?? '',
      status: json['status'] ?? 'active',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  // To JSON / Firebase
  Map<String, dynamic> toJson() {
    return {
      'bus_id': busId,
      'busNumber': busNumber,
      'busName': busName,
      'route': route,
      'capacity': capacity,
      'driverName': driverName,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
