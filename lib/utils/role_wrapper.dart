import 'package:flutter/material.dart';
import 'package:green_table/pages/consumer_dash.dart';
import 'package:green_table/pages/restaurant_dash.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RoleWrapper extends StatefulWidget {
  const RoleWrapper({super.key});  // Add constructor
  
  @override
  _RoleWrapperState createState() => _RoleWrapperState();
}

class _RoleWrapperState extends State<RoleWrapper> {
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userRole = prefs.getString('user_role');
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_userRole == 'consumer') {
      return ConsumerApp();
    } else if (_userRole == 'restaurant') {
      return RestaurantApp();
    }
    return Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}