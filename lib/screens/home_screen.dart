import 'package:flutter/material.dart';
import 'package:pos_app/widgets/card.dart';

import '../services/userinfo_crud.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _salesMade = 0;
  int _salesTarget = 0;

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF1A71DB),
            ),
            child: Text(UserInfo.getUsername()),
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
        ));
  }
}
