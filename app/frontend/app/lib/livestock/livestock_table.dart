import 'package:flutter/material.dart';

import './models/livestock_model.dart';

class LivestockTable extends StatelessWidget {
  const LivestockTable({super.key, required this.livestock});

  final List<LivestockRecord> livestock;

  @override
  Widget build(BuildContext context) => PaginatedDataTable(
    header: const Text('Livestock records'),
    rowsPerPage: livestock.length < 5 ? livestock.length : 5,
    columns: const [
      DataColumn(label: Text('Species')),
      DataColumn(label: Text('Feed')),
      DataColumn(label: Text('Output')),
      DataColumn(label: Text('Health')),
    ],
    source: _LivestockDataSource(livestock),
  );
}

class _LivestockDataSource extends DataTableSource {
  _LivestockDataSource(this.livestock);

  final List<LivestockRecord> livestock;

  @override
  DataRow? getRow(int index) {
    final row = livestock[index];
    final color = row.health == 'Healthy'
        ? Colors.green.shade100
        : row.health == 'Moderate'
        ? Colors.amber.shade100
        : Colors.red.shade100;

    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(row.species)),
        DataCell(Text('${row.feedKgPerDay.toStringAsFixed(1)} kg')),
        DataCell(Text('${row.outputLitersPerDay.toStringAsFixed(1)} L')),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(row.health),
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => livestock.length;

  @override
  int get selectedRowCount => 0;
}
