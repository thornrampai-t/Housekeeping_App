import 'package:flutter/material.dart';

Widget getServiceTypeWidget(String position) {
  if (position == 'Deep Clean') {
    return Container(
      width: 65, // กำหนดขนาดความกว้าง
      height: 65, // กำหนดขนาดความสูง
      decoration: BoxDecoration(
        color: Colors.green, // สีพื้นหลัง
        shape: BoxShape.circle, // ทำให้เป็นวงกลม
      ),
      child: Center(child: Image.asset('assets/icon/clean.png',height: 40)),
    );
  } else if (position == 'Garden') {
    return Container(
      width: 65, // กำหนดขนาดความกว้าง
      height: 65, // กำหนดขนาดความสูง
      decoration: BoxDecoration(
        color: Colors.green, // สีพื้นหลัง
        shape: BoxShape.circle, // ทำให้เป็นวงกลม
      ),
      child: Center(child: Image.asset('assets/icon/can-drop.png',height: 40)),
    );
  } else if (position == 'Care') {
    return Container(
      width: 65, // กำหนดขนาดความกว้าง
      height: 65, // กำหนดขนาดความสูง
      decoration: BoxDecoration(
        color: Colors.green, // สีพื้นหลัง
        shape: BoxShape.circle, // ทำให้เป็นวงกลม
      ),
      child: Center(child: Image.asset('assets/icon/Wheelchair.png',height: 40)),
    );
  } else if (position == 'Pet') {
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
