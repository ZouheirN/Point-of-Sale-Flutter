import 'package:flutter/material.dart';
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

  static Future<void> syncFromMySQL(BuildContext? context,
      {bool showSnackBar = true}) async {
    try {
      if (context != null) {
        showLoadingDialog('Syncing from MySQL', context);
      }

      // clear local database and recreate
      await SqliteService.silentDeleteDB();
      await SqliteService.initializeDB();

      // sync users
      if (await syncUsersFromMySQL() == ReturnTypes.failed) {
        throw Exception('Failed to sync users from MySQL');
      }
      debugPrint('Finished syncing users from MySQL');

      // sync products
      if (await syncProductsFromMySQL() == ReturnTypes.failed) {
        throw Exception('Failed to sync products from MySQL');
      }
      debugPrint('Finished syncing products from MySQL');

      // sync transactions
      if (await syncTransactionsFromMySQL() == ReturnTypes.failed) {
        throw Exception('Failed to sync transactions from MySQL');
      }
      debugPrint('Finished syncing transactions from MySQL');

      // sync transactions options
      if (await syncTransactionOptionsFromMySQL() == ReturnTypes.failed) {
        throw Exception('Failed to sync transactions options from MySQL');
      }
      debugPrint('Finished syncing transactions options from MySQL');

      // sync customers
      if (await syncCustomersFromMySQL() == ReturnTypes.failed) {
        throw Exception('Failed to sync customers from MySQL');
      }
      debugPrint('Finished syncing customers from MySQL');

      // sync warehouses
      if (await syncWarehousesFromMySQL() == ReturnTypes.failed) {
        throw Exception('Failed to sync warehouses from MySQL');
      }
      debugPrint('Finished syncing warehouses from MySQL');

      if (showSnackBar) {
        showGlobalSnackBar('Successfully synced from MySQL');
      }

      if (context != null) {
        if (!context.mounted) return;
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint(e.toString());
      showGlobalSnackBar('Failed to sync from MySQL');
      if (context != null) {
        if (!context.mounted) return;
        Navigator.pop(context);
      }
    }
  }

  static Future<dynamic> syncUsersFromMySQL() async {
    try {
      final conn = await MySQLConnection.createConnection(
        host: _mysqlConfigBox.get('host'),
        port: _mysqlConfigBox.get('port'),
        userName: _mysqlConfigBox.get('username'),
        password: _mysqlConfigBox.get('password'),
        databaseName: _mysqlConfigBox.get('databaseName'),
      );

      await conn.connect();

      var users = await conn.execute("SELECT * FROM users");

      await conn.close();

      // clear local users database and recreate
      await SqliteService.deleteAllUsers();

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

      return ReturnTypes.success;
    } catch (e) {
      debugPrint(e.toString());
      return ReturnTypes.failed;
    }
  }

  static Future<dynamic> syncProductsFromMySQL() async {
    try {
      final conn = await MySQLConnection.createConnection(
        host: _mysqlConfigBox.get('host'),
        port: _mysqlConfigBox.get('port'),
        userName: _mysqlConfigBox.get('username'),
        password: _mysqlConfigBox.get('password'),
        databaseName: _mysqlConfigBox.get('databaseName'),
      );

      await conn.connect();

      var products = await conn.execute("SELECT * FROM products");

      await conn.close();

      // clear local products database and recreate
      await SqliteService.deleteAllProducts();

      // add products
      for (final row in products.rows) {
        final productInfo = row.typedAssoc();
        SqliteService.addProduct(
          barcode: productInfo['barcode'],
          category: productInfo['category'],
          description: productInfo['description'],
          arDesc: productInfo['ar_desc'],
          price: productInfo['price'],
          price2: productInfo['price2'],
          vatPerc: productInfo['vat_perc'],
          quantity: productInfo['quantity'],
          location: productInfo['location'],
          expiry: productInfo['expiry'],
        );
      }

      return ReturnTypes.success;
    } catch (e) {
      debugPrint(e.toString());
      return ReturnTypes.failed;
    }
  }

  static Future<dynamic> syncTransactionsFromMySQL() async {
    try {
      final conn = await MySQLConnection.createConnection(
        host: _mysqlConfigBox.get('host'),
        port: _mysqlConfigBox.get('port'),
        userName: _mysqlConfigBox.get('username'),
        password: _mysqlConfigBox.get('password'),
        databaseName: _mysqlConfigBox.get('databaseName'),
      );

      await conn.connect();

      var transactions = await conn.execute("SELECT * FROM transactions");

      await conn.close();

      // clear local transactions database and recreate
      await SqliteService.deleteAllTransactions();

      // add transactions
      for (final row in transactions.rows) {
        final transactionInfo = row.typedAssoc();
        SqliteService.addTransaction(
          serial: transactionInfo['serial'],
          transID: transactionInfo['trans_id'],
          transType: transactionInfo['trans_type'],
          username: transactionInfo['username'],
          machineID: transactionInfo['machine_id'],
          customer: transactionInfo['customer'],
          fromWh: transactionInfo['from_wh'],
          toWH: transactionInfo['to_wh'],
          lineID: transactionInfo['line_id'],
          productID: transactionInfo['product_id'],
          productName: transactionInfo['product_name'],
          productPrice: transactionInfo['product_price'],
          productQty: transactionInfo['product_qty'],
          productTotal: transactionInfo['product_total'],
          taxPerc: transactionInfo['tax_perc'],
          discount: transactionInfo['discount'],
          extraDesc: transactionInfo['extra_desc'],
          currency: transactionInfo['currency'],
          reference: transactionInfo['reference'],
          transDate: transactionInfo['trans_date'],
        );
      }

      return ReturnTypes.success;
    } catch (e) {
      debugPrint(e.toString());
      return ReturnTypes.failed;
    }
  }

  static Future<dynamic> syncTransactionOptionsFromMySQL() async {
    try {
      final conn = await MySQLConnection.createConnection(
        host: _mysqlConfigBox.get('host'),
        port: _mysqlConfigBox.get('port'),
        userName: _mysqlConfigBox.get('username'),
        password: _mysqlConfigBox.get('password'),
        databaseName: _mysqlConfigBox.get('databaseName'),
      );

      await conn.connect();

      var products = await conn.execute("SELECT * FROM transactionOptions");

      await conn.close();

      // clear local transaction options database and recreate
      await SqliteService.deleteAllTransactionOptions();

      // add transaction options
      for (final row in products.rows) {
        final transactionOption = row.typedAssoc();
        SqliteService.addTransactionOption(
          id: transactionOption['id'],
          description: transactionOption['description'],
          showCustomer: transactionOption['showCustomer'],
          showCurrency: transactionOption['showCurrency'],
          showFromWh: transactionOption['showFromWh'],
          showToWh: transactionOption['showToWh'],
          showAutoAdd: transactionOption['showAutoAdd'],
          affectQty: transactionOption['affectQty'],
        );
      }

      return ReturnTypes.success;
    } catch (e) {
      debugPrint(e.toString());
      return ReturnTypes.failed;
    }
  }

  static Future<dynamic> syncCustomersFromMySQL() async {
    try {
      final conn = await MySQLConnection.createConnection(
        host: _mysqlConfigBox.get('host'),
        port: _mysqlConfigBox.get('port'),
        userName: _mysqlConfigBox.get('username'),
        password: _mysqlConfigBox.get('password'),
        databaseName: _mysqlConfigBox.get('databaseName'),
      );

      await conn.connect();

      var products = await conn.execute("SELECT * FROM customers");

      await conn.close();

      // clear local transaction options database and recreate
      await SqliteService.deleteAllCustomers();

      // add transaction options
      for (final row in products.rows) {
        final customer = row.typedAssoc();
        SqliteService.addCustomer(
          id: customer['id'],
          name: customer['name'],
          address: customer['address'],
          contactNumber: customer['contactNumber'],
        );
      }

      return ReturnTypes.success;
    } catch (e) {
      debugPrint(e.toString());
      return ReturnTypes.failed;
    }
  }

  static Future<dynamic> syncWarehousesFromMySQL() async {
    try {
      final conn = await MySQLConnection.createConnection(
        host: _mysqlConfigBox.get('host'),
        port: _mysqlConfigBox.get('port'),
        userName: _mysqlConfigBox.get('username'),
        password: _mysqlConfigBox.get('password'),
        databaseName: _mysqlConfigBox.get('databaseName'),
      );

      await conn.connect();

      var products = await conn.execute("SELECT * FROM warehouse");

      await conn.close();

      // clear local transaction options database and recreate
      await SqliteService.deleteAllWarehouses();

      // add transaction options
      for (final row in products.rows) {
        final warehouse = row.typedAssoc();
        SqliteService.addWarehouse(
          code: warehouse['code'],
          name: warehouse['name'],
        );
      }

      return ReturnTypes.success;
    } catch (e) {
      debugPrint(e.toString());
      return ReturnTypes.failed;
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
