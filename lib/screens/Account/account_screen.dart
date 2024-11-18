import 'package:flutter/material.dart';
import 'package:lock_item/services/user_service.dart';
import 'package:lock_item/models/user.dart';
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
      final decodedToken = await _userService.getDecodedToken();
      if (decodedToken != null) {
        final userId = int.parse(decodedToken['sub']);
        _logger.i('User ID from token: $userId');
        final fetchedUser = await _userService.getUserById(userId);

        if (fetchedUser != null) {
          setState(() {
            user = fetchedUser;
            isLoading = false;
          });
          _logger.i('User data loaded successfully: ${fetchedUser.toJson()}');
        } else {
          _logger.e('Failed to fetch user data.');
        }
      } else {
        _logger.e('Decoded token is null.');
      }
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
          style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold),
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
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserInfo('Full Name', '${user?.name ?? 'N/A'} ${user?.lastname ?? 'N/A'}'),
            _buildUserInfo('Username', user?.username ?? 'N/A'),
            _buildUserInfo('Email Address', user?.email ?? 'N/A'),
            _buildUserInfo('Phone Number', user?.phone ?? 'N/A'),
          ],
        ),
      ),

    );
  }
}
