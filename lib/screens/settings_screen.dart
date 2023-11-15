import 'package:flutter/material.dart';
import 'package:pos_app/services/mysql_service.dart';
import 'package:pos_app/services/sqlite_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          const Text('Database Settings', style: TextStyle(fontSize: 20)),
          ListTile(
            title: const Text('Configure MySQL Database'),
            trailing: const Icon(Icons.cable_rounded),
            onTap: () => MySQLService.showConfigurationDialog(context),
          ),
          ListTile(
            title: const Text('Delete Local Database'),
            trailing: const Icon(Icons.delete),
            onTap: () => SqliteService.deleteDB(context),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
