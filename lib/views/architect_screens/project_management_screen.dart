import 'package:flutter/material.dart';

class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Projects')),
      body: const Center(
        child: Text(
          'Project management UI will appear here.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

