import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_client.dart';

class DynamicCropTableBody extends StatefulWidget {
  final void Function(Map<String, dynamic> crop)? onActionPressed;

  const DynamicCropTableBody({super.key, this.onActionPressed});

  @override
  State<DynamicCropTableBody> createState() => DynamicCropTableBodyState();
}

class DynamicCropTableBodyState extends State<DynamicCropTableBody> {
  final ApiClient _apiClient = ApiClient();
  List<Map<String, dynamic>> _data = [];
  bool _isLoading = false;
  String? _error;

  static const _hiddenKeys = {'id', 'user_id', 'crop_type_id', 'notes'};
  static const _priorityOrder = [
    'name', 'crop_yield', 'profit', 'revenue', 'prod_cost',
    'planted_date', 'harvest_date', 'prod_start_year', 'prod_end_year',
  ];

  @override
  void initState() {
    super.initState();
    fetchCrops();
  }

  Future<void> fetchCrops() async {
    if (_isLoading) return;

    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final response = await _apiClient.get("/crop/get");
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        if (json['success'] == true && json['data'] is List) {
          if (mounted) {
            setState(() {
              _data = (json['data'] as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
              _isLoading = false;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _error = json['message']?.toString() ?? 'Unexpected response';
              _isLoading = false;
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _error = 'Server error: ${response.statusCode}';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Network error: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteCrop(Map<String, dynamic> item) async {
    final cropId = item['id'];

    if (cropId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Missing crop id')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Crop'),
        content: Text('Are you sure you want to delete "${item['name'] ?? 'this crop'}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final index = _data.indexWhere((e) => e['id'] == cropId);
    Map<String, dynamic>? removed;
    if (index != -1 && mounted) {
      setState(() => removed = _data.removeAt(index));
    }

    try {
      final response = await _apiClient.delete("/crop/delete/$cropId");

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('"${item['name']}" deleted successfully'),
              backgroundColor: const Color(0xFF00ED64),
            ),
          );
        }
      } else {
        if (removed != null && mounted) {
          setState(() => _data.insert(index, removed!));
        }
        String message = 'Failed to delete (${response.statusCode})';
        try {
          final body = jsonDecode(response.body);
          message = body['message']?.toString() ?? body['detail']?.toString() ?? message;
        } catch (_) {}
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (removed != null && mounted) {
        setState(() => _data.insert(index, removed!));
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Network error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _data.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _data.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: fetchCrops, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_data.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('No crop records found.'),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: fetchCrops, child: const Text('Refresh')),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final visibleKeys = _getVisibleKeys(constraints.maxWidth);
        return RefreshIndicator(
          onRefresh: fetchCrops,
          child: Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: _buildTable(keys: visibleKeys, isHeader: true, rows: const []),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minWidth: constraints.maxWidth),
                      child: _buildTable(keys: visibleKeys, isHeader: false, rows: _data),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<String> _getVisibleKeys(double width) {
    final allKeys = _data.first.keys.where((k) => !_hiddenKeys.contains(k)).toList();
    allKeys.sort((a, b) {
      final ia = _priorityOrder.indexOf(a);
      final ib = _priorityOrder.indexOf(b);
      if (ia == -1 && ib == -1) return 0;
      if (ia == -1) return 1;
      if (ib == -1) return -1;
      return ia.compareTo(ib);
    });

    int maxColumns;
    if (width < 500) {
      maxColumns = 3;
    } else if (width < 700) {
      maxColumns = 5;
    } else if (width < 900) {
      maxColumns = 7;
    } else {
      maxColumns = allKeys.length;
    }
    return allKeys.take(maxColumns).toList();
  }

  Widget _buildTable({
    required List<String> keys,
    required bool isHeader,
    required List<Map<String, dynamic>> rows,
  }) {
    return DataTable(
      columnSpacing: 20,
      horizontalMargin: 12,
      headingRowHeight: isHeader ? 48 : 0,
      dataRowMinHeight: isHeader ? 0 : 48,
      dataRowMaxHeight: isHeader ? 0 : 56,
      headingRowColor: WidgetStateProperty.all(Colors.grey.shade200),
      columns: [
        ...keys.map((key) => DataColumn(
              label: Text(_formatHeaderName(key), style: const TextStyle(fontWeight: FontWeight.bold)),
            )),
        const DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
      ],
      rows: isHeader
          ? []
          : rows.map((row) {
              return DataRow(
                cells: [
                  ...keys.map((key) => DataCell(Text(row[key]?.toString() ?? '-'))),
                  DataCell(
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      onSelected: (value) {
                        if (value == 'edit') {
                          widget.onActionPressed?.call(row);
                        } else if (value == 'delete') {
                          _deleteCrop(row);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(children: [Icon(Icons.edit, size: 20), SizedBox(width: 8), Text('Edit')]),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ]),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
    );
  }

  String _formatHeaderName(String key) {
    return key.split('_').map((word) {
      if (word.isEmpty) return '';
      return '${word[0].toUpperCase()}${word.substring(1)}';
    }).join(' ');
  }
}