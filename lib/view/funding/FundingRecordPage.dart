import 'package:flutter/material.dart';

class FundingRecordPage extends StatelessWidget {
  const FundingRecordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Funding Records'),
      ),
      body: const Center(child: Text('Funding Record Page')),
    );
  }
}
