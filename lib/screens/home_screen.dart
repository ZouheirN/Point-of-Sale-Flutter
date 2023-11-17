import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:pos_app/screens/employees_screen.dart';
import 'package:pos_app/screens/login_screen.dart';
import 'package:pos_app/screens/new_transaction_screen.dart';
import 'package:pos_app/screens/products_screen.dart';
import 'package:pos_app/screens/settings_screen.dart';
import 'package:pos_app/screens/transaction_history_screen.dart';
import 'package:pos_app/services/mysql_service.dart';
import 'package:pos_app/services/sqlite_service.dart';
import 'package:pos_app/widgets/card.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../services/userinfo_crud.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _salesMade = 0;
  int _salesTarget = 0;

  final _refreshController = RefreshController(initialRefresh: false);

  List<Map<String, dynamic>> _lowQuantityProducts = [];
  late Future _dataFuture;

  void _logout() {
    UserInfo.clearUserInfo();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }

  void _onRefresh() async {
    // get data
    await _getData();

    _refreshController.refreshCompleted();
  }

  Future<void> _getData() async {
    // sync data from mysql
    await MySQLService.syncFromMySQL(context, false);

    // todo get sales made

    // todo get sales target

    // get low quantity products
    await SqliteService.getAllLowQuantityProducts().then((value) {
      setState(() {
        _lowQuantityProducts = value;
      });
    });
  }

  @override
  void initState() {
    _dataFuture = _getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _dataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Loading state
          return Scaffold(
            appBar: AppBar(
              title: const Text('Dashboard'),
              centerTitle: true,
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          // Error state
          return Scaffold(
            appBar: AppBar(
              title: const Text('Dashboard'),
              centerTitle: true,
            ),
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        } else {
          // Data loaded successfully
          return Scaffold(
            appBar: AppBar(
              title: const Text('Dashboard'),
              centerTitle: true,
              actions: [
                PopupMenuButton(
                  onSelected: (bool result) {
                    UserInfo.setIsAutoLoadingEnabled(result);
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: true,
                      child: CheckboxListTile(
                        title: const Text("Auto Refresh"),
                        value: UserInfo.getIsAutoLoadingEnabled(),
                        onChanged: (value) {
                          Navigator.pop(context, value);
                        },
                      ),
                    ),
                  ],
                )
              ],
            ),
            drawer: _buildDrawer(),
            body: Padding(
              padding: const EdgeInsets.all(15.0),
              child: SmartRefresher(
                enablePullDown: true,
                onRefresh: _onRefresh,
                controller: _refreshController,
                header: const ClassicHeader(),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _buildAlertCard(),
                      PrimaryCard(
                        title: 'Sales Target',
                        text: 'Sales Made: $_salesMade out of $_salesTarget',
                      ),
                      // Add more widgets based on your data
                    ],
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF166DFF),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  UserInfo.getUsername(),
                  style: const TextStyle(fontSize: 40),
                ),
                const Gap(10),
                // Text(UserInfo.getRole()),
                Text('Role: ${UserInfo.getRole()}',
                    style: const TextStyle(fontSize: 20)),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.attach_money_rounded),
            title: const Text('New Transaction'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (context) => const NewTransactionScreen()),
            ),
          ),
          ListTile(
              leading: const Icon(Icons.history_rounded),
              title: const Text('Transaction History'),
              onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => const TransactionHistoryScreen()),
                  )),
          if (UserInfo.getRole() == 'Admin')
            ListTile(
              leading: const Icon(Icons.groups_rounded),
              title: const Text('Employees'),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => const EmployeesScreen()),
              ),
            ),
          ListTile(
            leading: const Icon(Icons.inventory_2_rounded),
            title: const Text('Products'),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const ProductsScreen())),
          ),
          const Divider(indent: 15, endIndent: 15),
          ListTile(
            leading: const Icon(Icons.settings_rounded),
            title: const Text('Settings'),
            onTap: _openSettings,
          ),
          ListTile(
            leading: const Icon(Icons.logout_rounded),
            title: const Text('Logout'),
            onTap: _logout,
          )
        ],
      ),
    );
  }

  Widget _buildAlertCard() {
    return AlertCard(
      lowQuantityProducts: _lowQuantityProducts,
    );
  }
}
