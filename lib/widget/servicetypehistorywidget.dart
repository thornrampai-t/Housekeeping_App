import 'package:flutter/material.dart';

Widget getServiceTypeWidget(String position) {
  if (position == 'แม่บ้าน') {
    return Container(
      width: 65, // กำหนดขนาดความกว้าง
      height: 65, // กำหนดขนาดความสูง
      decoration: BoxDecoration(
        color: Colors.green, // สีพื้นหลัง
        shape: BoxShape.circle, // ทำให้เป็นวงกลม
      ),
      child: Center(child: Image.asset('assets/icon/clean.png',height: 40)),
    );
  } else if (position == 'คนสวน') {
    return Container(
      width: 65, // กำหนดขนาดความกว้าง
      height: 65, // กำหนดขนาดความสูง
      decoration: BoxDecoration(
        color: Colors.green, // สีพื้นหลัง
        shape: BoxShape.circle, // ทำให้เป็นวงกลม
      ),
      child: Center(child: Image.asset('assets/icon/can-drop.png',height: 40)),
    );
  } else if (position == 'ดูแลผู้สูงอายุ') {
    return Container(
      width: 65, // กำหนดขนาดความกว้าง
      height: 65, // กำหนดขนาดความสูง
      decoration: BoxDecoration(
        color: Colors.green, // สีพื้นหลัง
        shape: BoxShape.circle, // ทำให้เป็นวงกลม
      ),
      child: Center(child: Image.asset('assets/icon/Wheelchair.png',height: 40)),
    );
  } else if (position == 'ดูแลสัตว์') {
    return Container(
      width: 65, // กำหนดขนาดความกว้าง
      height: 65, // กำหนดขนาดความสูง
      decoration: BoxDecoration(
        color: Colors.green, // สีพื้นหลัง
        shape: BoxShape.circle, // ทำให้เป็นวงกลม
      ),
      child: Center(child: Image.asset('assets/icon/pets.png',height: 40)),
    );
  } else {
    return Text('ไม่พบข้อมูล');
  }
}
