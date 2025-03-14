import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project/Data/promotion.dart';
import 'package:project/page/user/pay_Success.dart';
import 'package:project/page/user/promotion.dart';
import 'package:project/provider/authProvider.dart';
import 'package:project/service.dart/firestore.dart';
import 'package:provider/provider.dart';

class PaymentPage extends StatefulWidget {
  final String address;
  final String selectedDate;
  final String isSwitched;
  final String remark;
  final String selectedTitle;
  final String selectedSubtitle;
  final double selectedPrice;

  const PaymentPage({
    super.key,
    required this.address,
    required this.selectedDate,
    required this.isSwitched,
    required this.remark,
    required this.selectedTitle,
    required this.selectedSubtitle,
    required this.selectedPrice,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String? selectPaymentType;
  double selectedDiscount = 0;
  String type = '';
  double finalPrice = 0.0;
  double totalDiscount = 0.0;
  final FirestoreService firestoreService = FirestoreService();

  DateTime dateNow = DateTime.now();
  String formattedDate = ''; // ประกาศตัวแปร formattedDate

  double calculateDiscount(double totalAmount, double discount, String type) {
    double finalPrice = totalAmount;

    if (type == 'fixed') {
      // กรณีลดเป็นจำนวนเงิน เช่น ลด 300 บาท
      finalPrice = totalAmount - discount;
    } else if (type == 'percent') {
      // กรณีลดเป็นเปอร์เซ็นต์ เช่น ลด 10%
      finalPrice = totalAmount - (totalAmount * (discount / 100));
    }

    // ป้องกันไม่ให้ราคาติดลบ
    return finalPrice < 0 ? 0 : finalPrice;
  }

  @override
  void initState() {
    super.initState();
    // คำนวณราคาหลังจากส่วนลด
    finalPrice = calculateDiscount(
      widget.selectedPrice,
      selectedDiscount,
      type,
    );
    var formatter = DateFormat('d MMMM yyyy HH:mm');
    formattedDate = formatter.format(dateNow);
  }

  void _applyDiscount(double totalAmount, double discount, String type) {
    setState(() {
      finalPrice = calculateDiscount(totalAmount, discount, type);
      totalDiscount = widget.selectedPrice - finalPrice;
    });
  }

  @override
  Widget build(BuildContext context) {
    DateTime dateTime = DateFormat(
      'EEE, d MMM yyyy h:mm a',
    ).parse(widget.selectedDate);
    String thaiFormat = DateFormat('d MMMM yyyy HH:mm ').format(dateTime);

    return Scaffold(
      appBar: AppBar(
        title: Text('รายละเอียด', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 25, 98, 47),
      ),
      backgroundColor: Color.fromARGB(255, 243, 247, 222),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 15, left: 15),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black),
                  ),
                  child: Icon(Icons.location_on, size: 34, color: Colors.red),
                ),

                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.address,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Divider(color: Colors.grey, thickness: 1),
          ),

          Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Align(
              alignment: Alignment.topLeft,

              child: Text(
                'รายละเอียด',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 2, top: 3),
            child: Text(
              'วันที่ $thaiFormat ขนาดห้อง ${widget.selectedSubtitle} ',
              style: TextStyle(fontSize: 16),
            ),
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 2),
            child: Row(
              children: [
                Text(
                  'ระยะเวลา ${widget.selectedTitle}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                SizedBox(width: 150),
                Expanded(
                  child: Text(
                    '${widget.selectedPrice.toString()} บาท',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Divider(color: Colors.grey, thickness: 1),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 20, right: 2),
              child: Text(
                'หมายเหตุ',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          SizedBox(height: 4),
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Text("${widget.isSwitched} ${widget.remark}"),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Divider(color: Colors.grey, thickness: 1),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 2),
              child: Text(
                'รายระเอียดการชำระเงิน',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          SizedBox(height: 3),
          ListTile(
            leading: Image.asset(
              'assets/images/promptpay.png',
              width: 70, // กำหนดความกว้าง
              height: 70, // กำหนดความสูง
              fit: BoxFit.cover, // กำหนดการปรับขนาดรูปภาพให้พอดีกับขนาดที่กำหนด
            ),
            title: Text('QR Promtpay', style: TextStyle(fontSize: 20)),
            trailing: Radio<String>(
              value: 'QR Promtpay',
              groupValue: selectPaymentType,
              activeColor: Colors.green,
              onChanged: (String? value) {
                setState(() {
                  selectPaymentType = value;
                  print("เลือก: $selectPaymentType");
                });
              },
            ),
          ),
          ListTile(
            leading: Padding(
              padding: const EdgeInsets.only(left: 9),
              child: Icon(Icons.money, size: 50),
            ), // ไอคอน
            title: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text("เงินสด", style: TextStyle(fontSize: 20)),
            ), // ข้อความ
            trailing: Radio<String>(
              value: 'เงินสด',
              groupValue: selectPaymentType,
              activeColor: Colors.green,
              onChanged: (String? value) {
                setState(() {
                  selectPaymentType = value;
                  print("เลือก: $selectPaymentType");
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Divider(color: Colors.grey, thickness: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'ใช้โปรโมชัน',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ),
              ),
              SizedBox(width: 150),
              IconButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              PromotionPage(promotion_list: promotions),
                    ),
                  );

                  if (result != null) {
                    var selectedDiscount = result['discount'];
                    var type = result['type'];
                    print('Discount: $selectedDiscount');
                    print('Type: $type');

                    // เรียกใช้ฟังก์ชัน calculateDiscount เพื่อคำนวณราคาหลังจากส่วนลด
                    _applyDiscount(
                      widget.selectedPrice,
                      selectedDiscount,
                      type,
                    ); // เรียกใช้ _applyDiscount

                    print('Final Price: $finalPrice');
                  } else {
                    print('No promotion selected');
                  }
                },

                icon: Icon(Icons.navigate_next_rounded, size: 35),
              ),
            ],
          ),
          SizedBox(height: 26),
          Expanded(
            child: Container(
              height: 95,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.green,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.only(left: 15, top: 4, right: 3),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'ยอดทั้งหมด',
                          style: TextStyle(fontSize: 21, color: Colors.white),
                        ),
                        SizedBox(width: 165),
                        Text(
                          finalPrice.toStringAsFixed(2),
                          style: TextStyle(
                            fontSize: 23,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (totalDiscount > 0)
                    Padding(
                      padding: const EdgeInsets.only(left: 15, right: 3),
                      child: Row(
                        children: [
                          Text(
                            'ลดไปทั้งหมด',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                          SizedBox(width: 212),
                          Text(
                            totalDiscount.toStringAsFixed(2),
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ],
                      ),
                    ),

                  SizedBox(height: 10),
                  Center(
                    // จัดให้อยู่ตรงกลาง
                    child: SizedBox(
                      width: double.infinity, // กำหนดความกว้าง
                      height: 50, // กำหนดความสูง
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () async {
                            // ตรวจสอบเบอร์โทรก่อน
                            bool hasPhone = await firestoreService
                                .checkPhoneNoOnce(
                                  context,
                                  Provider.of<UserProvider>(
                                    context,
                                    listen: false,
                                  ).userId,
                                );

                            // ถ้าไม่มีเบอร์โทร ไม่ให้ดำเนินการต่อ
                            if (!hasPhone) return;

                            // ดึงข้อมูลของ employee และ customer
                            String empolyeeName =
                                Provider.of<empolyeeProvider>(
                                  context,
                                  listen: false,
                                ).empolyeeName;
                            String customerName =
                                Provider.of<UserProvider>(
                                  context,
                                  listen: false,
                                ).userId;

                            // ข้อมูลการจอง
                            Map<String, dynamic> bookingData = {
                              'bookingId': DateTime.now().toString(),
                              'customerName': customerName,
                              'empolyeeName': empolyeeName,
                              'address': widget.address,
                              'bookingDate': formattedDate,
                              'selectedDate': widget.selectedDate,
                              'detail': "${widget.isSwitched} ${widget.remark}",
                              'finalPrice': finalPrice,
                              'status': 'status',
                            };

                            // เพิ่มข้อมูลการจอง
                            await firestoreService.addBooking(
                              customerName,
                              empolyeeName,
                              widget.address,
                              formattedDate,
                              widget.selectedDate,
                              '${widget.isSwitched} ${widget.remark}',
                              finalPrice,
                              'status',
                            );

                            // เพิ่มประวัติการจอง
                            await firestoreService.addHistory(
                              customerName,
                              bookingData,
                            );
                            Navigator.push(context, MaterialPageRoute(builder: (builder)=> PaySuccessPage()));
                          },
                          

                          child: Text(
                            'ชำระเงิน',
                            style: TextStyle(fontSize: 18, color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
