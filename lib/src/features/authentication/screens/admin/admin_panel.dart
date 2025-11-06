import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:TrackMyBus/src/utils/screen_wrapper.dart';
import '../../models/user_model.dart';
import 'package:TrackMyBus/src/features/bus/models/bus_model.dart';

class AdminPanel extends StatefulWidget {
  final UserModel user;

  const AdminPanel({super.key, required this.user});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> with TickerProviderStateMixin {
  // ---------- User Form ----------
  final _formKeyUser = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController altEmailController = TextEditingController();

  String _selectedRole = 'user';
  bool _isLoadingUser = false;

  // ---------- Bus Form ----------
  final _formKeyBus = GlobalKey<FormState>();
  final TextEditingController busIdController = TextEditingController();
  final TextEditingController busNumberController = TextEditingController();
  final TextEditingController busNameController = TextEditingController();
  final TextEditingController busRouteController = TextEditingController();
  final TextEditingController busSeatsController = TextEditingController();
  final TextEditingController driverNameController = TextEditingController();
  String _selectedStatus = 'active';
  bool _isLoadingBus = false;

  late TabController _tabController;
  final DatabaseReference _busRef = FirebaseDatabase.instance.ref('buses');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    dobController.dispose();
    contactController.dispose();
    altEmailController.dispose();
    busIdController.dispose();
    busNumberController.dispose();
    busNameController.dispose();
    busRouteController.dispose();
    busSeatsController.dispose();
    driverNameController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _logout() {
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  // ---------- USER CRUD ----------
  Future<void> _addUser() async {
    if (_formKeyUser.currentState!.validate()) {
      setState(() => _isLoadingUser = true);
      try {
        final userRef = FirebaseFirestore.instance.collection('users').doc();
        final newUser = UserModel(
          id: userRef.id,
          username: usernameController.text.trim(),
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
          role: _selectedRole,
          status: 'active',
          firstName: firstNameController.text.trim(),
          lastName: lastNameController.text.trim(),
          dateOfBirth: dobController.text.trim(),
          contact: contactController.text.trim(),
          altEmail: altEmailController.text.trim().isEmpty ? null : altEmailController.text.trim(),
          emailVerified: false,
          contactVerified: false,
        );

        await userRef.set(newUser.toJson());

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User "${newUser.username}" created successfully ✅'),
            backgroundColor: Colors.green,
          ),
        );

        // Clear all fields
        usernameController.clear();
        emailController.clear();
        passwordController.clear();
        firstNameController.clear();
        lastNameController.clear();
        dobController.clear();
        contactController.clear();
        altEmailController.clear();
        setState(() => _selectedRole = 'user');
      } catch (e) {
        debugPrint('Error creating user: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating user: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() => _isLoadingUser = false);
      }
    }
  }

  // ---------- BUS CRUD ----------
  Future<void> _addBus() async {
    if (_formKeyBus.currentState!.validate()) {
      setState(() => _isLoadingBus = true);
      try {
        final busId = busIdController.text.trim();
        final newBusRef = _busRef.child(busId);

        final dhakaTime = DateTime.now().toUtc().add(const Duration(hours: 6));

        final newBus = BusModel(
          id: busId,
          busId: busId,
          busNumber: busNumberController.text.trim(),
          busName: busNameController.text.trim(),
          route: busRouteController.text.trim(),
          capacity: int.tryParse(busSeatsController.text.trim()) ?? 0,
          driverName: driverNameController.text.trim(),
          status: _selectedStatus,
          createdAt: dhakaTime,
        );

        await newBusRef.set(newBus.toJson());

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bus added successfully ✅'),
            backgroundColor: Colors.green,
          ),
        );

        busIdController.clear();
        busNumberController.clear();
        busNameController.clear();
        busRouteController.clear();
        busSeatsController.clear();
        driverNameController.clear();
        setState(() => _selectedStatus = 'active');
      } catch (e) {
        debugPrint('Error adding bus: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding bus: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() => _isLoadingBus = false);
      }
    }
  }

