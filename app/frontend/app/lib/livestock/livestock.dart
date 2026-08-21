import 'package:flutter/material.dart';
import 'livestock_form.dart';
import 'livestock_table.dart';

class LivestockPage extends StatefulWidget {
  const LivestockPage({super.key});

  @override
  State<LivestockPage> createState() => _LivestockPageState();
}

class _LivestockPageState extends State<LivestockPage> {
  final _tableKey = GlobalKey<DynamicLivestockTableBodyState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Livestock Page')),
      body: DynamicLivestockTableBody(
        key: _tableKey,
        onActionPressed: (livestock) async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => LivestockForm(livestock: livestock),
            ),
          );
          if (result == true) {
            _tableKey.currentState?.fetchLivestock();
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LivestockForm()),
          );
          if (result == true) {
            _tableKey.currentState?.fetchLivestock();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}