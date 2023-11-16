import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:pos_app/services/sqlite_service.dart';
import 'package:pos_app/widgets/buttons.dart';
import 'package:pos_app/widgets/dialogs.dart';
import 'package:pos_app/widgets/textfields.dart';

class NewTransactionScreen extends StatefulWidget {
  const NewTransactionScreen({super.key});

  @override
  State<NewTransactionScreen> createState() => _NewTransactionScreenState();
}

class _NewTransactionScreenState extends State<NewTransactionScreen> {
  late final List<Map<String, dynamic>> _options = [];
  bool _isLoading = true;

  final _customerController = TextEditingController();
  String _currency = 'USD (\$)';
  final _fromWHController = TextEditingController();
  final _toWHController = TextEditingController();
  bool _autoAdd = true;

  final _formKey = GlobalKey<FormState>();
  String _transactionType = '';

  void _goToTransaction() {
    if (_formKey.currentState!.validate()) {}
  }

  Widget? _buildOptions() {
    if (_transactionType.isEmpty) return null;

    _customerController.clear();
    _fromWHController.clear();
    _toWHController.clear();
    _currency = 'USD (\$)';
    _autoAdd = true;

    Map<String, dynamic> transactionOptionDetails = (_options
        .where((element) => element['description'] == _transactionType)
        .toList())[0];

    List<Widget> columns = [];

    if (transactionOptionDetails['showCustomer'] == 1) {
      columns.add(const Gap(10));
      columns.add(
        SecondaryTextField(
          controller: _customerController,
          labelText: 'Customer',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a customer';
            }
            return null;
          },
          suffixIcon: IconButton(
            onPressed: () {
              showSelectCustomerDialog(context, _customerController);
            },
            icon: const Icon(Icons.search),
          ),
        ),
      );
    }
    if (transactionOptionDetails['showCurrency'] == 1) {
      columns.add(const Gap(10));
      columns.add(
        CustomDropdown<String>(
          initialItem: _currency,
          items: const ['USD (\$)', 'LBP (LL)'],
          onChanged: (value) {
            setState(() {
              _currency = value;
            });
          },
        ),
      );
    }

    if (transactionOptionDetails['showFromWh'] == 1) {
      columns.add(const Gap(10));
      columns.add(
        SecondaryTextField(
          controller: _fromWHController,
          labelText: 'From Warehouse',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a warehouse';
            }
            return null;
          },
          suffixIcon: IconButton(
            onPressed: () {
              showSelectWarehouseDialog(context, _fromWHController);
            },
            icon: const Icon(Icons.search),
          )
        ),
      );
    }

    if (transactionOptionDetails['showToWh'] == 1) {
      columns.add(const Gap(10));
      columns.add(
        SecondaryTextField(
          controller: _toWHController,
          labelText: 'To Warehouse',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a warehouse';
            }
            return null;
          },
          suffixIcon: IconButton(
            onPressed: () {
              showSelectWarehouseDialog(context, _toWHController);
            },
            icon: const Icon(Icons.search),
          )
        ),
      );
    }

    if (transactionOptionDetails['showAutoAdd'] == 1) {
      columns.add(const Gap(10));
      columns.add(
        CheckboxListTile(
          title: const Text('Auto Add'),
          value: _autoAdd,
          onChanged: (value) {
            setState(() {
              _autoAdd = value!;
            });
          },
        ),
      );
    }

    return Column(
      children: columns,
    );
  }

  @override
  void initState() {
    SqliteService.getTransactionOptions().then((value) {
      for (var i = 0; i < value.length; i++) {
        _options.add(value[i]);
      }

      setState(() {
        _isLoading = false;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _customerController.dispose();
    _fromWHController.dispose();
    _toWHController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('New Transaction'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else if (_options.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('New Transaction'),
        ),
        body: const Center(
          child: Text('No transaction types found'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Transaction'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(15),
          children: [
            const Text(
              'Transaction Type',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20),
            ),
            CustomDropdown<String>.search(
              hintText: 'Select a transaction type',
              items: _options.map((e) => e['description'] as String).toList(),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a transaction type';
                }
                return null;
              },
              onChanged: (value) {
                setState(() {
                  _transactionType = value;
                });
              },
            ),
            if (_buildOptions() != null) _buildOptions()!,
            const Gap(20),
            PrimaryButton(
                onPressed: _goToTransaction, child: const Text('Continue'))
          ],
        ),
      ),
    );
  }
}
