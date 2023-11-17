import 'package:flutter/material.dart';
import 'package:pos_app/services/sqlite_service.dart';

void showLoadingDialog(String text, BuildContext context) => showDialog(
      context: context,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          title: Text(text, textAlign: TextAlign.center),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );

void showSelectCustomerDialog(
    BuildContext context, TextEditingController controller) async {
  List customers = [];
  bool isLoading = true;

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        // get all customers
        SqliteService.getAllCustomers().then(
          (value) => setState(
            () {
              customers = value;
              isLoading = false;
            },
          ),
        );

        if (isLoading) {
          return const AlertDialog(
              title: Text('Loading'), content: CircularProgressIndicator());
        }

        if (customers.isEmpty) {
          return const AlertDialog(title: Text('No customers found'));
        }

        return AlertDialog(
          title: const Text('Select Customer'),
          content: SizedBox(
            width: double.maxFinite,
            height: MediaQuery.of(context).size.height * customers.length / 10,
            child: ListView.builder(
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(customers[index]['name']),
                  subtitle: Text('ID: ${customers[index]['id']}'),
                  onTap: () {
                    controller.text = customers[index]['name'];
                    Navigator.of(context).pop();
                  },
                );
              },
              itemCount: customers.length,
            ),
          ),
        );
      },
    ),
  );
}

void showSelectWarehouseDialog(
    BuildContext context, TextEditingController controller) async {
  List warehouses = [];
  bool isLoading = true;

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        // get all customers
        SqliteService.getAllWarehouses().then(
          (value) => setState(
            () {
              warehouses = value;
              isLoading = false;
            },
          ),
        );

        if (isLoading) {
          return const AlertDialog(
              title: Text('Loading'), content: CircularProgressIndicator());
        }

        if (warehouses.isEmpty) {
          return const AlertDialog(title: Text('No warehouses found'));
        }

        return AlertDialog(
          title: const Text('Select Warehouse'),
          content: SizedBox(
            width: double.maxFinite,
            height: MediaQuery.of(context).size.height * warehouses.length / 10,
            child: ListView.builder(
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(warehouses[index]['name']),
                  subtitle: Text('ID: ${warehouses[index]['code']}'),
                  onTap: () {
                    controller.text = warehouses[index]['name'];
                    Navigator.of(context).pop();
                  },
                );
              },
              itemCount: warehouses.length,
            ),
          ),
        );
      },
    ),
  );
}