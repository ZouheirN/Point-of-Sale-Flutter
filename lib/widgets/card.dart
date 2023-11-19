import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

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
    if (widget.lowQuantityProducts == null ||
        widget.lowQuantityProducts!.isEmpty) {
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
            _buildLowQuantityProducts(),
          ],
        ),
      ),
    );
  }

  Future<void> _retrySync(String barcode) async {}

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
