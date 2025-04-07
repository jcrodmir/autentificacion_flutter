import 'package:flutter/material.dart';

class CheckOutStatusScreen extends StatelessWidget {
  const CheckOutStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(strokeWidth: 2,
        ),
      ),
    );
  }
}