class WeightEntry {
  const WeightEntry({
    required this.id,
    required this.date,
    required this.weightKg,
    required this.createdAt,
  });

  final int id;
  final String date; // YYYY-MM-DD
  final double weightKg;
  final DateTime createdAt;
}
