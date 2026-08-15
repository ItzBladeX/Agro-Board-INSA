import 'package:flutter/material.dart';

import './models/crop_model.dart';

class CropTable extends StatelessWidget {
  const CropTable({super.key, required this.crops});

  final List<CropRecord> crops;

  @override
  Widget build(BuildContext context) => PaginatedDataTable(
    header: const Text('Crop records'),
    rowsPerPage: crops.length < 5 ? crops.length : 5,
    columns: const [
      DataColumn(label: Text("crop id")),
      DataColumn(label: Text('crop Name')),
      DataColumn(label: Text('Season(planting - harvesting)')),
      DataColumn(label: Text('Expected Yield (kg/ha)')),
      DataColumn(label: Text('Actual Yield (kg/ha)')),
    ],
    source: _CropDataSource(crops),
  );
}

class _CropDataSource extends DataTableSource {
  _CropDataSource(this.crops);

  final List<CropRecord> crops;

  @override
  DataRow? getRow(int index) {
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
