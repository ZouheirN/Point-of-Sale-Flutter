import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:pos_app/services/mysql_service.dart';
import 'package:pos_app/services/unsynced_products_crud.dart';
import 'package:pos_app/widgets/buttons.dart';
import 'package:pos_app/widgets/dialogs.dart';
import 'package:pos_app/widgets/global_snackbar.dart';
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
  bool _isBarcodeChecked = true;
  bool _isNameChecked = true;
  bool _isCategoryChecked = true;
  bool _isArabicNameChecked = false;
  bool _isPriceChecked = true;
  bool _isPrice2Checked = true;
  bool _isVatPercChecked = true;
  bool _isQuantityChecked = true;
  bool _isLocationChecked = false;
  bool _isExpiryChecked = false;

  @override
  void initState() {
    _vatPercController.text = '11';
    super.initState();
  }

  @override
  void dispose() {
    _barcodeController.dispose();
    _nameController.dispose();
    _categoryController.dispose();
    _arabicNameController.dispose();
    _priceController.dispose();
    _price2Controller.dispose();
    _vatPercController.dispose();
    _quantityController.dispose();
    _locationController.dispose();
    _expiryController.dispose();
    super.dispose();
  }

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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a barcode';
                      }
                      return null;
                    },
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
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
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
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a category';
                }
                return null;
              },
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
                )),
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
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a price';
                }

                return null;
              },
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
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a price';
                }

                return null;
              },
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
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
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
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a quantity';
                }
                return null;
              },
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
                )),
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
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.calendar_month_rounded),
                onPressed: _showDatePicker,
              ),
            ),
            const Gap(15),
            PrimaryButton(
              onPressed: _onSaveButtonPressed,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onSaveButtonPressed() async {
    if (_formKey.currentState!.validate()) {
      showLoadingDialog('Adding Product', context);

      final barcode = _barcodeController.text.trim();
      final name = _nameController.text.trim();
      final category = _categoryController.text.trim();
      final arabicName = _arabicNameController.text.trim();
      final price = double.parse(_priceController.text.trim());
      final price2 = double.parse(_price2Controller.text.trim());
      final vatPerc = double.parse(_vatPercController.text.trim());
      final quantity = double.parse(_quantityController.text.trim());
      final location = _locationController.text.trim();
      final expiryDate = _expiryController.text.trim();

      // add to unsynced products
      UnSyncedProducts.addUnSyncedProduct(
        barcode: barcode,
        name: name,
        category: category,
        arabicName: arabicName,
        price: price,
        price2: price2,
        vatPerc: vatPerc,
        quantity: quantity,
        location: location,
        expiryDate: expiryDate,
      );

      // try to save to mysql
      final result = await MySQLService.addProduct(
        barcode: barcode,
        name: name,
        category: category,
        arabicName: arabicName,
        price: price,
        price2: price2,
        vatPerc: vatPerc,
        quantity: quantity,
        location: location,
        expiryDate: expiryDate,
      );

      if (result == ReturnTypes.duplicate) {
        showGlobalSnackBar('Product already exists');
        if (!mounted) return;
        Navigator.of(context).pop();
        return;
      }

      if (result == ReturnTypes.failed) {
        showGlobalSnackBar('Failed to add product');
        if (!mounted) return;
        Navigator.of(context).pop();
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Failed to add product'),
                content: const Text(
                    'Your product has been added to the un-synced products list. Check the dashboard to sync it later or remove it.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Ok'),
                  ),
                ],
              );
            });
        return;
      }

      showGlobalSnackBar('Product added successfully');
      if (!mounted) return;
      Navigator.of(context).pop();
    }
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

  void _showDatePicker() {
    showDatePicker(
      helpText: 'Select Expiry Date',
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1970),
      lastDate: DateTime(2100),
    ).then((value) {
      if (value != null) {
        _expiryController.text = value.toString().split(' ')[0];
        setState(() {
          _isExpiryChecked = true;
        });
      }
    });
  }
}
