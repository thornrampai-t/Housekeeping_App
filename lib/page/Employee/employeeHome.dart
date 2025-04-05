import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project/page/Employee/employeeAccount.dart';
import 'package:project/page/Employee/employeedetailBooking.dart';
import 'package:project/provider/authProvider.dart';
import 'package:project/service/firestore.dart';
import 'package:provider/provider.dart';

class employeeHomePage extends StatefulWidget {
  const employeeHomePage({super.key});

  @override
  State<employeeHomePage> createState() => _employeeHomePageState();
}

class _employeeHomePageState extends State<employeeHomePage> {
  List widgetOption = const [Text('home'), EmployeeAccount()];
  FirestoreService firestoreService = FirestoreService();
  DateTime? _selectedDate = DateTime.now();
  int indexBottomNav = 0;
  EasyDatePickerController _controller = EasyDatePickerController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employeeId = Provider.of<idAllAccountProvider>(context).uid;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(170.0), // ปรับขนาดความสูงของ AppBar
        child: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: false,
           backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(30), // ทำให้มุมล่างมน
            ),
          ),
          flexibleSpace: StreamBuilder<QuerySnapshot>(
            stream: firestoreService.getWhereDocIdEmployee(employeeId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator(); // แสดงโหลดข้อมูล
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Text("ไม่พบข้อมูล"); // ถ้าไม่มีข้อมูล
              }

              // ดึงข้อมูลจาก snapshot
              var employeeData =
                  snapshot
                      .data!
                      .docs
                      .first; // เนื่องจากค้นหาตาม docId จะได้แค่เอกสารเดียว

              // ดึงข้อมูลฟิลด์จากเอกสาร
              String imageUrl =
                  employeeData['imageUrl'] ?? ''; // ดึงค่า imageUrl
              String name = employeeData['name'] ?? 'ไม่ระบุชื่อ'; // ดึงชื่อ
              String serviceType =
                  employeeData['serviceType'] ?? 'ไม่มีคำอธิบาย'; // ดึงคำอธิบาย
              String expertiseLevels =
                  employeeData['expertiseLevels'] ?? 'ไม่มีคำอธิบาย'; // ดึงคำอธิบาย

              return Column(
                children: [
                  SizedBox(height: 90),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .start, // จัดเรียงในแนวนอนให้อยู่กลาง
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .center, // จัดเรียงในแนวตั้งให้อยู่กลาง
                      children: [
                        // แสดงข้อมูลที่ดึงมา
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 60,
                          backgroundImage: NetworkImage(imageUrl),
                        ),
                        SizedBox(width: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .center, // จัดข้อความใน Column ให้อยู่กลางในแนวตั้ง
                          children: [
                            Text(
                              name,
                              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                color: Colors.white
                              )
                            ),
                            Text(
                              serviceType,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontSize: 18
                              )
                            ),
                            SizedBox(height:5,),
                            Text(
                         expertiseLevels,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.white54,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body:
      
          indexBottomNav == 0
              ? Container(
                child: Column(
                  children: [
                    EasyDateTimeLinePicker.itemBuilder(
                      controller: _controller,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2030, 3, 18),
                      //focusedDate: DateTime.now(),
                      // selectionMode:SelectionMode.alwaysFirst(),
                      focusedDate: _selectedDate,
                      itemExtent: 75,
                      itemBuilder: (
                        context,
                        date,
                        isSelected,
                        isDisabled,
                        isToday,
                        onTap,
                      ) {
                        String dayOfWeek = DateFormat('EEE', 'en').format(date);
                        String day = date.day.toString();
                        String month = DateFormat(
                          'MMM',
                          'en',
                        ).format(date); // เดือน เช่น "ม.ค.", "ก.พ."
                        return InkResponse(
                          onTap: onTap,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 4, left: 4),
                            child: Container(
                              decoration: BoxDecoration(
                                color:
                                    isSelected
                                        ? Theme.of(context).colorScheme.secondary
                                        : Colors.white,
                                border: Border.all(
                                  color:
                                      isSelected
                                          ? Theme.of(context).colorScheme.secondary
                                          : Colors
                                              .black, // ขอบสีเขียวเมื่อเลือก, สีเทาเมื่อไม่ได้เลือก
                                  width: 1, // กำหนดความหนาของขอบ
                                ),
                                borderRadius: BorderRadius.circular(
                                  12,
                                ), // ทำให้ขอบมน
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    dayOfWeek,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color:
                                          isSelected
                                              ? Colors.white
                                              : Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    day,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color:
                                          isSelected
                                              ? Colors.white
                                              : Colors.black,
                                      fontSize: 18,
                                      fontWeight:
                                          isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                    ),
                                  ),
                                  Text(
                                    month,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color:
                                          isSelected
                                              ? Colors.white
                                              : Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      onDateChange: (date) {
                        setState(() {
                          _selectedDate = date;
                          print(_selectedDate);
                        });
                      },
                      physics: BouncingScrollPhysics(),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Text(
                            'ตารางงาน',
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith()
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:Theme.of(context).colorScheme.secondary,
                              foregroundColor: Colors.blueGrey, // สีของข้อความ
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  12,
                                ), // กำหนดขอบมน
                              ),
                            ),
                            onPressed: () {
                              _controller.animateToDate(DateTime.now());
                              setState(() {
                                _selectedDate = DateTime.now();
                              });
                            },
                            child: Text(
                              'Current date',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.normal,
                                fontSize: 16
                              )
                            ),
                          ),
                        ),
                      ],
                    ),
                    StreamBuilder<QuerySnapshot>(
                      stream: firestoreService.getBookingSelectedDate(
                        _selectedDate,
                        employeeId,
                      ),
                      builder: (context, snapshot) {
                        {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator(); // แสดงโหลดข้อมูล
                          }
                
                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return Text("ไม่มีการจองในวันนึ้"); // ถ้าไม่มีข้อมูล
                          }
                          print(
                            "ข้อมูลที่ได้รับจาก Firestore: ${snapshot.data!.docs.length}",
                          );
                          // ดึงข้อมูลจาก snapshot
                          var employeeData = snapshot.data!.docs;
                          print(
                            "ข้อมูลที่ดึงจาก Firestore: $employeeData",
                          ); // log ข้อมูลที่ดึงมา
                
                          return Expanded(
                            child: ListView.builder(
                              itemCount: employeeData.length,
                              itemBuilder: (context, index) {
                                var data =
                                    employeeData[index].data()
                                        as Map<String, dynamic>;
                                //print('data :$data');
                                var address = data['address'];
                                var date =
                                    data['selectedDate']; // รับข้อมูลจาก Firestore ที่เป็น Timestamp
                                var customerDocId = data['customerDocId'];
                                var historyDocId = data['historyDocId'];
                                DateTime selectedDate =
                                    date.toDate(); // แปลงเป็น DateTime
                
                                // แสดงวันที่ในรูปแบบที่ต้องการ
                                
                                String formattedTime = DateFormat(
                                  'hh:mm:a',
                                ).format(selectedDate);
                
                                print(formattedTime);
                                return InkWell(
                                  onTap: () async {
                                    Navigator.push(context,MaterialPageRoute(builder: (builder)=>EmployeeDetailBooking(customerId: customerDocId,bookingId: historyDocId,address: address,) ));
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 5,
                                    ),
                                    child: SizedBox(
                                      height: 130, // ปรับความสูง
                                      child: Card(
                                       color: Theme.of(context).colorScheme.surface
,
                                         // พื้นหลังสีขาว
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                          side: BorderSide(
                                            color: Colors.black,
                                            width: 2,
                                          ), // ขอบสีดำ
                                        ),
                                        child: Row(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.all(7),
                                              child: Container(
                                                width: 90,
                                                height:
                                                    double
                                                        .infinity, // ให้ Container สูงเท่ากับ Card
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context).colorScheme.secondary,
                                                  borderRadius: BorderRadius.circular(
                                                    20,
                                                    // topLeft: Radius.circular(12),
                                                    // bottomLeft: Radius.circular(12),
                                                  ),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.only(
                                                    top: 12,
                                                  ),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    // crossAxisAlignment: CrossAxisAlignment.start,
                                                    children:
                                                        formattedTime
                                                            .split(":")
                                                            .map(
                                                              (char) => Align(
                                                                alignment:
                                                                    Alignment
                                                                        .bottomLeft,
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets.only(
                                                                        left: 10,
                                                                      ),
                                                                  child: Text(
                                                                    char,
                                                                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                                                      color: Colors.white
                                                                    )
                                                                  ),
                                                                ),
                                                              ),
                                                            )
                                                            .toList(),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Column(
                                                //mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(height: 10),
                                                  StreamBuilder<String>(
                                                    stream: firestoreService
                                                        .getUserNameStream(
                                                          customerDocId,
                                                        ), // Call the function with the docId
                                                    builder: (context, snapshot) {
                                                      if (snapshot
                                                              .connectionState ==
                                                          ConnectionState
                                                              .waiting) {
                                                        return CircularProgressIndicator(); // Show loading indicator while waiting for data
                                                      }
                
                                                      if (snapshot.hasError) {
                                                        return Text(
                                                          'Error: ${snapshot.error}',
                                                        );
                                                      }
                
                                                      if (!snapshot.hasData) {
                                                        return Text(
                                                          'ไม่พบข้อมูล',
                                                        ); // If no data is found
                                                      }
                
                                                      // If data is found, display the username
                                                      return Text(
                                                        'คุณ ${snapshot.data}',
                                                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                                          
                                                        )
                                                      );
                                                    },
                                                  ),
                
                                                  Text(
                                                    'สถานที่ $address',
                                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                      fontWeight: FontWeight.normal
                                                    ),
                                                    maxLines: 3,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              )
              : widgetOption[indexBottomNav],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        selectedItemColor: const Color.fromARGB(255, 230, 237, 191),
        unselectedItemColor: Colors.white,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            backgroundColor:Theme.of(context).bottomNavigationBarTheme.backgroundColor,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Account',
            backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
          ),
        ],
        currentIndex: indexBottomNav,
        onTap: (value) {
          setState(() {
            indexBottomNav = value;
          });
        },
      ),
    );
  }
}
