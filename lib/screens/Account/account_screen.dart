import 'package:flutter/material.dart';
import 'package:lock_item/services/user_service.dart';
import 'package:lock_item/models/user.dart';
import 'package:lock_item/shared/handlers/jwt_handler.dart';
import 'package:logger/logger.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  User? user;
  final UserService _userService = UserService();
  final Logger _logger = Logger();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final handler = await JwtHandler.fromStorage();
      final userId = handler.getUserId();
      _logger.i('User ID from token: $userId');

      final fetchedUser = await _userService.getUserById(userId);
      if (fetchedUser == null) {
        _logger.e('Failed to fetch user data.');
        return;
      }

      setState(() {
        user = fetchedUser;
        isLoading = false;
      });
      _logger.i('User data loaded successfully: ${fetchedUser.toJson()}');
    } catch (e) {
      _logger.e('Error loading user data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildUserInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
              fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const Divider(height: 32, thickness: 1),
      ],
    );
  }

  ButtonStyle commonButtonStyle() {
    return ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
      backgroundColor: Colors.black,
    );
  }

  void _showEditDialog() {
    if (user == null) return;

    final TextEditingController nameController =
        TextEditingController(text: user!.name);
    final TextEditingController lastnameController =
        TextEditingController(text: user!.lastname);
    final TextEditingController emailController =
        TextEditingController(text: user!.email);
    final TextEditingController phoneController =
        TextEditingController(text: user!.phone);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: lastnameController,
                  decoration: const InputDecoration(labelText: 'Last Name'),
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Phone'),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: commonButtonStyle(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final updatedUser = User(
                  id: user!.id,
                  username: user!.username,
                  name: nameController.text,
                  lastname: lastnameController.text,
                  email: emailController.text,
                  phone: phoneController.text,
                );

                final success =
                    await _userService.updateUser(user!, updatedUser);
                if (success) {
                  setState(() {
                    user = updatedUser;
                  });
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to update profile')),
                  );
                }
              },
              style: commonButtonStyle(),
              child: const Text(
                'Save',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () async {
              await _userService.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildUserInfo('Full Name',
                      '${user?.name ?? 'N/A'} ${user?.lastname ?? 'N/A'}'),
                  _buildUserInfo('Username', user?.username ?? 'N/A'),
                  _buildUserInfo('Email Address', user?.email ?? 'N/A'),
                  _buildUserInfo('Phone Number', user?.phone ?? 'N/A'),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: _showEditDialog,
                      style: commonButtonStyle(),
                      child: const Text(
                        'Edit',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
