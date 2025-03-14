import 'package:project/Data/booking.dart';
import 'package:project/Data/marker_data.dart';

class Customer {
  String userId; // คิดว่าจะไม่เอาแล้ว
  String name;
  String phoneNumber;
  String email;
  String password;
  String typeacc;
  String photo;
  List<MarkerData> addresses;
  List<Booking> bookingHistory;

  // type ระหว่าง customer/employee

  Customer({
    required this.userId,
    required this.name,
    required this.phoneNumber,
    required this.email,
    required this.password,
    required this.typeacc,
    required this.photo,
    required this.addresses,
    required this.bookingHistory,
  });
}
