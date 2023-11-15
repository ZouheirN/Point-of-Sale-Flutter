import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:pos_app/screens/login_screen.dart';
import 'package:pos_app/screens/products_screen.dart';
import 'package:pos_app/screens/settings_screen.dart';
import 'package:pos_app/widgets/card.dart';
import 'package:pos_app/screens/employees_screen.dart';
import '../services/userinfo_crud.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _salesMade = 0;
  int _salesTarget = 0;

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

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF1A71DB),
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
            title: const Text('Create Invoice'),
            onTap: () {},
          ),
          // ListTile(
          //   leading: const Icon(Icons.history_rounded),
          //   title: const Text('Transaction History'),
          //   onTap: () {},
          // ),
          if (UserInfo.getRole() == 'Admin')
          ListTile(
            leading: const Icon(Icons.groups_rounded),
            title: const Text('View Employees'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const EmployeesScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.inventory_2_rounded),
            title: const Text('View Products'),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const ProductsScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.settings_rounded),
            title: const Text('Settings'),
            onTap: _openSettings,
          ),
          const Divider(indent: 15, endIndent: 15),
          ListTile(
            leading: const Icon(Icons.logout_rounded),
            title: const Text('Logout'),
            onTap: _logout,
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
      ),
      drawer: _buildDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              PrimaryCard(
                title: 'Sales Target',
                text: 'Sales Made: $_salesMade out of $_salesTarget',
              )
            ],
          ),
        ),
      ),
    );
  }
}
