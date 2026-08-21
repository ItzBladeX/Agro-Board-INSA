class CropRecord {
  const CropRecord({
    required this.cropId,
    required this.name,
    required this.season,
    required this.expectedYieldKgPerHa,
    required this.actualYieldKgPerHa,
  });
  final double cropId;
  final String name;
  final String season;
  final double expectedYieldKgPerHa;
  final double actualYieldKgPerHa;
}
