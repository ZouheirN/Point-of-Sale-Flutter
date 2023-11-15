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
        await database.execute(
          '''
          CREATE TABLE IF NOT EXISTS products (
          barcode varchar(255),
          description varchar(255),
          ar_desc varchar(255),
          price REAL,
          price2 REAL,
          Vat_Perc INTEGER,
          quantity REAL,
          location varchar(255),
          expiry INTEGER
          );
          ''',
        );
        // create transactions table
        await database.execute('''
          CREATE TABLE IF NOT EXISTS transactions (
          Serial INTEGER PRIMARY KEY,
          Trans_ID INTEGER,
          Trans_Type varchar(255),
          Username varchar(255),
          Machine_ID varchar(255),
          FROM_WH varchar(255),
          TO_WH varchar(255),
          Line_ID INTEGER,
          Product_ID varchar(255),
          Product_Name varchar(255),
          Product_Price REAL,
          Product_Qty REAL,
          Product_Total REAL,
          TAX_Perc INTEGER,
          DISC REAL,
          Extra_Desc varchar(255),
          Currency varchar(255),
          Synced BOOLEAN
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
    required String? ar_desc,
    required double? price,
    required double? price2,
    required int? Vat_Perc,
    required double? quantity,
    required String? location,
    required int? expiry,
  }) async {
    final db = await initializeDB();
    await db.insert('products', {
      'barcode': barcode,
      'description': description,
      'ar_desc': ar_desc,
      'price': price,
      'price2': price2,
      'Vat_Perc': Vat_Perc,
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
  }) async {
    final db = await initializeDB();
    await db.insert('transactions', {
      'Serial': serial,
      'Trans_ID': transID,
      'Trans_Type' : transType,
      'Username' : username,
      'Machine_ID': machineID,
      'FROM_WH': fromWh,
      'TO_WH': toWH,
      'Line_ID': lineID,
      'Product_ID': productID,
      'Product_Name': productName,
      'Product_Price': productPrice,
      'Product_Qty': productQty,
      'Product_Total': productTotal,
      'TAX_Perc': taxPerc,
      'DISC': discount,
      'Extra_Desc': extraDesc,
      'Currency': currency,
      'Synced': true,
    });
  }

  static Future<Map<String, dynamic>?> getUser(String username,
      String password) async {
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

  static Future<List<Map<String, Object?>>> getUserTransactions(
      String username) async {
    final db = await initializeDB();

    final result = await db.rawQuery('''
      SELECT * FROM transactions where Username = '$username' 
    ''');

    return result;
  }
}
