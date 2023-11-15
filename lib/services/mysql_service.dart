import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mysql_client/mysql_client.dart';
import 'package:pos_app/services/sqlite_service.dart';

class MySQLService {
  static final _mysqlConfigBox = Hive.box('mysql_config');

  static void setConfiguration(String host, int port, String username,
      String password, String databaseName) {
    _mysqlConfigBox.put('host', host);
    _mysqlConfigBox.put('port', port);
    _mysqlConfigBox.put('username', username);
    _mysqlConfigBox.put('password', password);
    _mysqlConfigBox.put('databaseName', databaseName);
  }

  // static Map<String, dynamic> getConfiguration() {
  //   return {
  //     'host': _mysqlConfigBox.get('host'),
  //     'port': _mysqlConfigBox.get('port'),
  //     'username': _mysqlConfigBox.get('username'),
  //     'password': _mysqlConfigBox.get('password'),
  //   };
  // }

  static Future<bool> _addUser(String username, String password, String fname,
      String lname, String phone, String role) async {
    try {
      final conn = await MySQLConnection.createConnection(
          host: _mysqlConfigBox.get('host'),
          port: _mysqlConfigBox.get('port'),
          userName: _mysqlConfigBox.get('username'),
          password: _mysqlConfigBox.get('password'),
          databaseName: _mysqlConfigBox.get('databaseName'));
      await conn.connect();

      var stmt = await conn.prepare(
        "INSERT INTO users (username, password, fname, lname, phone, role) VALUES (?, ?, ?, ?, ?, ?)",
      );
      final result =
          await stmt.execute([username, password, fname, lname, phone, role]);
      await stmt.deallocate();

      for (final row in result.rows) {
        final userInfo = row.typedAssoc();
        SqliteService.addUser(
          id: userInfo['id'],
          username: userInfo['username'],
          password: userInfo['password'],
          fname: userInfo['fname'],
          lname: userInfo['lname'],
          phone: userInfo['phone'],
          role: userInfo['role'],
        );
      }
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
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
    final databaseNameController = TextEditingController(
      text: _mysqlConfigBox.get('databaseName'),
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
                  TextField(
                    controller: databaseNameController,
                    decoration: const InputDecoration(
                      labelText: 'Database Name',
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
                      databaseName: databaseNameController.text,
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
                    databaseNameController.text,
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

  static void showAddUserDialog(BuildContext context) {
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    final fnameController = TextEditingController();
    final lnameController = TextEditingController();
    final phoneController = TextEditingController();
    final roleController = TextEditingController();

    final formKey = GlobalKey<FormState>();

    Text status = const Text("");

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text('Add User'),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a username';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: fnameController,
                      decoration: const InputDecoration(
                        labelText: 'First Name',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your first name';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: lnameController,
                      decoration: const InputDecoration(
                        labelText: 'Last Name',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your last name';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone',
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a phone number';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: roleController,
                      decoration: const InputDecoration(
                        labelText: 'Role',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a role';
                        }
                        return null;
                      },
                    ),
                    const Gap(20),
                    status,
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    setState(() {
                      status = const Text('Adding user...',
                          style: TextStyle(color: Colors.grey));
                    });

                    // todo check if user already exists

                    // add to MySQL
                    final result = await _addUser(
                      usernameController.text,
                      passwordController.text,
                      fnameController.text,
                      lnameController.text,
                      phoneController.text,
                      roleController.text,
                    );

                    if (!result) {
                      setState(() {
                        status = const Text('Failed to add user',
                            style: TextStyle(color: Colors.red));
                      });
                    } else {
                      setState(() {
                        status = const Text('User added',
                            style: TextStyle(color: Colors.green));
                      });
                    }
                  }
                },
                child: const Text('Add'),
              ),
            ],
          );
        });
      },
    );
  }
}
