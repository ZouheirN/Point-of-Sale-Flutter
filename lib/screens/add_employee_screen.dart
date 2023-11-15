import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:pos_app/services/mysql_service.dart';
import 'package:pos_app/widgets/buttons.dart';

const List<String> _list = [
  'Admin',
  'Employee',
];

class AddEmployeeScreen extends StatefulWidget {
  const AddEmployeeScreen({super.key});

  @override
  State<AddEmployeeScreen> createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fnameController = TextEditingController();
  final _lnameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _roleController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  Text _status = const Text("");

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _fnameController.dispose();
    _lnameController.dispose();
    _phoneController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Employee'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(15),
          children: [
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a username';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a password';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _fnameController,
              decoration: const InputDecoration(
                labelText: 'First Name',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your first name';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _lnameController,
              decoration: const InputDecoration(
                labelText: 'Last Name',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your last name';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone',
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a phone number';
                }
                return null;
              },
            ),
            CustomDropdown<String>(
              hintText: 'Role',
              items: _list,
              onChanged: (value) {
                _roleController.text = value;
              },
            ),
            // TextFormField(
            //   controller: _roleController,
            //   decoration: const InputDecoration(
            //     labelText: 'Role',
            //   ),
            //   validator: (value) {
            //     if (value == null || value.isEmpty) {
            //       return 'Please enter a role';
            //     }
            //     return null;
            //   },
            // ),
            const Gap(20),
            Align(alignment: Alignment.center, child: _status),
            const Gap(20),
            PrimaryButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  setState(() {
                    _status = const Text('Adding user...',
                        style: TextStyle(color: Colors.grey));
                  });

                  // todo check if user already exists

                  // add to MySQL
                  final result = await MySQLService.addUser(
                    _usernameController.text,
                    _passwordController.text,
                    _fnameController.text,
                    _lnameController.text,
                    _phoneController.text,
                    _roleController.text,
                  );

                  if (result == ReturnTypes.failed) {
                    setState(() {
                      _status = const Text('Failed to add user',
                          style: TextStyle(color: Colors.red));
                    });
                  } else if (result == ReturnTypes.duplicate) {
                    setState(() {
                      _status = const Text('User already exists',
                          style: TextStyle(color: Colors.red));
                    });
                  } else if (result == ReturnTypes.success) {
                    setState(() {
                      _status = const Text('User added',
                          style: TextStyle(color: Colors.green));
                    });
                  }
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}
