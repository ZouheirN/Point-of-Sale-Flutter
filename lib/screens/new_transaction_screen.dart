import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:pos_app/services/sqlite_service.dart';
import 'package:pos_app/widgets/global_snackbar.dart';
import 'package:pos_app/widgets/textfields.dart';

class NewTransactionScreen extends StatefulWidget {
  final String customer;
  final String currency;
  final String fromWH;
  final String toWH;

  const NewTransactionScreen({
    super.key,
    required this.customer,
    required this.currency,
    required this.fromWH,
    required this.toWH,
  });

  @override
  State<NewTransactionScreen> createState() => _NewTransactionScreenState();
}

class _NewTransactionScreenState extends State<NewTransactionScreen> {
  final _barcodeController = TextEditingController();
  final _productNameController = TextEditingController();
  final _productPriceController = TextEditingController();
  final _productLocationController = TextEditingController();
  final _productQuantityController = TextEditingController();
  final _selectedQuantityController = TextEditingController();

  List _listOfProducts = [];

  @override
  void initState() {
    // print all values
    print(widget.customer);
    print(widget.currency);
    print(widget.fromWH);
    print(widget.toWH);
    super.initState();
  }

  @override
  void dispose() {
    _barcodeController.dispose();
    _productQuantityController.dispose();
    _selectedQuantityController.dispose();
    _productNameController.dispose();
    _productPriceController.dispose();
    _productLocationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Transaction'),
        actions: [
          IconButton(
              onPressed: _onSaveButtonPressed,
              icon: const Icon(Icons.save_rounded))
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          SecondaryTextField(
            labelText: 'Barcode',
            controller: _barcodeController,
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                    onPressed: _onBarcodeButtonPressed,
                    icon: const Icon(Icons.camera_alt_rounded)),
                IconButton(
                    onPressed: _onCheckButtonPressed,
                    icon: const Icon(Icons.check_rounded)),
              ],
            ),
          ),
          const Gap(20),
          SecondaryTextField(
            enabled: false,
            labelText: 'Name',
            controller: _productNameController,
          ),
          const Gap(20),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: SecondaryTextField(
                  enabled: false,
                  labelText: 'Price',
                  controller: _productPriceController,
                ),
              ),
              const Gap(20),
              Expanded(
                flex: 3,
                child: SecondaryTextField(
                  enabled: false,
                  labelText: 'Location',
                  controller: _productLocationController,
                ),
              ),
            ],
          ),
          const Gap(20),
          Row(
            children: [
              Expanded(
                child: SecondaryTextField(
                  enabled: false,
                  labelText: 'Av. Quantity',
                  controller: _productQuantityController,
                ),
              ),
              const Gap(20),
              Expanded(
                child: SecondaryTextField(
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  labelText: 'Quantity',
                  controller: _selectedQuantityController,
                ),
              ),
              const Gap(20),
              IconButton(
                  onPressed: _onAddButtonPressed, icon: const Icon(Icons.add))
            ],
          ),
          const Gap(20),
          _buildListOfProducts()
        ],
      ),
    );
  }

  Widget _buildListOfProducts() {
    return Container(
      alignment: Alignment.center,
      child: ListView(
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        children: [
          const Row(
            // mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(child: Text('Barcode')),
              Expanded(child: Text('Name')),
              Expanded(child: Text('Quantity')),
              Expanded(child: Text('Price')),
            ],
          ),
          const Gap(10),
          for (var product in _listOfProducts)
            Row(
              // mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(child: Text(product['barcode'])),
                Expanded(child: Text(product['name'])),
                Expanded(child: Text(product['quantity'].toString())),
                Expanded(child: Text(product['price'].toString())),
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _onCheckButtonPressed() async {
    _productNameController.clear();
    _productPriceController.clear();
    _productQuantityController.clear();
    _productLocationController.clear();

    // get product from sqlite
    dynamic product =
        await SqliteService.getProduct(_barcodeController.text.trim());

    if (product == null) {
      if (!mounted) return;
      showGlobalSnackBar('Product not found');
      return;
    }

    setState(() {
      _productNameController.text = product['description'];
      _productPriceController.text = product['price2'].toString();
      _productQuantityController.text = product['quantity'].toString();
      _productLocationController.text = product['location'];
    });
  }

  Future<void> _onAddButtonPressed() async {
    await _onCheckButtonPressed();

    // check if barcode, name, price, av.quantity, and quantity are empty
    if (_barcodeController.text == '') {
      showGlobalSnackBar('Barcode is empty');
      return;
    }

    if (_productNameController.text == '') {
      showGlobalSnackBar('Name is empty');
      return;
    }

    if (_productPriceController.text == '') {
      showGlobalSnackBar('Price is empty');
      return;
    }

    if (_productQuantityController.text == '') {
      showGlobalSnackBar('Av. Quantity is empty');
      return;
    }

    if (_selectedQuantityController.text == '') {
      showGlobalSnackBar('Quantity is empty');
      return;
    }

    // add the product to the list
    _listOfProducts.add({
      "barcode": _barcodeController.text.trim(),
      "name": _productNameController.text.trim(),
      "quantity": double.parse(_selectedQuantityController.text.trim()),
      "price": double.parse(_selectedQuantityController.text.trim()) *
          double.parse(_productPriceController.text)
    });

    // clear the fields
    _productNameController.clear();
    _productPriceController.clear();
    _productQuantityController.clear();
    _productLocationController.clear();
  }

  void _onBarcodeButtonPressed() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Scan Barcode"),
          content: SizedBox(
            height: 300,
            width: double.maxFinite,
            child: MobileScanner(
              // fit: BoxFit.contain,
              controller: MobileScannerController(
                detectionSpeed: DetectionSpeed.normal,
                facing: CameraFacing.front,
                torchEnabled: true,
              ),
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  debugPrint('Barcode found! ${barcode.rawValue}');
                  setState(() {
                    _barcodeController.text = barcode.rawValue!;
                  });
                  Navigator.of(context).pop();
                }
              },
            ),
          ),
        );
      },
    );
  }

  void _onSaveButtonPressed() {}
}
