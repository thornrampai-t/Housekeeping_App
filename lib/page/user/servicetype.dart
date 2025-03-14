import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/page/user/employee.dart';
import 'package:project/service.dart/firestore.dart';

class ServicePage extends StatefulWidget {
  final String selectPosition;

  ServicePage({super.key, required this.selectPosition});

  @override
  State<ServicePage> createState() => _ServicePageState();
}

class _ServicePageState extends State<ServicePage> {
  final TextEditingController searchController = TextEditingController();
  final FirestoreService firestoreService =
      FirestoreService(); // ✅ สร้าง instance ของ FirestoreService
  String searchQuery = '';

  Stream<QuerySnapshot> getEmployeesStream() {
    switch (widget.selectPosition) {
      case 'Deep Clean':
        return firestoreService.getWhereDeepCleanStream();
      case 'Garden':
        return firestoreService.getWhereGardenStream();
      case 'Care':
        return firestoreService.getWhereCareStream();
      case 'Pet':
        return firestoreService.getWherePetStream();
      default:
        return Stream.empty(); // ถ้าไม่ตรงกับตำแหน่งที่กำหนด ให้ส่งค่าเป็น Stream ว่าง
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.selectPosition)),
      backgroundColor: Color.fromARGB(255, 243, 247, 222),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          children: [
            SizedBox(height: 5),
            SearchBar(
             controller:  searchController,
              hintText: 'Search',
              leading: Icon(Icons.search),
              onChanged: (value) {
                setState(() {
                  searchQuery = value; // อัปเดตคำค้น
                });
              },
            ),
            SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: getEmployeesStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text("No employees found"));
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var doc = snapshot.data!.docs[index];
                      String image = doc['photo'];
                      String name = doc['name'] ?? 'Unknown';
                      String type = doc['position'] ?? '';

                      return InkWell(
                        onTap: () {
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
                                            Icon(
                                              Icons.star,
                                              color: Colors.amber,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              '5 star',
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
      ),
    );
  }
}
