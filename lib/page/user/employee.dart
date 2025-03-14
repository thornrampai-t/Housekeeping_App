import 'package:flutter/material.dart';
import 'package:project/page/user/map.dart';
import 'package:project/provider/authProvider.dart';
import 'package:provider/provider.dart';

class EmployeePage extends StatelessWidget {
  String name;
  String image;
  String type;
  EmployeePage({
    super.key,
    required this.name,
    required this.image,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 243, 247, 222),
      body: Column(
        children: [
          Stack(
            children: [
              Container(
                padding: EdgeInsets.only(top: 80, left: 70),
                child: Image.network(image, height: 250, width: 250),
              ),

              Container(
                padding: EdgeInsets.only(top: 50, left: 8),
                child: Align(
                  alignment: Alignment.topLeft,

                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.arrow_back_ios_new, color: Colors.black),
                  ),
                ),
              ),
            ],
          ),

          Divider(
            color: Colors.black, // สีของเส้น
            thickness: 1, // ความหนาของเส้น
          ),
          SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Align(
              alignment: Alignment.centerLeft,

              child: Text(type, style: TextStyle(fontSize: 20)),
            ),
          ),
          SizedBox(height: 5),
          Row(
            children: [
              SizedBox(width: 20),
              Container(
                width:
                    90, // ควรกำหนดให้เป็นค่าที่ต้องการ (เท่ากับ 2 เท่าของ radius ที่ใช้ใน CircleAvatar)
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle, // ทำให้ Container เป็นวงกลม
                  color: Colors.grey, // สีพื้นหลัง
                ),
                child: ClipOval(
                  child: Image.network(
                    image,
                    fit: BoxFit.cover, // ให้รูปเต็มพื้นที่วงกลม
                  ),
                ),
              ),

              SizedBox(width: 30),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: TextStyle(fontSize: 18)),
                  Icon(Icons.star),
                ],
              ),
              SizedBox(width: 5),
              Spacer(), // ใช้ Spacer เพื่อผลักดันปุ่มไปที่ขวาสุด
              ElevatedButton(
                onPressed: () {
                 var customerProvider = Provider.of<empolyeeProvider>(context, listen: false); // Set listen: false to avoid rebuilding the widget unnecessarily
                  customerProvider.setempolyeeName(name);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MapPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[300],
                  shape: CircleBorder(),
                  padding: EdgeInsets.all(5),
                ),
                child: Image.asset('assets/icon/booking.png', width: 20),
              ),
              SizedBox(width: 10),
            ],
          ),
        ],
      ),
    );
  }
}
