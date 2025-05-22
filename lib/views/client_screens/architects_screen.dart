import 'package:flutter/material.dart';

class ArchitectsScreen extends StatelessWidget {
  const ArchitectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Architects')),
      body: const Center(
        child: Text(
          'List of Architects will be shown here.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
