// ignore_for_file: avoid_print

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:green_table/api/auth_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../pages/login_page.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String email;
  final String password;
  
  const OTPVerificationScreen({
    super.key,
    required this.email,
    required this.password,
  });

  @override
  _OTPVerificationScreenState createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final _otpController = TextEditingController();
  int _resendAttempts = 0;
  DateTime? _firstResendTime;
  bool _canResend = true;
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    _loadResendAttempts();
  }

  Future<void> _loadResendAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _resendAttempts = prefs.getInt('resendAttempts') ?? 0;
      _firstResendTime = DateTime.parse(prefs.getString('firstResendTime') ?? DateTime.now().toString());
    });
  }

  Future<void> _handleResendOTP() async {
    if (_resendAttempts >= 3) {
      final hoursSinceFirstAttempt = DateTime.now().difference(_firstResendTime!).inHours;
      if (hoursSinceFirstAttempt < 24) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Maximum resend attempts reached. Try again after 24 hours')),
        );
        return;
      }
      await _resetResendCounter();
    }

    try {
      final response = await AuthAPI.resendOTP(widget.email, widget.password);
      if (response['success'] == true) {
        setState(() {
          _resendAttempts++;
          if (_resendAttempts == 1) {
            _firstResendTime = DateTime.now();
          }
        });
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('resendAttempts', _resendAttempts);
        await prefs.setString('firstResendTime', _firstResendTime!.toIso8601String());
        _startCooldownTimer();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Failed to resend OTP')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to resend OTP: ${e.toString()}')),
      );
    }
  }

  void _startCooldownTimer() {
    const cooldown = Duration(seconds: 30);
    setState(() => _canResend = false);
    _cooldownTimer = Timer(cooldown, () {
      setState(() => _canResend = true);
    });
  }

  Future<void> _resetResendCounter() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('resendAttempts');
    await prefs.remove('firstResendTime');
    setState(() {
      _resendAttempts = 0;
      _firstResendTime = null;
    });
  }

  Future<void> _verifyOTP() async {
    try {
      final response = await AuthAPI.verifyOTP(
        email: widget.email,
        otp: _otpController.text,
      );
      
      print('OTP Verification Response: $response');
      
      if ((response['success']?.toString().toLowerCase() ?? 'false') == 'true') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('OTP verified successfully')),
        );
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LoginPage(),
            settings: RouteSettings(
              name: '/login',
              arguments: {
                'email': widget.email,
                'password': widget.password
              },
            ),
          ),
        );
      } else {
        final errorMessage = response['error'] is Map 
            ? response['error']['message'] 
            : response['message'] ?? 'OTP verification failed';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage.toString())),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verification error: ${e.toString()}')),
      );
    }
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Enter OTP sent to ${widget.email}'),
            TextFormField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'OTP'),
            ),
            ElevatedButton(
              onPressed: _verifyOTP,
              child: const Text('Verify OTP'),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: _canResend && _resendAttempts < 3 ? _handleResendOTP : null,
              child: _resendAttempts >= 3 
                ? Text('Try again in ${24 - DateTime.now().difference(_firstResendTime!).inHours} hours')
                : const Text('Resend OTP'),
            ),
          ],
        ),
      ),
    );
  }
}