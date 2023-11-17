import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';
import 'package:pos_app/widgets/dialogs.dart';
import 'package:pos_app/widgets/global_snackbar.dart';
import 'package:sqflite/sqflite.dart';

class SqliteService {
  static Future<Database> initializeDB() async {
    String path = await getDatabasesPath();

    return openDatabase(
      join(path, 'database.db'),
      onCreate: (database, version) async {
        // create users table
        await database.execute('''
        CREATE TABLE IF NOT EXISTS users (
          username varchar(255) PRIMARY KEY,
          password varchar(255),
          fname varchar(255),
          lname varchar(255),
          phone varchar(255),
          role varchar(255)
        );
        ''');
        // create products table
        await database.execute('''
          CREATE TABLE IF NOT EXISTS products (
            barcode varchar(255) PRIMARY KEY,
            description TEXT,
            category TEXT,
            ar_desc TEXT,
            price REAL,
            price2 REAL,
            vat_perc INTEGER,
            quantity REAL,
            location TEXT,
            expiry TEXT
          );
          ''');
        // create transactions table
        await database.execute('''
          CREATE TABLE IF NOT EXISTS transactions (
            serial INTEGER PRIMARY KEY,
            trans_id INTEGER,
            trans_type VARCHAR(20),
            username VARCHAR(20),
            machine_id VARCHAR(25),
            customer VARCHAR(25),
            from_wh VARCHAR(10),
            to_wh VARCHAR(10),
            line_id INTEGER,
            product_id VARCHAR(25),
            product_name VARCHAR(100),
            product_price REAL,
            product_qty REAL,
            product_total REAL,
            tax_perc INTEGER,
            discount REAL,
            extra_desc VARCHAR(50),
            currency VARCHAR(3),
            reference VARCHAR(25),
            trans_date TEXT
          );
          ''');
        // create transactions options table
        await database.execute('''
          CREATE TABLE IF NOT EXISTS transactionOptions (
            id integer primary key,
            description varchar(255),
            showCustomer INTEGER,
            showCurrency INTEGER,
            showFromWh INTEGER,
            showToWh INTEGER,
            showAutoAdd INTEGER,
            affectQty INTEGER
          );
          ''');
        // create warehouse tables
        await database.execute('''
        CREATE TABLE IF NOT EXISTS warehouse (
          code varchar(255) PRIMARY KEY,
          name TEXT
        );
        ''');
        // create customers table
        await database.execute('''
        CREATE TABLE IF NOT EXISTS customers (
          id INTEGER PRIMARY KEY,
          name TEXT,
          address TEXT,
          contactNumber TEXT
        );
        ''');
      },
      version: 1,
    );
  }

  static Future<void> silentDeleteDB() async {
    String path = await getDatabasesPath();
    await deleteDatabase(join(path, 'database.db'));
  }

  static Future<void> deleteDB(BuildContext context) async {
    showLoadingDialog('Deleting Local Database...', context);

    // delete
    String path = await getDatabasesPath();
    await deleteDatabase(join(path, 'database.db'));

    // recreate
    await initializeDB();

    showGlobalSnackBar('Local Database Deleted');

    if (!context.mounted) return;
    Navigator.of(context).pop();
  }

  static Future<void> addUser({
    required String username,
    required String password,
    required String fname,
    required String lname,
    required String phone,
    required String role,
  }) async {
    final db = await initializeDB();
    await db.insert('users', {
      'username': username,
      'password': password,
      'fname': fname,
      'lname': lname,
      'phone': phone,
      'role': role,
    });
  }

  static Future<void> addProduct({
    required String? barcode,
    required String? description,
    required String? category,
    required String? arDesc,
    required double? price,
    required double? price2,
    required int? vatPerc,
    required double? quantity,
    required String? location,
    required String? expiry,
  }) async {
    final db = await initializeDB();
    await db.insert('products', {
      'barcode': barcode,
      'description': description,
      'category': category,
      'ar_desc': arDesc,
      'price': price,
      'price2': price2,
      'vat_perc': vatPerc,
      'quantity': quantity,
      'location': location,
      'expiry': expiry,
    });
  }

  static Future<void> addTransaction({
    required int serial,
    required int transID,
    required String transType,
    required String username,
    required String machineID,
    required String customer,
    required String fromWh,
    required String toWH,
    required int lineID,
    required String productID,
    required String productName,
    required double productPrice,
    required double productQty,
    required double productTotal,
    required int taxPerc,
    required double discount,
    required String extraDesc,
    required String currency,
    required String reference,
    required String transDate,
  }) async {
    final db = await initializeDB();
    await db.insert('transactions', {
      'serial': serial,
      'trans_id': transID,
      'trans_type': transType,
      'username': username,
      'machine_id': machineID,
      'customer': customer,
      'from_wh': fromWh,
      'to_wh': toWH,
      'line_id': lineID,
      'product_id': productID,
      'product_name': productName,
      'product_price': productPrice,
      'product_qty': productQty,
      'product_total': productTotal,
      'tax_perc': taxPerc,
      'discount': discount,
      'extra_desc': extraDesc,
      'currency': currency,
      'reference': reference,
      'trans_date': transDate,
    });
  }

