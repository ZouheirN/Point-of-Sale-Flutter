import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:pos_app/services/mysql_service.dart';
import 'package:pos_app/services/unsynced_products_crud.dart';
import 'package:pos_app/widgets/dialogs.dart';
import 'package:pos_app/widgets/global_snackbar.dart';

class PrimaryCard extends StatelessWidget {
  final String title;
  final String text;

  const PrimaryCard({super.key, required this.title, required this.text});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 5,
      color: Colors.white,
      surfaceTintColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            ListTile(
              title: Text(
                text,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AlertCard extends StatefulWidget {
  final List<Map<String, dynamic>>? lowQuantityProducts;

  const AlertCard({super.key, this.lowQuantityProducts});

  @override
  State<AlertCard> createState() => _AlertCardState();
}

class _AlertCardState extends State<AlertCard> {
  @override
  Widget build(BuildContext context) {
    final List unSyncedProducts = UnSyncedProducts.getUnSyncedProducts();

    if ((widget.lowQuantityProducts == null ||
            widget.lowQuantityProducts!.isEmpty) &&
        (unSyncedProducts == [] || unSyncedProducts.isEmpty)) {
      return const SizedBox.shrink();
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 5,
      color: Colors.white,
      surfaceTintColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.warning_rounded,
                  color: Colors.red,
                  size: 30,
                ),
                Gap(10),
                Text(
                  'Alerts',
                  style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.red),
                ),
              ],
            ),
            _buildUnSyncedProducts(),
            _buildLowQuantityProducts(),
          ],
        ),
      ),
    );
  }

  Widget _buildUnSyncedProducts() {
    final unSyncedProducts = UnSyncedProducts.getUnSyncedProducts();

    if (unSyncedProducts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        const Text(
          'Un-Synced Products',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        for (final product in unSyncedProducts)
          ListTile(
            title: Text(
              product['description'],
              style: const TextStyle(fontSize: 18),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Barcode: ${product['barcode']}',
                  style: const TextStyle(fontSize: 18),
                ),
                Text(
                  'Quantity: ${product['quantity']}',
                  style: const TextStyle(fontSize: 18),
                ),
                Text(
                  'Price: ${product['price']}',
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
            trailing: Column(
              children: [
                Expanded(
                  child: InkWell(
                    child: const Icon(Icons.delete_rounded),
                    onTap: () {
                      setState(() {
                        UnSyncedProducts.deleteUnSyncedProduct(
                            product['barcode']);
                      });
                    },
                  ),
                ),
                const Gap(20),
                Expanded(
                  child: InkWell(
                      onTap: () => _retrySync(product['barcode']),
                      child: const Icon(Icons.sync_rounded)),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Future<void> _retrySync(String barcode) async {
    showLoadingDialog('Syncing Product', context);

    final product = UnSyncedProducts.getUnSyncedProducts().firstWhere(
      (element) => element['barcode'] == barcode,
    );

    final result = await MySQLService.addProduct(
      barcode: barcode,
      name: product['description'],
      category: product['category'],
      arabicName: product['ar_desc'],
      price: product['price'],
      price2: product['price2'],
      vatPerc: product['vat_perc'],
      quantity: product['quantity'],
      location: product['location'],
      expiryDate: product['expiry'],
    );

    if (result == ReturnTypes.duplicate) {
      showGlobalSnackBar(
          'Product already exists in MySQL database. Removing from un-synced products');
      UnSyncedProducts.deleteUnSyncedProduct(barcode);
      if (!mounted) return;
      Navigator.of(context).pop();
      return;
    }

    if (result == ReturnTypes.failed) {
      showGlobalSnackBar('Failed to sync product. Please try again later');
      if (!mounted) return;
      Navigator.of(context).pop();
      return;
    }

    showGlobalSnackBar('Product synced successfully');
    if (!mounted) return;
    Navigator.of(context).pop();
    setState(() {});
  }

  Widget _buildLowQuantityProducts() {
    if (widget.lowQuantityProducts == null ||
        widget.lowQuantityProducts!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        const Text(
          'Low Quantity Products',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        for (final product in widget.lowQuantityProducts!)
          ListTile(
            title: Text(
              product['description'],
              style: const TextStyle(fontSize: 18),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Barcode: ${product['barcode']}',
                  style: const TextStyle(fontSize: 18),
                ),
                Text(
                  'Quantity: ${product['quantity']}',
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
