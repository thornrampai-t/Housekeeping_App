class Promotion {
  final double discount;
  final String name;
  final DateTime startDay;
  final DateTime endDay;
  final String typePromotion;

  Promotion({
    required this.name,
    required this.discount,
    required this.startDay,
    required this.endDay,
    required this.typePromotion, // Fixed, Percent
  });
}
