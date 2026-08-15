class LivestockRecord {
  const LivestockRecord({
    required this.species,
    required this.feedKgPerDay,
    required this.outputLitersPerDay,
    required this.health,
  });

  final String species;
  final double feedKgPerDay;
  final double outputLitersPerDay;
  final String health;
}
