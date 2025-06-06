import 'package:flutter/material.dart';

class InvestmentFormPage extends StatelessWidget {
  const InvestmentFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Investment Form'),
      ),
      body: const Center(child: Text('Investment Form Page')),
    );
  }
}
