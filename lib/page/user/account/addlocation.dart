import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/page/user/account/mapbookmark.dart';
import 'package:project/provider/authProvider.dart';
import 'package:project/service/firestore.dart';
import 'package:provider/provider.dart';

class AddLocationPage extends StatefulWidget {
  const AddLocationPage({super.key});

  @override
  State<AddLocationPage> createState() => _AddLocationPageState();
}

class _AddLocationPageState extends State<AddLocationPage> {
  final FirestoreService firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          'บันทึกสถานที่โปรดของคุณ',
          style: TextStyle(color: Colors.white),
        ), // ✅ อัปเดต title ตาม index
        backgroundColor: const Color.fromARGB(255, 25, 98, 47),

        elevation: 4.0,
        shadowColor: Colors.black.withOpacity(1),
      ),
      backgroundColor: Color.fromARGB(255, 243, 247, 222),
      body: StreamBuilder(
        stream: firestoreService.getHistoryandBookmarkCustomerStream(
          Provider.of<UserProvider>(context, listen: false).userId,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("ไม่มีข้อมูลสถานที่ที่บันทึกไว้"));
          }

          var docs = snapshot.data!.docs;

          return ListView.builder(
            
            padding: EdgeInsets.only(bottom: 4),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var data = docs[index].data() as Map<String, dynamic>;

              // ตรวจสอบว่ามีข้อมูล addresses หรือไม่
              List bookMarks = (data['addresses'] as List?) ?? [];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 5),

                  ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap:
                        true, // ให้ ListView.builder ด้านในทำงานได้โดยไม่ต้องใช้ Expanded
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: bookMarks.length,
                    itemBuilder: (context, i) {
                      var bookMarkItem = bookMarks[i] as Map<String, dynamic>;
                      String namePosition =
                          bookMarkItem['name'] ?? "ไม่มีชื่อสถานที่";
                      String nameAddress =
                          bookMarkItem['address'] ?? "ไม่มีที่อยู่";

                      return ListTile(
                        title: Text(namePosition),
                        subtitle: Text(nameAddress),
                        leading: Icon(Icons.location_on, color: Color.fromARGB(255, 25, 98, 47)),
                      );
                    },
                  ),

                  Divider(), 

                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (builder) => MapBookMark()),
                      );
                    },
                    child: ListTile(
                      title: Text('เพิ่มตำแหน่ง'),
                      leading: Icon(Icons.add),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
