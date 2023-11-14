import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mysql_client/mysql_client.dart';

class MySQLConfiguration {
  static final _mysqlConfigBox = Hive.box('mysql_config');

  static void setConfiguration(
    String host,
    int port,
    String username,
    String password,
  ) {
    _mysqlConfigBox.put('host', host);
    _mysqlConfigBox.put('port', port);
    _mysqlConfigBox.put('username', username);
    _mysqlConfigBox.put('password', password);
  }

  static Map<String, dynamic> getConfiguration() {
    return {
      'host': _mysqlConfigBox.get('host'),
      'port': _mysqlConfigBox.get('port'),
      'username': _mysqlConfigBox.get('username'),
      'password': _mysqlConfigBox.get('password'),
    };
  }

  static void showConfigurationDialog(BuildContext context) {
    Widget? status;

    final hostController = TextEditingController(
      text: _mysqlConfigBox.get('host'),
    );
    final portController = TextEditingController(
      text: _mysqlConfigBox.get('port').toString() == "null"
          ? "3306"
          : _mysqlConfigBox.get('port').toString(),
    );
    final usernameController = TextEditingController(
      text: _mysqlConfigBox.get('username'),
    );
    final passwordController = TextEditingController(
      text: _mysqlConfigBox.get('password'),
    );

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) => AlertDialog(
            title: const Text('MySQL Configuration'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: hostController,
                    decoration: const InputDecoration(
                      labelText: 'Host',
                    ),
                  ),
                  TextField(
                    controller: portController,
                    decoration: const InputDecoration(
                      labelText: 'Port',
                    ),
                  ),
                  TextField(
                    controller: usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                    ),
                  ),
                  TextField(
                    obscureText: true,
                    controller: passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                    ),
                  ),
                  const Gap(20),
                  if (status != null) status!,
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  // check connection
                  setState(() => status = const Text('Connecting...',
                      style: TextStyle(color: Colors.grey)));

                  try {
                    final conn = await MySQLConnection.createConnection(
                      host: hostController.text,
                      port: int.parse(portController.text),
                      userName: usernameController.text,
                      password: passwordController.text,
                    );
                    await conn.connect();
                  } catch (e) {
                    setState(() => status = const Text('Connection failed',
                        style: TextStyle(color: Colors.red)));
                    return;
                  }

                  setState(() => status = const Text('Connection successful',
                      style: TextStyle(color: Colors.green)));
                  setConfiguration(
                    hostController.text,
                    int.parse(portController.text),
                    usernameController.text,
                    passwordController.text,
                  );
                },
                child: const Text('Save'),
              ),
            ],
          ),
        );
      },
    );
  }
}
