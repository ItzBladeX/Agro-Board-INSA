import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import './models/crop_model.dart';

class CropTable extends StatelessWidget {
  const CropTable({super.key, required this.crops});

  final List<CropRecord> crops;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return Column(
            children: crops.map((crop) {
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ListTile(
                  title: Text(
                    crop.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'ID: ${crop.cropId.toStringAsFixed(0)}\n'
                    'Season: ${crop.season}\n'
                    'Expected: ${crop.expectedYieldKgPerHa.toStringAsFixed(0)} kg/ha\n'
                    'Actual: ${crop.actualYieldKgPerHa.toStringAsFixed(0)} kg/ha',
                  ),
                  isThreeLine: true,
                ),
              );
            }).toList(),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            height: 300,
            child: PaginatedDataTable2(
              header: const Text('Crop Records'),
              headingRowColor: WidgetStateProperty.all(
                Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              columnSpacing: 10,
              horizontalMargin: 12,
              minWidth: 900,
              rowsPerPage: 5,
              availableRowsPerPage: const [5, 10, 20],
              columns: const [
                DataColumn2(label: Text('Crop ID'), size: ColumnSize.S),
                DataColumn2(label: Text('Name'), size: ColumnSize.M),
                DataColumn2(
                  label: Text('Season (Planting - Harvesting)'),
                  size: ColumnSize.L,
                ),
                DataColumn2(
                  label: Text('Expected Yield (kg/ha)'),
                  numeric: true,
                  size: ColumnSize.M,
                ),
                DataColumn2(
                  label: Text('Actual Yield (kg/ha)'),
                  numeric: true,
                  size: ColumnSize.M,
                ),
              ],
              source: _CropDataSource(crops),
            ),
          ),
        );
      },
    );
  }
}

class _CropDataSource extends DataTableSource {
  _CropDataSource(this.crops);

  final List<CropRecord> crops;

  @override
  DataRow? getRow(int index) {
    if (index >= crops.length) return null;
    final crop = crops[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(crop.cropId.toStringAsFixed(0))),
        DataCell(Text(crop.name)),
        DataCell(Text(crop.season)),
        DataCell(Text(crop.expectedYieldKgPerHa.toStringAsFixed(0))),
        DataCell(Text(crop.actualYieldKgPerHa.toStringAsFixed(0))),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => crops.length;

  @override
  int get selectedRowCount => 0;
}
