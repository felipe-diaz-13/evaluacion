import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'user_status_form.dart';

class UserScreen extends StatefulWidget {
  final String username;
  final String password;

  const UserScreen({super.key, required this.username, required this.password});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _statuses = [];

  @override
  void initState() {
    super.initState();
    _loadStatuses();
  }

  Future<void> _loadStatuses() async {
    setState(() => _isLoading = true);
    final statuses = await ApiService().getUserStatus();
    if (!mounted) return;
    setState(() {
      _statuses = statuses;
      _isLoading = false;
    });
  }

  Color _statusColor(String name) {
    switch (name.toLowerCase()) {
      case 'active':   return Colors.green;
      case 'inactive': return Colors.orange;
      case 'blocked':  return Colors.red;
      case 'delete':   return Colors.grey;
      default:         return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const UserStatusFormScreen()),
          );
          if (result == true) _loadStatuses();
        },
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Estado'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStatuses,
              child: _statuses.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 80),
                        Center(child: Text('No hay estados registrados')),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                      itemCount: _statuses.length,
                      itemBuilder: (_, i) {
                        final s = _statuses[i];
                        final name = s['User_status_name'] ?? '-';
                        final desc = s['User_status_description'] ?? '-';
                        final color = _statusColor(name);
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: color.withValues(alpha: 0.15),
                              child: Icon(Icons.circle, color: color, size: 16),
                            ),
                            title: Text(
                              name,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(desc),
                            trailing: Chip(
                              label: Text(
                                'ID: ${s['User_status_id']}',
                                style: const TextStyle(fontSize: 11),
                              ),
                              backgroundColor: color.withValues(alpha: 0.1),
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
