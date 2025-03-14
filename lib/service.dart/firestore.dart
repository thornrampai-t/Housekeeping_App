import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project/page/user/pay_Success.dart';
import 'package:project/provider/authProvider.dart';
import 'package:project/widget/warnphonno.dart';
import 'package:provider/provider.dart';

class FirestoreService {
  // ข้อมูลพนักงาน
  final CollectionReference employee = FirebaseFirestore.instance.collection(
    'Employee_test',
  );

  Stream<QuerySnapshot> getWhereDeepCleanStream() {
    final deepCleanStream =
        employee.where('position', isEqualTo: 'Deep Clean').snapshots();
    return deepCleanStream;
  }

  Stream<QuerySnapshot> getWhereGardenStream() {
    final deepCleanStream =
        employee.where('position', isEqualTo: 'Garden').snapshots();
    return deepCleanStream;
  }

  Stream<QuerySnapshot> getWhereCareStream() {
    final deepCleanStream =
        employee.where('position', isEqualTo: 'Care').snapshots();
    return deepCleanStream;
  }

  Stream<QuerySnapshot> getWherePetStream() {
    final deepCleanStream =
        employee.where('position', isEqualTo: 'Pet').snapshots();
    return deepCleanStream;
  }

  Stream<QuerySnapshot> getEmployee() {
    final employeeSteam = employee.orderBy('name').snapshots();

    return employeeSteam;
  }

