import 'package:flutter/material.dart';
import 'livestock_form.dart';

class LivestockPage extends StatelessWidget {
  const LivestockPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('LiveStock Page')),
      
      floatingActionButton:   FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LivestockForm()),
            );
          },
          child: const Icon(Icons.add),
        ),
    );
  }
}
