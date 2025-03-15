import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project/function/checktypelogin.dart';
import 'package:project/function/updateimage.dart';
import 'package:project/page/user/account/account.dart';
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
  final UpdateImage updateImage = UpdateImage();
  XFile? _selectedImage;

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneNoController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final CheckTypeLogin checkTypeLogin = CheckTypeLogin();

  @override
  Widget build(BuildContext context) {
    bool isGoogleLogin = checkTypeLogin.isLoggedInWithGoogle();
    final userId = Provider.of<UserProvider>(context).userId;
    var imageStream = firestoreService.getImageCustomerStream(userId);
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 243, 247, 222),
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
                      width: 50.0, // กำหนดขนาดของวงกลม
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
                  child: StreamBuilder<String>(
                    stream: imageStream, // ใช้ stream ที่เราสร้าง
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator(); // แสดงขณะรอข้อมูล
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (snapshot.hasData) {
                        String imageUrl = snapshot.data ?? 'ไม่พบข้อมูล';
                        return imageUrl == 'ไม่พบข้อมูล'
                            ? Text(imageUrl)
                            : Container(
                              width: 120, // กำหนดขนาดของวงกลม
                              height: 120.0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  15,
                                ), // ทำให้รูปทรงเป็นวงกลม
                                image: DecorationImage(
                                  image: NetworkImage(imageUrl),
                                  fit:
                                      BoxFit
                                          .cover, // ทำให้ภาพครอบคลุมพื้นที่ในวงกลม
                                ),
                              ),
                            ); // แสดงรูปภาพหากมี URL
                      } else {
                        return Text('ไม่พบข้อมูล');
                      }
                    },
                  ),
                ),
                Positioned(
                  left: 80,
                  top: 80,
                  child: GestureDetector(
                    onTap: () {
                      // Call onProfileTapped() when the user taps
                      updateImage.onProfileTapped();
                    },
                    child: Container(
                      width: 40.0, // กำหนดขนาดของวงกลม
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
                    decoration: InputDecoration(
                      hintText: "Enter your Phone number",
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
                      // หากค่า value ว่าง ไม่ต้องตรวจสอบอะไร
                      if (value == null || value.isEmpty) {
                        return null; // ถ้าเป็นค่า null หรือว่าง ไม่ต้องทำการตรวจสอบ
                      }

                      // รูปแบบเบอร์โทร (เบอร์โทรไทยที่เริ่มด้วย 0 และตามด้วย 9 หลัก)
                      String phonePattern = r'^[0]{1}[1-9]{1}[0-9]{8}$';
                      RegExp regExp = RegExp(phonePattern);

                      // ตรวจสอบเบอร์โทร
                      if (!regExp.hasMatch(value)) {
                        return 'Please enter a valid phone number';
                      }

                      return null; // ไม่มีข้อผิดพลาด
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

                      await firestoreService.updateFullNameCustomer(
                        context,
                        userId,
                        newUserName,
                      );

                      await firestoreService.updatePhoneNumCustomer(
                        userId,
                        newPhoneNum,
                      );
                      // หลังจากเคลียร์ฟอร์มแล้ว ให้ทำการ Navigating กลับ
                      print("Navigating back...");
                      Navigator.pop(context);
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
