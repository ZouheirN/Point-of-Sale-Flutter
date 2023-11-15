import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:pos_app/services/mysql_service.dart';
import 'package:pos_app/services/sqlite_service.dart';

class EmployeesScreen extends StatefulWidget {
  const EmployeesScreen({super.key});

  @override
  State<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
  bool _isLoading = true;
  late List _users = [];

  void _addUser() {
    MySQLService.showAddUserDialog(context);
  }

  void _viewUserInfo(String username) {
    bool isLoading = true;
    dynamic transactions;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          SqliteService.getUserTransactions(username).then(
            (value) => setState(
              () {
                transactions = value;
                isLoading = false;
              },
            ),
          );

          if (isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(15),
            children: [
              Text(
                'Transactions made by $username',
                style: const TextStyle(fontSize: 20),
              ),
              if (transactions.isEmpty)
                const Column(
                  children: [
                    Gap(10),
                    Text('No transactions made'),
                  ],
                )
              else for (var transaction in transactions)
                ListTile(
                  title: Text(
                    'Invoice #${transaction['Trans_ID']}',
                    style: const TextStyle(fontSize: 20),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Transaction Type: ${transaction['Trans_Type']}'),
                      Text('Total Price: ${transaction['Product_Total']}'),
                    ],
                  ),
                ),
            ],
          );
        });
      },
    );
  }

  @override
  void initState() {
    SqliteService.getAllUsers().then((value) {
      setState(() {
        _users = value;
        _isLoading = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Employees'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Employees'),
        actions: [IconButton(onPressed: _addUser, icon: const Icon(Icons.add))],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(15),
        itemBuilder: (context, index) {
          return ListTile(
            leading: _users[index]['role'] == 'admin'
                ? const Icon(Icons.admin_panel_settings_rounded)
                : const Icon(Icons.person_rounded),
            title: Text('${_users[index]['fname']} ${_users[index]['lname']}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Username: ${_users[index]['username']}"),
                Text("Role: ${_users[index]['role']}"),
              ],
            ),
            onTap: () => _viewUserInfo(_users[index]['username']),
          );
        },
        itemCount: _users.length,
      ),
    );
  }
}
