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
        id INTEGER PRIMARY KEY,
        username varchar(255),
        password varchar(255),
        fname varchar(255),
        lname varchar(255),
        phone varchar(255),
        role varchar(255)
        );
        ''');
        await database.insert('users', {
          'id': 1,
          'username': 'admin',
          'password': 'admin',
          'fname': 'Admin',
          'lname': 'Admin',
          'phone': '0000000000',
          'role': 'admin',
        });
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
          User_ID INTEGER,
          Machine_ID varchar(255),
          FROM_WH varchar(255),
          To_WH varchar(255),
          Line_ID INTEGER,
          Product_ID varchar(255),
          Product_Name varchar(255),
          Product_Price REAL,
          Product_Qty REAL,
          Product_Total REAL,
          TAX_Perc INTEGER,
          DISC REAL,
          Extra_Desc varchar(255),
          Currency varchar(255)
          );
          ''');

        await database.insert('transactions', {
          'Serial': 1,
          'Trans_ID': 1,
          'Trans_Type': 'Sale',
          'User_ID': 1,
          'Machine_ID': '1',
          'FROM_WH': '1',
          'To_WH': '1',
          'Line_ID': 1,
          'Product_ID': '1',
          'Product_Name': '1',
          'Product_Price': 1,
          'Product_Qty': 1,
          'Product_Total': 1,
          'TAX_Perc': 1,
          'DISC': 1,
          'Extra_Desc': '1',
          'Currency': '1',
        });
      },
      version: 1,
    );
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
    required int id,
    required String username,
    required String password,
    required String fname,
    required String lname,
    required String phone,
    required String role,
  }) async {
    final db = await initializeDB();
    await db.insert('users', {
      'id': id,
      'username': username,
      'password': password,
      'fname': fname,
      'lname': lname,
      'phone': phone,
      'role': role,
    });
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

  static Future<List<Map<String, Object?>>> getUserTransactions(
      String username) async {
    final db = await initializeDB();

    //get user info
    dynamic user = await db.rawQuery('''
      SELECT * FROM users WHERE username = '$username'
    ''');
    user = user.first;

    final result = await db.rawQuery('''
      SELECT * FROM transactions where User_ID = '${user['id']}' 
    ''');

    return result;
  }
}
