import 'package:project/Data/employee.dart';
import 'package:project/Data/customer.dart';

class Booking {
  final int bookingId; // รหัสการจอง
  final Customer user; // ผู้จอง (เก็บข้อมูล User)
  final Employee housekeeper; // แม่บ้านที่ทำงาน (เก็บข้อมูล Employee)
  final DateTime bookingDate; // วันที่ทำการจอง
  final DateTime serviceDate; // วันที่ทำการบริการ
  final double totalPrice; // ราคาทั้งหมดของการบริการ
  final String description; // หมายเหตุ
  final String status; // สถานะการการจ่ายเงิน

  Booking({
    required this.bookingId,
    required this.user,
    required this.housekeeper,
    required this.bookingDate,
    required this.serviceDate,
    required this.totalPrice,
    required this.description,
    required this.status,
  });
}
