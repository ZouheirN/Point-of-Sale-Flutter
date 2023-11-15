import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:pos_app/screens/home_screen.dart';
import 'package:pos_app/screens/settings_screen.dart';
import 'package:pos_app/services/sqlite_service.dart';
import 'package:pos_app/widgets/buttons.dart';
import 'package:pos_app/widgets/textfields.dart';

import '../services/userinfo_crud.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _status = '';
  bool _isLoading = false;

  _login() async {
    if (_formKey.currentState!.validate()) {
      if (_isLoading) return;

      setState(() {
        _isLoading = true;
      });

      final username = _usernameController.text.trim();
      final password = _passwordController.text;

      // check if username and password is correct and return all user info
      final user = await SqliteService.getUser(username, password);

      if (user == null) {
        setState(() {
          _isLoading = false;
          _status = 'Invalid username or password';
        });
        return;
      }

      setState(() {
        _isLoading = false;
      });

      // Save to Hive
      UserInfo.setUserInfo(
        user['username'],
        user['role'],
        user['fname'],
        user['lname'],
      );

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()));
    }
  }

  _goToSettings() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const SettingsScreen()));
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Point of Sale App'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _goToSettings,
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  PrimaryTextField(
                    formKey: _formKey,
                    hintText: "Username",
                    controller: _usernameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your username';
                      }
                      return null;
                    },
                  ),
                  const Gap(20),
                  PrimaryTextField(
                    formKey: _formKey,
                    hintText: "Password",
                    obscureText: true,
                    controller: _passwordController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  const Gap(30),
                  Text(_status, style: const TextStyle(color: Colors.red)),
                  const Gap(30),
                  PrimaryButton(
                    onPressed: _login,
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text('Login', style: TextStyle(fontSize: 20)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
