import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mysql_client/mysql_client.dart';
import 'package:pos_app/services/sqlite_service.dart';
import 'package:pos_app/widgets/dialogs.dart';
import 'package:pos_app/widgets/global_snackbar.dart';

enum ReturnTypes {
  success,
  failed,
  duplicate,
}

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

  static Future<void> syncFromMySQL(BuildContext context) async {
    try {
      showLoadingDialog('Syncing from MySQL', context);

      final conn = await MySQLConnection.createConnection(
        host: _mysqlConfigBox.get('host'),
        port: _mysqlConfigBox.get('port'),
        userName: _mysqlConfigBox.get('username'),
        password: _mysqlConfigBox.get('password'),
        databaseName: _mysqlConfigBox.get('databaseName'),
      );

      await conn.connect();

      var users = await conn.execute("SELECT * FROM users");
      var products = await conn.execute("SELECT * FROM products");
      var transactions = await conn.execute("SELECT * FROM transactions");

      await conn.close();

      // clear local database and recreate
      await SqliteService.silentDeleteDB();
      await SqliteService.initializeDB();

      // add users
      for (final row in users.rows) {
        final userInfo = row.typedAssoc();
        SqliteService.addUser(
          username: userInfo['username'],
          password: userInfo['password'],
          fname: userInfo['fname'],
          lname: userInfo['lname'],
          phone: userInfo['phone'],
          role: userInfo['role'],
        );
      }

      // add products
      for (final row in products.rows) {
        final productInfo = row.typedAssoc();
        debugPrint(productInfo.toString());
        SqliteService.addProduct(
          barcode: productInfo['barcode'],
          description: productInfo['description'],
          arDesc: productInfo['ar_desc'],
          price: productInfo['price'],
          price2: productInfo['price2'],
          vatPerc: productInfo['Vat_Perc'],
          quantity: productInfo['quantity'],
          location: productInfo['location'],
          expiry: productInfo['expiry'],
        );
      }

      // add transactions
      for (final row in transactions.rows) {
        final transactionInfo = row.typedAssoc();
        SqliteService.addTransaction(
          serial: transactionInfo['Serial'],
          transID: transactionInfo['Trans_ID'],
          transType: transactionInfo['Trans_Type'],
          username: transactionInfo['Username'],
          machineID: transactionInfo['Machine_ID'],
          fromWh: transactionInfo['FROM_WH'],
          toWH: transactionInfo['TO_WH'],
          lineID: transactionInfo['Line_ID'],
          productID: transactionInfo['Product_ID'],
          productName: transactionInfo['Product_Name'],
          productPrice: transactionInfo['Product_Price'],
          productQty: transactionInfo['Product_Qty'],
          productTotal: transactionInfo['Product_Total'],
          taxPerc: transactionInfo['Tax_Perc'],
          discount: transactionInfo['DISC'],
          extraDesc: transactionInfo['Extra_Desc'],
          currency: transactionInfo['Currency'],
        );
      }

      showGlobalSnackBar('Synced from MySQL');

      if (!context.mounted) return;
      Navigator.pop(context);
    } catch (e) {
      debugPrint(e.toString());
      showGlobalSnackBar('Failed to sync from MySQL');
      Navigator.pop(context);
    }
  }

  static Future<dynamic> addUser(String username, String password, String fname,
      String lname, String phone, String role) async {
    try {
      final conn = await MySQLConnection.createConnection(
        host: _mysqlConfigBox.get('host'),
        port: _mysqlConfigBox.get('port'),
        userName: _mysqlConfigBox.get('username'),
        password: _mysqlConfigBox.get('password'),
        databaseName: _mysqlConfigBox.get('databaseName'),
      );
      await conn.connect();

      var stmt = await conn.prepare(
        "INSERT INTO users (username, password, fname, lname, phone, role) VALUES (?, ?, ?, ?, ?, ?)",
      );
      await stmt.execute([username, password, fname, lname, phone, role]);
      await stmt.deallocate();
      await conn.close();

      SqliteService.addUser(
        username: username,
        password: password,
        fname: fname,
        lname: lname,
        phone: phone,
        role: role,
      );

      return ReturnTypes.success;
    } catch (e) {
      debugPrint(e.toString());

      if (e.toString().contains('Duplicate entry')) {
        return ReturnTypes.duplicate;
      }

      return ReturnTypes.failed;
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
}
