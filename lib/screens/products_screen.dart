import 'package:flutter/material.dart';
import 'package:pos_app/screens/add_product_screen.dart';
import 'package:pos_app/services/sqlite_service.dart';
import 'package:pos_app/widgets/textfields.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  bool _isLoading = true;
  late List _products = [];

  final _searchController = TextEditingController();

  @override
  void initState() {
    SqliteService.getAllProducts().then((value) {
      setState(() {
        _products = value;
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
          title: const Text('Products'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const AddProductScreen(),
              ),
            ),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.only(left: 15, right: 15, top: 15, bottom: 5),
            child: PrimaryTextField(
              text: 'Search',
              controller: _searchController,
              icon: const Icon(Icons.search_rounded),
              onChanged: _searchProduct,
            ),
          ),
          const SizedBox(height: 15),
          Expanded(
            child: ListView.separated(
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_products[index]['description']),
                  subtitle: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Barcode: ${_products[index]['barcode']}'),
                          Text(
                              'Price: \$${displayDouble(_products[index]['price'])}'),
                        ],
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              'Quantity: ${displayDouble(_products[index]['quantity'])}'),
                        ],
                      )
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
              itemCount: _products.length,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _searchProduct(String query) async {
    final products = await SqliteService.getAllProducts();

    setState(() {
      _products = products
          .where((product) =>
              product['description']
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              product['ar_desc']
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              product['barcode']
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase()))
          .toList();
    });
  }

  // function to display string of double and only with 2 decimal places if they are not 0
  String displayDouble(double value) {
    if (value == value.round()) {
      return value.toStringAsFixed(0);
    } else if (value == value.roundToDouble()) {
      return value.toStringAsFixed(1);
    } else {
      return value.toStringAsFixed(2);
    }
  }
}
