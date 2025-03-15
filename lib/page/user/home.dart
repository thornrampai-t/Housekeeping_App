import 'package:flutter/material.dart';
import 'package:project/page/user/Booking.dart';
import 'package:project/page/user/account/account.dart';
import 'package:project/page/user/account/account.dart';
import 'package:project/page/user/search.dart';
import 'package:project/provider/authProvider.dart';
import 'package:project/service/firestore.dart';
import 'package:project/widget/servicebottom.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FirestoreService firestoreService = FirestoreService();
  int indexBottomNav = 0;
  List widgetOption = const [
    Text('home'),
    SearchPage(),
    BookingPage(),
    AccountPage(),
  ];

  late Stream<String> imageStream;

  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<UserProvider>(context).userId;
    print('home $userId');
    imageStream = firestoreService.getImageCustomerStream(userId);
    print(imageStream);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: Text(
          getTitle(indexBottomNav),
          style: TextStyle(color: Colors.white),
        ), // ✅ อัปเดต title ตาม index
        backgroundColor: const Color.fromARGB(255, 25, 98, 47),

        elevation: 4.0,
        shadowColor: Colors.black.withOpacity(1),
      ),
      backgroundColor: Color.fromARGB(255, 243, 247, 222),
      body:
          indexBottomNav == 0
              ? Column(
                children: [
                  Padding(padding: EdgeInsets.only(top: 15)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      height: 150,
                      padding: EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            spreadRadius: 2,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(padding: EdgeInsets.only(left: 10)),
                          StreamBuilder<String>(
                            stream: imageStream, // ใช้ stream ที่เราสร้าง
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return CircularProgressIndicator(); // แสดงขณะรอข้อมูล
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else if (snapshot.hasData) {
                                String imageUrl =
                                    snapshot.data ?? 'ไม่พบข้อมูล';
                                return imageUrl == 'ไม่พบข้อมูล'
                                    ? Text(imageUrl)
                                    : Flexible(
                                      child: Container(
                                        width: 80, // กำหนดขนาดของวงกลม
                                        height: 80.0,
                                        decoration: BoxDecoration(
                                          shape:
                                              BoxShape
                                                  .circle, // ทำให้รูปทรงเป็นวงกลม
                                          image: DecorationImage(
                                            image: NetworkImage(imageUrl),
                                            fit:
                                                BoxFit
                                                    .cover, // ทำให้ภาพครอบคลุมพื้นที่ในวงกลม
                                          ),
                                        ),
                                      ),
                                    );
                              } else {
                                return Text('ไม่พบข้อมูล');
                              }
                            },
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                StreamBuilder<String>(
                                  stream: firestoreService.getuserNameStream(
                                    userId,
                                  ),
                                  builder:
                                      (context, snapshot) => Text(
                                        snapshot.hasData
                                            ? "${snapshot.data}"
                                            : "กำลังโหลด...",

                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                ),
                                Text('Address'),
                                Text('งานล่าสุด'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.only(left: 10),
                    alignment: Alignment.centerLeft,
                    child: Text('Service', style: TextStyle(fontSize: 23)),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      serviceButton(
                        context,
                        'Deep Clean',
                        'assets/icon/clean.png',
                      ),
                      serviceButton(
                        context,
                        'Garden',
                        'assets/icon/can-drop.png',
                      ),
                      serviceButton(
                        context,
                        'Care',
                        'assets/icon/wheelchair.png',
                      ),
                      serviceButton(context, 'Pet', 'assets/icon/pets.png'),
                    ],
                  ),
                ],
              )
              : widgetOption[indexBottomNav],
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: const Color.fromARGB(255, 230, 237, 191),
        unselectedItemColor: Colors.white,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            backgroundColor: const Color.fromARGB(255, 25, 98, 47),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
            backgroundColor: const Color.fromARGB(255, 25, 98, 47),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_rounded),
            label: 'Booking',
            backgroundColor: const Color.fromARGB(255, 25, 98, 47),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Account',
            backgroundColor: const Color.fromARGB(255, 25, 98, 47),
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

  String getTitle(int index) {
    switch (index) {
      case 0:
        return 'Home';
      case 1:
        return 'Search';
      case 2:
        return 'Booking';
      case 3:
        return 'Account';
      default:
        return 'App';
    }
  }
}