  Future<void> _deleteBus(String busId) async {
    try {
      await _busRef.child(busId).remove();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bus deleted ✅'), backgroundColor: Colors.red),
      );
    } catch (e) {
      debugPrint('Error deleting bus: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting bus: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _updateBusStatus(String busId, String newStatus) async {
    try {
      await _busRef.child(busId).update({'status': newStatus});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bus status updated to $newStatus ✅'),
          backgroundColor: Colors.blue,
        ),
      );
    } catch (e) {
      debugPrint('Error updating bus status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating bus status: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _showUpdateBusDialog(BusModel bus) async {
    final TextEditingController updateBusNumberController = TextEditingController(text: bus.busNumber);
    final TextEditingController updateBusNameController = TextEditingController(text: bus.busName);
    final TextEditingController updateBusRouteController = TextEditingController(text: bus.route);
    final TextEditingController updateBusSeatsController = TextEditingController(text: bus.capacity.toString());
    final TextEditingController updateDriverNameController = TextEditingController(text: bus.driverName);
    String updateStatus = bus.status;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update Bus'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField(controller: updateBusNumberController, label: 'Bus Number', icon: Icons.confirmation_number),
                const SizedBox(height: 12),
                _buildTextField(controller: updateBusNameController, label: 'Bus Name', icon: Icons.directions_bus),
                const SizedBox(height: 12),
                _buildTextField(controller: updateBusRouteController, label: 'Route', icon: Icons.alt_route),
                const SizedBox(height: 12),
                _buildTextField(controller: updateBusSeatsController, label: 'Seats', icon: Icons.event_seat),
                const SizedBox(height: 12),
                _buildTextField(controller: updateDriverNameController, label: 'Driver Name', icon: Icons.person),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  dropdownColor: Colors.deepPurple[200],
                  value: updateStatus,
                  items: const [
                    DropdownMenuItem(value: 'active', child: Text('Active')),
                    DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                    DropdownMenuItem(value: 'maintenance', child: Text('Maintenance')),
                  ],
                  onChanged: (v) => updateStatus = v ?? 'active',
                  decoration: _dropdownDecoration('Status'),
                  style: const TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final dhakaTime = DateTime.now().toUtc().add(const Duration(hours: 6));
                final updatedBus = BusModel(
                  id: bus.id,
                  busId: bus.busId,
                  busNumber: updateBusNumberController.text.trim(),
                  busName: updateBusNameController.text.trim(),
                  route: updateBusRouteController.text.trim(),
                  capacity: int.tryParse(updateBusSeatsController.text.trim()) ?? bus.capacity,
                  driverName: updateDriverNameController.text.trim(),
                  status: updateStatus,
                  createdAt: dhakaTime,
                );
                await _busRef.child(bus.id).set(updatedBus.toJson());
                Navigator.pop(context);
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.user.role != 'admin') {
      return buildScreenWithBackground(
        appBar: AppBar(title: const Text('Access Denied')),
        overlayOpacity: 0.6,
        content: const Center(
          child: Text(
            'Access Denied ❌\nYou are not an admin.',
            style: TextStyle(color: Colors.white, fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return buildScreenWithBackground(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        actions: [IconButton(icon: const Icon(Icons.logout), onPressed: _logout)],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.people), text: "Users"),
            Tab(icon: Icon(Icons.directions_bus), text: "Buses"),
          ],
        ),
      ),
      overlayOpacity: 0.4,
      content: TabBarView(
        controller: _tabController,
        children: [_buildUserTab(), _buildBusTab()],
      ),
    );
  }

