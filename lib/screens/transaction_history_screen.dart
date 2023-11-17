import 'package:flutter/material.dart';
import 'package:pos_app/screens/transaction_type_screen.dart';
import 'package:pos_app/services/mysql_service.dart';
import 'package:pos_app/services/sqlite_service.dart';
import 'package:pos_app/services/userinfo_crud.dart';
import 'package:pos_app/widgets/global_snackbar.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  bool _isLoading = true;
  late List _transactions = [];

  final _refreshController = RefreshController(initialRefresh: false);

  void _onRefresh() async {
    // get all products from mysql
    final result = await MySQLService.syncTransactionsFromMySQL();

    if (result != ReturnTypes.success) {
      showGlobalSnackBar('Failed to sync from MySQL');
      _refreshController.refreshFailed();
      return;
    }

    await SqliteService.getAllUserTransactions(UserInfo.getUsername())
        .then((value) {
      setState(() {
        _transactions = value;
        _isLoading = false;
      });
    });

    _refreshController.refreshCompleted();
  }

  @override
  void initState() {
    SqliteService.getAllUserTransactions(UserInfo.getUsername()).then((value) {
      setState(() {
        _transactions = value;
        _isLoading = false;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Products'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const TransactionTypeScreen(),
              ),
            ),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: SmartRefresher(
        controller: _refreshController,
        enablePullDown: true,
        header: const ClassicHeader(),
        onRefresh: _onRefresh,
        child: ListView.separated(
          padding: const EdgeInsets.all(15),
          itemBuilder: (context, index) {
            final transaction = _transactions[index];
            return ListTile(
              title: Text(
                  'Transaction ID: ${transaction['trans_id']} (${transaction['reference']})'),
              subtitle: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('Type: ${transaction['trans_type']}'),
                        Text('Customer: ${transaction['customer']}'),
                        Text('From WH: ${transaction['from_wh']}'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('To WH: ${transaction['to_wh']}'),
                        Text('Total Items: '),
                        Text('Total Price: '),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
          separatorBuilder: (context, index) => const Divider(
            height: 10,
            thickness: 1,
            indent: 15,
            endIndent: 15,
          ),
          itemCount: _transactions.length,
        ),
      ),
    );
  }
}
