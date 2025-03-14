import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project/function/durationdate.dart';
import 'package:project/provider/authProvider.dart';
import 'package:project/service.dart/firestore.dart';
import 'package:project/widget/servicetypehistorywidget.dart';
import 'package:provider/provider.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  DateTime currentDate = DateTime.now();
  ChangeDuration changeDuration = ChangeDuration();
  final FirestoreService firestoreService = FirestoreService();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 243, 247, 222),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: firestoreService.getHistoryCustomerStream(
                Provider.of<UserProvider>(context, listen: false).userId,
              ), // กำหนด userName ที่ต้องการ
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                var docs = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var data = docs[index].data() as Map<String, dynamic>;

                    List bookingHistory = data['bookingHistory'] ?? [];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 5),
                        ListView.builder(
                          shrinkWrap: true, // ให้ ListView ซ้อนกันได้
                          physics:
                              NeverScrollableScrollPhysics(), // ปิด Scroll ซ้อน
                          itemCount: bookingHistory.length,
                          itemBuilder: (context, i) {
                            Map<String, dynamic> booking =
                                bookingHistory[i]; // ดึง Map ของแต่ละรายการ
                            String employeeName = booking['empolyeeName'];
                                                    StreamBuilder<String>(
                            stream: firestoreService.getServiceTypeStream(employeeName),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return CircularProgressIndicator(); // กำลังโหลดข้อมูล
                              }
                              if (snapshot.hasError) {
                                return Text("เกิดข้อผิดพลาด");
                              }
                              return Text(snapshot.data ?? 'ไม่พบข้อมูล');
                            },
                          );
                            // แปลง string -> datetime
                            String bookingDate = booking['bookingDate'];
                            DateFormat format = DateFormat("d MMMM yyyy HH:mm");
                            DateTime dateTime = format.parse(bookingDate);
                            Duration difference = currentDate.difference(
                              dateTime,
                            );
                            String formattedDuration = changeDuration
                                .formatDuration(difference);
                            print(formattedDuration);

                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  15,
                                ), // ทำให้ขอบมน
                                side: BorderSide(
                                  // เพิ่มขอบ
                                  color: Colors.grey, // สีของขอบ
                                  width: 1, // ความหนาของขอบ
                                ),
                              ),
                              color: Colors.grey.shade200, // สีพื้นหลังของ Card
                              margin: EdgeInsets.all(10), // ระยะห่างจากขอบ
                              child: Padding(
                                padding: const EdgeInsets.all(10),

                                child: Row(
                                  children: [

                                    StreamBuilder<String>(
                                      stream: firestoreService.getServiceTypeStream(employeeName),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return CircularProgressIndicator(); // กำลังโหลดข้อมูล
                                        }
                                        if (snapshot.hasError) {
                                          return Text("เกิดข้อผิดพลาด");
                                        }
                                        return getServiceTypeWidget(
                                         snapshot.data ?? 'ไม่พบข้อมูล',
                                         ); // แสดงค่าที่โหลดมา
                                      },
                                    ),
                                    SizedBox(width: 20),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              StreamBuilder<String>(
                                                stream: firestoreService
                                                    .getServiceTypeStream(
                                                      employeeName,
                                                    ),
                                                builder: (context, snapshot) {
                                                  if (snapshot
                                                          .connectionState ==
                                                      ConnectionState.waiting) {
                                                    return CircularProgressIndicator(); // โหลดข้อมูล
                                                  }
                                                  if (snapshot.hasError) {
                                                    return Text(
                                                      "เกิดข้อผิดพลาด",
                                                    );
                                                  }
                                                  return Text(
                                                    snapshot.data ??
                                                        'ไม่พบข้อมูล',
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ); // แสดงค่าที่โหลดมา
                                                },
                                              ),

                                              Text(
                                                formattedDuration,
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 2),
                                          Row(
                                            children: [
                                              Text('ที่อยู่', style: TextStyle(fontWeight: FontWeight.bold),),
                                              SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  '${booking['address']}',
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 2),
                                          Text(
                                            'จองวันที่',
                                           style: TextStyle(fontWeight: FontWeight.bold),),
                                          Text(
                                            '${booking['selectedDate']}',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
