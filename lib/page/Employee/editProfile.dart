import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project/provider/authProvider.dart';
import 'package:project/service/firestore.dart';
import 'package:provider/provider.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late Stream<String> imageStream;
  FirestoreService firestoreService = FirestoreService();
  bool isPasswordUpdated = false; // ตัวแปรบ่งชี้สถานะการอัปเดตพาสเวิร์ด
  bool isError = false; // ตัวแปรบ่งชี้หากเกิดข้อผิดพลาด

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneNoController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String userName = "";
  String phoneNum = "";
  File? _image;
  String? _fileName;
  bool _isLoading = false; // ใช้เพื่อแสดงสถานะการโหลดข้อมูล
  final ImagePicker _picker = ImagePicker();
  String _imageUrl = ''; // ตัวแปรเก็บ URL ของภาพ

  // ฟังก์ชันเลือกภาพจากโทรศัพท์
  Future<void> _pickImage() async {
    final XFile? picture = await _picker.pickImage(source: ImageSource.gallery);
    if (picture != null) {
      File imageFile = File(picture.path);
      print("File size: ${imageFile.lengthSync()} bytes");

      setState(() {
        _image = imageFile;
        _isLoading = true; // กำหนดสถานะเป็นกำลังโหลดเมื่อเริ่มการอัปโหลด
      });
    }
  }

  Future<void> _uploadImageToFirebase(String userId, File imageFile) async {
    try {
      print('userID: $userId');

      // สร้างชื่อไฟล์ใหม่ที่ไม่ซ้ำกัน
      String fileName = '${userId}.png';

      // สร้างการอ้างอิงไปยัง Firebase Storage
      Reference storageRef = FirebaseStorage.instance.ref().child(
        'employee/profile/$fileName',
      );

      // อัปโหลดไฟล์
      await storageRef.putFile(imageFile);
      print('fileName:$fileName');
      String downloadUrl = await storageRef.getDownloadURL();
      // อัปเดต Firestore ด้วย URL ของไฟล์
      await FirebaseFirestore.instance
          .collection('Employee')
          .doc(userId)
          .update({'imageUrl': downloadUrl});

      setState(() {
        _imageUrl = fileName;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("Error uploading image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final employeeId = Provider.of<idAllAccountProvider>(context).uid;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Column(
        children: [
          SizedBox(height: 70),
          Row(
            children: [
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 50.0,
                      height: 50.0,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 25, 98, 47),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.chevron_left_rounded,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 60),
              Text(
                'Edit Profile',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 15),
          Align(
            alignment: Alignment.center,
            child: Stack(
              children: [
                Container(
                  child: StreamBuilder<QuerySnapshot>(
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

                      return _image == null
                          ? ClipOval(
                            child: Container(
                              width: 130,
                              height: 130.0,
                              decoration: BoxDecoration(
                              color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(15),
                                image: DecorationImage(
                                  image: NetworkImage(
                                    imageUrl,
                                  ), // ใช้ imageUrl จาก Firestore
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          )
                          : ClipOval(
                            child: Container(
                              width: 120,
                              height: 120.0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                image: DecorationImage(
                                  image: FileImage(
                                    _image!,
                                  ), // ใช้ _image ที่ผู้ใช้เลือก
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                    },
                  ),
                ),
                Positioned(
                  left: 80,
                  top: 90,
                  child: GestureDetector(
                    onTap: _pickImage, // เรียกใช้ฟังก์ชัน pickImage เมื่อคลิก
                    child: Container(
                      width: 40.0,
                      height: 40.0,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 25, 98, 47),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.edit, size: 23, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20),
          Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextFormField(
                    controller: _fullNameController,
                    decoration: InputDecoration(
                      hintText: "Enter your Full name",
                      hintStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.black
                    ),
                      border: InputBorder.none,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(13.0),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(13.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextFormField(
                    controller: _phoneNoController,
                    inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly, // รับเฉพาะตัวเลข
                    LengthLimitingTextInputFormatter(10),  // จำกัดให้กรอกได้แค่ 10 ตัว
                  ],
                    decoration: InputDecoration(
                      hintText: "Enter your Phone number",
                      hintStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.black
                    ),
                      border: InputBorder.none,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(13.0),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(13.0),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return null;
                      }

                      String phonePattern = r'^[0]{1}[1-9]{1}[0-9]{8}$';
                      RegExp regExp = RegExp(phonePattern);

                      if (!regExp.hasMatch(value)) {
                        return 'Please enter a valid phone number';
                      }

                      return null;
                    },
                  ),
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(300, 50),
                    backgroundColor: Color.fromARGB(255, 25, 98, 47),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState?.validate() ?? false) {
                      print("Updating user data...");
                      String newUserName = _fullNameController.text;
                      String newPhoneNum = _phoneNoController.text;

                      print('newuser: $newUserName');
                      print('newphone: $newPhoneNum');

                      try {
                        bool shouldUpdateName =
                            newUserName !=
                            userName; // เช็คว่า ชื่อใหม่ไม่เหมือนเดิม
                        bool shouldUpdatePhone =
                            newPhoneNum.isNotEmpty &&
                            newPhoneNum !=
                                phoneNum; // เช็คว่า เบอร์โทรใหม่ไม่ว่างและไม่เหมือนเดิม

                        // อัปเดตชื่อผู้ใช้ถ้าจำเป็น
                        if (shouldUpdateName) {
                          await firestoreService.updateFullNameEmployee(
                            employeeId,
                            newUserName,
                          );
                        }

                        // อัปเดตเบอร์โทรถ้าจำเป็น
                        if (shouldUpdatePhone) {
                          await firestoreService.updatePhoneNumEmployee(
                            employeeId,
                            newPhoneNum,
                          );
                        }

                        if (_image != null) {
                          print('image: $_image');
                          await _uploadImageToFirebase(employeeId, _image!);
                        }

                        // ใช้ setState() อัปเดต UI
                        setState(() {
                          if (shouldUpdateName) userName = newUserName;
                          if (shouldUpdatePhone) phoneNum = newPhoneNum;
                        });

                        // ปิดหน้า Dialog หรือ Pop-up
                        if (mounted) {
                          // ตรวจสอบว่า widget ยังอยู่ใน tree
                          Navigator.pop(context);
                        }
                      } catch (e) {
                        print("❌ เกิดข้อผิดพลาด: $e");
                      }
                    }
                  },

                  child: Text(
                    'Save Change',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                // การแสดงข้อความสถานะของพาสเวิร์ด
                if (isPasswordUpdated)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Password updated successfully!',
                      style: TextStyle(color: Colors.green, fontSize: 16),
                    ),
                  ),
                if (isError)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Failed to update password. Please try again.',
                      style: TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
