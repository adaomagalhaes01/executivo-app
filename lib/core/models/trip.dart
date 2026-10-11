class Trip {
  final String id;
  final String origin;
  final String destination;
  final DateTime date;
  final double value;
  final String paymentMethod;
  final String status;
  final String category;

  Trip({
    required this.id,
    required this.origin,
    required this.destination,
    required this.date,
    required this.value,
    required this.paymentMethod,
    required this.status,
    this.category = 'Executivo',
  });
}
