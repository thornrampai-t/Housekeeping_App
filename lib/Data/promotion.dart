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
    required this.typePromotion, // fixed, percent
  });
}

List<Promotion> promotions = [
  Promotion(
    name: 'ลด 300 บาท',
    discount: 300.00,
    startDay: DateTime(2025, 2, 23),
    endDay: DateTime(2025, 3, 1),
    typePromotion: 'fixed'
  ),
  Promotion(
    name: 'ลด 20 บาท',
    discount: 20.00,
    startDay: DateTime(2025, 2, 23),
    endDay: DateTime(2025, 3, 1),
    typePromotion: 'fixed'
  ),
  Promotion(
    name: 'ลด 20%',
    discount: 20,
    startDay: DateTime(2025, 2, 22),
    endDay: DateTime(2025, 2, 23),
    typePromotion: 'percent'
  ),
];