  static Future<void> addTransactionOption({
    required int id,
    required String description,
    required int showCustomer,
    required int showCurrency,
    required int showFromWh,
    required int showToWh,
    required int showAutoAdd,
    required int affectQty,
  }) async {
    final db = await initializeDB();
    await db.insert(
      'transactionOptions',
      {
        'id': id,
        'description': description,
        'showCustomer': showCustomer,
        'showCurrency': showCurrency,
        'showFromWh': showFromWh,
        'showToWh': showToWh,
        'showAutoAdd': showAutoAdd,
        'affectQty': affectQty,
      },
    );
  }

  static Future<void> addCustomer({
    required int id,
    required String name,
    required String address,
    required String contactNumber,
  }) async {
    final db = await initializeDB();
    await db.insert(
      'customers',
      {
        'id': id,
        'name': name,
        'address': address,
        'contactNumber': contactNumber,
      },
    );
  }

  static Future<void> addWarehouse({
    required String code,
    required String name,
  }) async {
    final db = await initializeDB();
    await db.insert(
      'warehouse',
      {
        'code': code,
        'name': name,
      },
    );
  }

  static Future<Map<String, dynamic>?> getUser(
      String username, String password) async {
    final db = await initializeDB();
    final result = await db.rawQuery('''
      SELECT * FROM users WHERE username = '$username' AND password = '$password'
    ''');
    if (result.isNotEmpty) {
      return (result.first);
    }

    return null;
  }

  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    final db = await initializeDB();
    final result = await db.rawQuery('''
      SELECT * FROM users
    ''');
    return result;
  }

  static Future<List<Map<String, dynamic>>> getAllProducts() async {
    final db = await initializeDB();
    final result = await db.rawQuery('''
      SELECT * FROM products
    ''');
    return result;
  }

  static Future<Map<String, Object?>?> getProduct(String barcode) async {
    final db = await initializeDB();
    final result = await db.rawQuery('''
      SELECT * FROM products where barcode = "$barcode"
    ''');
    if (result.isEmpty) return null;
    return result[0];
  }

  static Future<List<Map<String, dynamic>>> getAllProductCategories() async {
    final db = await initializeDB();
    final result = await db.rawQuery('''
      SELECT category FROM products GROUP BY category
    ''');
    return result;
  }

  static Future<List<Map<String, dynamic>>> getAllLowQuantityProducts() async {
    final db = await initializeDB();
    final result = await db.rawQuery('''
      SELECT * FROM products WHERE quantity < 50;
    ''');
    return result;
  }

  static Future<List<Map<String, Object?>>> getAllUserTransactions(
      String username) async {
    final db = await initializeDB();

    final result = await db.rawQuery('''
      SELECT * FROM transactions where username = "$username"
    ''');

    return result;
  }

  static Future<List<Map<String, dynamic>>> getTransactionOptions() async {
    final db = await initializeDB();
    final result = await db.rawQuery('''
      SELECT * FROM transactionOptions
    ''');
    return result;
  }

  static Future<List<Map<String, dynamic>>> getAllCustomers() async {
    final db = await initializeDB();
    final result = await db.rawQuery('''
      SELECT * FROM customers
    ''');
    return result;
  }

  static Future<List<Map<String, dynamic>>> getAllWarehouses() async {
    final db = await initializeDB();
    final result = await db.rawQuery('''
      SELECT * FROM warehouse
    ''');
    return result;
  }

  static Future<void> deleteAllUsers() async {
    final db = await initializeDB();
    await db.delete('users');
  }

  static Future<void> deleteAllProducts() async {
    final db = await initializeDB();
    await db.delete('products');
  }

  static Future<void> deleteAllTransactions() async {
    final db = await initializeDB();
    await db.delete('transactions');
  }

  static Future<void> deleteAllTransactionOptions() async {
    final db = await initializeDB();
    await db.delete('transactionOptions');
  }

  static Future<void> deleteAllCustomers() async {
    final db = await initializeDB();
    await db.delete('customers');
  }

  static Future<void> deleteAllWarehouses() async {
    final db = await initializeDB();
    await db.delete('warehouse');
  }
}
