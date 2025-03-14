import 'package:flutter/material.dart';
import 'package:project/function/checktypelogin.dart';
import 'package:project/provider/authProvider.dart';
import 'package:project/service.dart/firestore.dart';
import 'package:provider/provider.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _passWordController = TextEditingController();
  final CheckTypeLogin checkTypeLogin = CheckTypeLogin();
  FirestoreService firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<UserProvider>(context).userId;
    bool isGoogleLogin = checkTypeLogin.isLoggedInWithGoogle(); // เรียกใช้งาน
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 243, 247, 222),
      body: Column(
        children: [
          SizedBox(height: 70),
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
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: TextFormField(
              controller: _passWordController,
              decoration: InputDecoration(
                hintText: "Enter your New Password",
                border: InputBorder.none,

                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(13.0),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(13.0),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(13.0),
                ),
              ),
              enabled: !isGoogleLogin,
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: Size(300, 50),
              backgroundColor: Color.fromARGB(255, 25, 98, 47),
            ),
            onPressed: () async {
              String newPassword = _passWordController.text;

              print("🟡 Updating password...");

              await firestoreService.updatPasswordCustomer(userId, newPassword);

              Navigator.pop(context);
              print("✅ Successfully navigated back!");
            },

            child: Text(
              'Save Change',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }
}