  Stream<QuerySnapshot> searchEmployee(String query) {
    if (query.isEmpty) {
      return getEmployee(); // ถ้าไม่มีคำค้นหาให้ดึงข้อมูลทั้งหมด
    }

    return employee
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: query + '\uf8ff') // ค้นหาแบบ prefix
        .snapshots();
  }

  Stream<String> getServiceTypeStream(String employeeName) {
    return employee
        .where('name', isEqualTo: employeeName)
        .limit(1) // จำกัดผลลัพธ์ให้ได้แค่ 1 เอกสาร
        .snapshots() // รับข้อมูลแบบสตรีม
        .map((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            return snapshot.docs.first['position'] ?? 'ไม่พบข้อมูล';
          }
          return 'ไม่พบข้อมูล';
        });
  }

  //--------------------------------------------------------------------
  // ข้อมูล customer
  final CollectionReference customer = FirebaseFirestore.instance.collection(
    'Customer',
  );

  Stream<String> getWhereUserIdStream(String email) {
    final customerStream = customer
        .where('userEmail', isEqualTo: email)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            final doc = snapshot.docs.first.data() as Map<String, dynamic>;
            final userId = doc['userId'].toString();

            return userId;
          } else {
            return 'ไม่พบข้อมูล';
          }
        });
    return customerStream;
  }

  Stream<String> getuserNameStream(String userId) {
    final customerStream = customer
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            final doc = snapshot.docs.first.data() as Map<String, dynamic>;
            final userId = doc['userName'].toString();

            return userId;
          } else {
            return 'ไม่พบข้อมูล';
          }
        });
    return customerStream;
  }

  Future<bool> checkPhoneNoOnce(BuildContext context, String userId) async {
    var querySnapshot = await customer.where('userId', isEqualTo: userId).get();

    if (querySnapshot.docs.isEmpty) {
      print("ไม่พบข้อมูลของชื่อนี้");
      return false; // แก้ให้คืนค่า false ถ้าไม่พบข้อมูล
    }

    var userData = querySnapshot.docs.first.data() as Map<String, dynamic>;
    if (userData.containsKey('phoneNum') &&
        userData['phoneNum'].toString().isNotEmpty) {
      print("มีเบอร์โทร: ${userData['phoneNum']}");
      return true;
    } else {
      showPopup(
        context,
        "แจ้งเตือน",
        "ไม่มีการบันทึกเบอร์โทร กรุณาเพิ่มเบอร์ที่ตั้งค่า",
      );
      return false;
    }
  }

  Stream<String> getImageCustomerStream(String userId) {
    return customer
        .where('userId', isEqualTo: userId)
        .limit(1) // จำกัดผลลัพธ์ให้ได้แค่ 1 เอกสาร
        .snapshots() // รับข้อมูลแบบสตรีม
        .map((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            return snapshot.docs.first['userPhoto'] ?? 'ไม่พบข้อมูล';
          }
          return 'ไม่พบข้อมูล';
        });
  }

  Stream<QuerySnapshot> getHistoryCustomerStream(String userId) {
    final customerHistoryStream =
        customer.where('userId', isEqualTo: userId).snapshots();
    return customerHistoryStream;
  }

  // update
  Future<void> addHistory(String userId, Map<String, dynamic> booking) async {
    QuerySnapshot querySnapshot =
        await customer.where('userId', isEqualTo: userId).get();

    if (querySnapshot.docs.isNotEmpty) {
      DocumentReference customerDoc = querySnapshot.docs.first.reference;

      await customerDoc.update({
        'bookingHistory': FieldValue.arrayUnion([booking]),
      });

      print("✅ เพิ่มข้อมูลการจองลงใน bookingHistory สำเร็จ");
    } else {
      print("❌ ไม่พบลูกค้าในฐานข้อมูล");
    }
  }
  Future<void> addBookLocation(String userId, Map<String, dynamic> booking) async {
    QuerySnapshot querySnapshot =
        await customer.where('userId', isEqualTo: userId).get();

    if (querySnapshot.docs.isNotEmpty) {
      DocumentReference customerDoc = querySnapshot.docs.first.reference;

      await customerDoc.update({
        'bookingHistory': FieldValue.arrayUnion([booking]),
      });

      print("✅ เพิ่มข้อมูลการจองลงใน bookingHistory สำเร็จ");
    } else {
      print("❌ ไม่พบลูกค้าในฐานข้อมูล");
    }
  }

  Future<void> updateFullNameCustomer(BuildContext context, String userId, String newUserName) async {
    if (newUserName.isEmpty) {
      print('ไม่มีการเปลี่ยนชื่อ');
    } else {
      QuerySnapshot querySnapshot =
          await customer.where('userId', isEqualTo: userId).get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentReference customerDoc = querySnapshot.docs.first.reference;

        await customerDoc.update({
          'userName': newUserName, // 🔄 เปลี่ยน userName เป็นค่าใหม่
        });
      

        print("✅ เปลี่ยนชื่อผู้ใช้เป็น '$newUserName' สำเร็จ!");
      } else {
        print("❌ ไม่พบผู้ใช้ที่มี userName = '$userId'");
      }
    }
  }

  Future<void> updatePhoneNumCustomer(String userId, String newPhoneNum) async {
    if (newPhoneNum.isEmpty) {
      print('ไม่มีการเปลี่ยนชื่อ');
    } else {
      QuerySnapshot querySnapshot =
          await customer.where('userId', isEqualTo: userId).get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentReference customerDoc = querySnapshot.docs.first.reference;

        await customerDoc.update({
          'phoneNum': newPhoneNum, // 🔄 เปลี่ยน userName เป็นค่าใหม่
        });

        print("✅ เปลี่ยนเบอร์ใช้เป็น '$newPhoneNum' สำเร็จ!");
      } else {
        print("❌ ไม่พบผู้ใช้ที่มี userId = '$userId'");
      }
    }
  }

  Future<void> updatPasswordCustomer(String userId, String newPassword) async {
    QuerySnapshot querySnapshot =
        await customer.where('userId', isEqualTo: userId).get();

    print("🟢 Firestore Query Completed!");

    if (querySnapshot.docs.isNotEmpty) {
      DocumentReference customerDoc = querySnapshot.docs.first.reference;
      print("🟢 User found, updating password...");

      // 🔄 ต้อง `await` update() เพื่อให้แน่ใจว่าเสร็จก่อนดำเนินการต่อ
      await customerDoc.update({'userPassword': newPassword});

      print("Password updated successfully for userId: $userId!");
    } else {
      print("No user found with userId: '$userId'");
    }
  }

  //-------------------------
  final CollectionReference booking = FirebaseFirestore.instance.collection(
    'Booking',
  );
  // บันทึกการจอง
  Future<void> addBooking(
    String customer,
    String empolyee,
    String address,
    String bookingDate,
    String serviceDate,
    String detail,
    double totalPrice,
    String status,
  ) {
    return booking.add({
      'bookingId': DateTime.now().toString(),
      'customer': customer,
      'empolyee': empolyee,
      'address': address,
      'bookingDate': bookingDate,
      'serviceDate': serviceDate,
      'detail': detail,
      'totalPrice': totalPrice,
      'status': status,
    });
  }
}
