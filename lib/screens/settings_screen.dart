import 'package:flutter/material.dart';
import 'package:pos_app/services/mysql_configuration.dart';

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
          Text('Database Settings', style: TextStyle(fontSize: 20)),
          ListTile(
            title: Text('Configure MySQL Database'),
            trailing: Icon(Icons.cable_rounded),
            onTap: () => MySQLConfiguration.showConfigurationDialog(context),
          ),
          Divider(),
        ],
      ),
    );
  }
}
