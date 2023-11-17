import 'package:chips_choice/chips_choice.dart';
import 'package:flutter/material.dart';
import 'package:pos_app/screens/add_product_screen.dart';
import 'package:pos_app/services/mysql_service.dart';
import 'package:pos_app/services/sqlite_service.dart';
import 'package:pos_app/services/userinfo_crud.dart';
import 'package:pos_app/widgets/global_snackbar.dart';
import 'package:pos_app/widgets/textfields.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  // bool _isLoading = true;
  late List _products = [];
  final _searchController = TextEditingController();

  final _refreshController = RefreshController(initialRefresh: false);

  List<String> _selectedCategories = [];
  List<String> _categories = [];

  void _onRefresh() async {
    // get all products from mysql
    final result = await MySQLService.syncProductsFromMySQL();

    if (result != ReturnTypes.success) {
      showGlobalSnackBar('Failed to sync from MySQL');
      _refreshController.refreshFailed();
      return;
    }

    await SqliteService.getAllProducts().then((value) {
      setState(() {
        _products = value;
        // _isLoading = false;
      });
    });

    //get all categories from sqlite
    await SqliteService.getAllProductCategories().then((value) {
      setState(() {
        _categories = value.map((e) => e['category'].toString()).toList();
      });
    });

    _refreshController.refreshCompleted();
  }

  @override
  void initState() {
    SqliteService.getAllProducts().then((value) {
      setState(() {
        _products = value;
        // _isLoading = false;
      });
    });

    SqliteService.getAllProductCategories().then((value) {
      setState(() {
        _categories = value.map((e) => e['category'].toString()).toList();
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_categories.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Products'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final filterProducts = _products
        .where((product) =>
            _selectedCategories.isEmpty ||
            _selectedCategories.contains(product['category']))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          if (UserInfo.getRole() == "Admin")
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
              hintText: 'Search',
              controller: _searchController,
              icon: const Icon(Icons.search_rounded),
              onChanged: _searchProduct,
            ),
          ),
          ChipsChoice<String>.multiple(
            value: _selectedCategories,
            onChanged: (val) {
              setState(() => _selectedCategories = val);
            },
            choiceItems: C2Choice.listFrom<String, String>(
              source: _categories,
              value: (i, v) => v,
              label: (i, v) => v,
            ),
          ),
          Expanded(
            child: SmartRefresher(
              controller: _refreshController,
              enablePullDown: true,
              header: const ClassicHeader(),
              onRefresh: _onRefresh,
              child: ListView.separated(
                itemBuilder: (context, index) {
                  final product = filterProducts[index];
                  return ListTile(
                    title: Text(product['description']),
                    subtitle: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Barcode: ${product['barcode']}',
                              ),
                              Text(
                                'Price: \$${displayDouble(product['price'])}',
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Quantity: ${displayDouble(product['quantity'])}',
                              ),
                              Text(
                                'Category: ${product['category']}',
                                textAlign: TextAlign.end,
                              ),
                            ],
                          ),
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
                itemCount: filterProducts.length,
              ),
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
