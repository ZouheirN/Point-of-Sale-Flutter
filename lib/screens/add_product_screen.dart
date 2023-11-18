import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:pos_app/widgets/textfields.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _barcodeController = TextEditingController();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _arabicNameController = TextEditingController();
  final _priceController = TextEditingController();
  final _price2Controller = TextEditingController();
  final _vatPercController = TextEditingController();
  final _quantityController = TextEditingController();
  final _locationController = TextEditingController();
  final _expiryController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  // check box variables
  bool _isBarcodeChecked = false;
  bool _isNameChecked = false;
  bool _isCategoryChecked = false;
  bool _isArabicNameChecked = false;
  bool _isPriceChecked = false;
  bool _isPrice2Checked = false;
  bool _isVatPercChecked = false;
  bool _isQuantityChecked = false;
  bool _isLocationChecked = false;
  bool _isExpiryChecked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(15),
          children: [
            Row(
              children: [
                Expanded(
                  child: SecondaryTextField(
                    formKey: _formKey,
                    controller: _barcodeController,
                    labelText: 'Barcode',
                    icon: Checkbox(
                      value: _isBarcodeChecked,
                      onChanged: (value) {
                        setState(() {
                          _isBarcodeChecked = value!;
                        });
                      },
                    ),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                            onPressed: _onBarcodeButtonPressed,
                            icon: const Icon(Icons.camera_alt_rounded)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const Gap(15),
            SecondaryTextField(
              formKey: _formKey,
              controller: _nameController,
              labelText: 'Name',
              icon: Checkbox(
                value: _isNameChecked,
                onChanged: (value) {
                  setState(() {
                    _isNameChecked = value!;
                  });
                },
              )
            ),
            const Gap(15),
            SecondaryTextField(
              formKey: _formKey,
              controller: _categoryController,
              labelText: 'Category',
              icon: Checkbox(
                value: _isCategoryChecked,
                onChanged: (value) {
                  setState(() {
                    _isCategoryChecked = value!;
                  });
                },
              )
            ),
            const Gap(15),
            SecondaryTextField(
              formKey: _formKey,
              controller: _arabicNameController,
              labelText: 'Arabic Name',
              icon: Checkbox(
                value: _isArabicNameChecked,
                onChanged: (value) {
                  setState(() {
                    _isArabicNameChecked = value!;
                  });
                },
              )
            ),
            const Gap(15),
            SecondaryTextField(
              formKey: _formKey,
              controller: _priceController,
              labelText: 'Price',
              icon: Checkbox(
                value: _isPriceChecked,
                onChanged: (value) {
                  setState(() {
                    _isPriceChecked = value!;
                  });
                },
              )
            ),
            const Gap(15),
            SecondaryTextField(
              formKey: _formKey,
              controller: _price2Controller,
              labelText: 'Price 2',
              icon: Checkbox(
                value: _isPrice2Checked,
                onChanged: (value) {
                  setState(() {
                    _isPrice2Checked = value!;
                  });
                },
              )
            ),
            const Gap(15),
            SecondaryTextField(
              formKey: _formKey,
              controller: _vatPercController,
              labelText: 'VAT Percentage',
              icon: Checkbox(
                value: _isVatPercChecked,
                onChanged: (value) {
                  setState(() {
                    _isVatPercChecked = value!;
                  });
                },
              )
            ),
            const Gap(15),
            SecondaryTextField(
              formKey: _formKey,
              controller: _quantityController,
              labelText: 'Quantity',
              icon: Checkbox(
                value: _isQuantityChecked,
                onChanged: (value) {
                  setState(() {
                    _isQuantityChecked = value!;
                  });
                },
              )
            ),
            const Gap(15),
            SecondaryTextField(
              formKey: _formKey,
              controller: _locationController,
              labelText: 'Location',
              icon: Checkbox(
                value: _isLocationChecked,
                onChanged: (value) {
                  setState(() {
                    _isLocationChecked = value!;
                  });
                },
              )
            ),
            const Gap(15),
            SecondaryTextField(
              formKey: _formKey,
              controller: _expiryController,
              labelText: 'Expiry Date',
              icon: Checkbox(
                value: _isExpiryChecked,
                onChanged: (value) {
                  setState(() {
                    _isExpiryChecked = value!;
                  });
                },
              )
            ),
            const Gap(15),
            ElevatedButton(
              onPressed: () {
                // todo save to sqlite
                // todo save to mysql
                // todo sync from mysql
                // todo show snackbar
                // todo pop screen
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
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
                facing: CameraFacing.back,
                torchEnabled: false,
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
}
