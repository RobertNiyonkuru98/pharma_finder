import 'package:flutter/material.dart';

class InsuranceScreen extends StatelessWidget {
  const InsuranceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Health Insurance'),
        backgroundColor: const Color(0xFF0A6C56),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text(
          'Insurance Selection Page',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}