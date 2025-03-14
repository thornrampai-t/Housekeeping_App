import 'package:project/Data/employee.dart';
import 'package:project/Data/customer.dart';

class Review {
  final int reviewId;
  final Customer user; // เก็บเป็น object ของ User แทนการเก็บแค่ userId
  final Employee housekeeper; // เก็บเป็น object ของ Employee แทนการเก็บแค่ housekeeperId
  final double rating;
  final String comment;

  Review({
    required this.reviewId,
    required this.user,
    required this.housekeeper,
    required this.rating,
    required this.comment,
  });
}
