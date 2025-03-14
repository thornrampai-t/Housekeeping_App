import 'package:flutter/material.dart';
import 'package:project/page/user/account/mapbookmark.dart';

class AddLocationPage extends StatefulWidget {
  const AddLocationPage({super.key});

  @override
  State<AddLocationPage> createState() => _AddLocationPageState();
}

class _AddLocationPageState extends State<AddLocationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('บันทึกสถานที่โปรดของคุณ')),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.home),
            title: Text('เพิ่มบ้าน'),
            onTap: () {
              // เพิ่มการทำงานเมื่อเลือกเพิ่มบ้าน
            },
          ),
          ListTile(
            leading: Icon(Icons.work),
            title: Text('เพิ่มที่ทำงาน'),
            onTap: () {
              // เพิ่มการทำงานเมื่อเลือกเพิ่มที่ทำงาน
            },
          ),
          ListTile(
            leading: Icon(Icons.add),
            title: Text('เพิ่มใหม่'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (builder) => MapBookMark()),
              );
            },
          ),
        ],
      ),
    );
  }
}