  // ---------- UI for User Tab ----------
  Widget _buildUserTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Form(
          key: _formKeyUser,
          child: Column(
            children: [
              _buildTextField(controller: usernameController, label: "Username", icon: Icons.person),
              const SizedBox(height: 12),
              _buildTextField(controller: emailController, label: "Email", icon: Icons.email),
              const SizedBox(height: 12),
              _buildTextField(controller: passwordController, label: "Password", icon: Icons.lock, obscureText: true),
              const SizedBox(height: 12),
              _buildTextField(controller: firstNameController, label: "First Name", icon: Icons.person),
              const SizedBox(height: 12),
              _buildTextField(controller: lastNameController, label: "Last Name", icon: Icons.person_outline),
              const SizedBox(height: 12),
              _buildTextField(controller: dobController, label: "Date of Birth (YYYY-MM-DD)", icon: Icons.cake),
              const SizedBox(height: 12),
              _buildTextField(controller: contactController, label: "Contact Number", icon: Icons.phone),
              const SizedBox(height: 12),
              _buildTextField(controller: altEmailController, label: "Alt Email (Optional)", icon: Icons.alternate_email),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                dropdownColor: Colors.deepPurple[200],
                value: _selectedRole,
                items: const [
                  DropdownMenuItem(value: 'user', child: Text('User')),
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                ],
                onChanged: (v) => setState(() => _selectedRole = v ?? 'user'),
                decoration: _dropdownDecoration('Role'),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoadingUser ? null : _addUser,
                child: _isLoadingUser
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Create User'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- UI for Bus Tab ----------
  Widget _buildBusTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Form(
            key: _formKeyBus,
            child: Column(
              children: [
                _buildTextField(controller: busIdController, label: "Bus ID", icon: Icons.badge),
                const SizedBox(height: 12),
                _buildTextField(controller: busNumberController, label: "Bus Number", icon: Icons.confirmation_number),
                const SizedBox(height: 12),
                _buildTextField(controller: busNameController, label: "Bus Name", icon: Icons.directions_bus),
                const SizedBox(height: 12),
                _buildTextField(controller: busRouteController, label: "Route", icon: Icons.alt_route),
                const SizedBox(height: 12),
                _buildTextField(controller: busSeatsController, label: "Seats", icon: Icons.event_seat),
                const SizedBox(height: 12),
                _buildTextField(controller: driverNameController, label: "Driver Name", icon: Icons.person),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  dropdownColor: Colors.deepPurple[200],
                  value: _selectedStatus,
                  items: const [
                    DropdownMenuItem(value: 'active', child: Text('Active')),
                    DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                    DropdownMenuItem(value: 'maintenance', child: Text('Maintenance')),
                  ],
                  onChanged: (v) => setState(() => _selectedStatus = v ?? 'active'),
                  decoration: _dropdownDecoration('Status'),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isLoadingBus ? null : _addBus,
                  child: _isLoadingBus
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Add Bus'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<DatabaseEvent>(
              stream: _busRef.onValue,
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
                  return const Center(child: Text("No buses found", style: TextStyle(color: Colors.white)));
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
                }

                final data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>?;
                if (data == null) {
                  return const Center(child: Text("No buses found", style: TextStyle(color: Colors.white)));
                }

                final buses = data.entries.map((entry) {
                  final busData = Map<String, dynamic>.from(entry.value as Map);
                  return BusModel.fromJson(busData, entry.key as String);
                }).toList();

                return ListView.builder(
                  itemCount: buses.length,
                  itemBuilder: (context, index) {
                    final bus = buses[index];
                    return Card(
                      color: Colors.white.withOpacity(0.2),
                      child: ListTile(
                        title: Text(bus.busName, style: const TextStyle(color: Colors.white)),
                        subtitle: Text(
                          "ID: ${bus.busId} | Number: ${bus.busNumber} | Route: ${bus.route} | Seats: ${bus.capacity} | Driver: ${bus.driverName}",
                          style: const TextStyle(color: Colors.white70),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            DropdownButton<String>(
                              value: bus.status,
                              dropdownColor: Colors.deepPurple[200],
                              items: const [
                                DropdownMenuItem(value: 'active', child: Text('Active')),
                                DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                                DropdownMenuItem(value: 'maintenance', child: Text('Maintenance')),
                              ],
                              onChanged: (newStatus) {
                                if (newStatus != null && newStatus != bus.status) {
                                  _updateBusStatus(bus.id, newStatus);
                                }
                              },
                              style: const TextStyle(color: Colors.white),
                              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                            ),
                            IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showUpdateBusDialog(bus)),
                            IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteBus(bus.id)),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Helpers ----------
  InputDecoration _dropdownDecoration(String label) => InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: Colors.white70),
    filled: true,
    fillColor: Colors.deepPurple[300],
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
  );

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
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
        prefixIcon: Icon(icon, color: Colors.white),
        filled: true,
        fillColor: Colors.deepPurple[300],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
