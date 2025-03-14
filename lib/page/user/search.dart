import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/page/user/employee.dart';
import 'package:project/service.dart/firestore.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController searchController = TextEditingController();
  final FirestoreService firestoreService = FirestoreService();
  String searchQuery = '';

  // ฟังก์ชันค้นหาข้อมูลจาก Firestore
  Stream<QuerySnapshot> searchEmployee(String query) {
    if (query.isEmpty) {
      return firestoreService.getEmployee(); // ถ้าไม่มีคำค้น ก็ดึงข้อมูลทั้งหมด
    } else {
      return firestoreService.searchEmployee(query); // ฟังก์ชันค้นหาจากคำค้น
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 243, 247, 222),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SearchBar(
              controller: searchController,
              hintText: 'Search',
              leading: Icon(Icons.search),
              onChanged: (value) {
                setState(() {
                  searchQuery = value; // อัปเดตคำค้น
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: searchEmployee(
                searchQuery,
              ), // ดึงข้อมูลจาก Firestore ตามคำค้น
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                var employees = snapshot.data!.docs;

                if (employees.isEmpty) {
                  return Center(child: Text("No results found"));
                }

                return ListView.builder(
                  itemCount: employees.length,
                  itemBuilder: (context, index) {
                    var doc = employees[index];
                    String image = doc['photo'];
                    String name = doc['name'] ?? 'Unknown';
                    String type = doc['position'] ?? '';

                    return InkWell(
                      onTap: () {
                        // เมื่อคลิกที่รายการให้ไปที่หน้า EmployeePage
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => EmployeePage(
                                  name: name,
                                  image: image,
                                  type: type,
                                ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(top: 25),
                        child: Center(
                          child: SizedBox(
                            height: 300,
                            width: 300,
                            child: Card(
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: Row(
                                        children: [
                                          Icon(Icons.star, color: Colors.amber),
                                          SizedBox(width: 4),
                                          Text(
                                            '5 star', // ปรับตามข้อมูลจริง
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    CircleAvatar(
                                      backgroundColor: Colors.grey,
                                      radius: 70,
                                      backgroundImage: NetworkImage(image),
                                    ),
                                    SizedBox(height: 15),
                                    Text(
                                      name,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 15),
                                    Text(
                                      type,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
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
