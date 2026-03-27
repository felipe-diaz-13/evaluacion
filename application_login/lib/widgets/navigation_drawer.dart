import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  final String username;
  final Function(int) onItemSelected;
  final VoidCallback onLogout;
  final int currentIndex;

  const CustomDrawer({
    super.key,
    required this.username,
    required this.onItemSelected,
    required this.onLogout,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [_buildHeader(context), _buildMenuItems(context)],
      ), // ListView
    ); // Drawer
  }

  Widget _buildHeader(BuildContext context) {
    return DrawerHeader(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withValues(alpha: 0.8),
          ],
        ), // LinearGradient
      ), // BoxDecoration
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 40, color: Colors.blue),
          ), // CircleAvatar
          const SizedBox(height: 15),
          Text(
            username,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ), // TextStyle
          ), // Text
        ],
      ), // Column
    ); // DrawerHeader
  }

  Widget _buildMenuItems(BuildContext context) {
    return Column(
      children: [
        _buildListTile(context, Icons.home, 'Inicio', 0, currentIndex == 0),
        _buildListTile(
          context,
          Icons.manage_accounts,
          'Estado de Usuario',
          1,
          currentIndex == 1,
        ),
        const Divider(),
        _buildLogoutTile(context),
      ],
    ); // Column
  }

  Widget _buildListTile(
    BuildContext context,
    IconData icon,
    String title,
    int index,
    bool isSelected,
  ) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Theme.of(context).primaryColor : Colors.grey[700],
      ), // Icon
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
        ), // TextStyle
      ), // Text
      trailing: isSelected
          ? Icon(Icons.arrow_forward, color: Theme.of(context).primaryColor, size: 20)
          : null,
      onTap: () => onItemSelected(index),
      selected: isSelected,
      selectedTileColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
    ); // ListTile
  }

  Widget _buildLogoutTile(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.logout, color: Colors.red),
      title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
      onTap: () {
        Navigator.pop(context);
        onLogout();
      },
    ); // ListTile
  }
}
