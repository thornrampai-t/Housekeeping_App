import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_arc_text/flutter_arc_text.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:project/Data/customer.dart' show Customer;
import 'package:project/page/user/home.dart';
import 'package:project/page/user/register.dart';
import 'package:project/provider/authProvider.dart';
import 'package:project/service.dart/firestore.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ขาดเงา ตรง curve
class LoginUserPage extends StatefulWidget {
  const LoginUserPage({super.key});

  @override
  State<LoginUserPage> createState() => _LoginUserPageState();
}

class _LoginUserPageState extends State<LoginUserPage> {
  DateTime date = DateTime.now();
  FirestoreService firestoreService =
      FirestoreService(); // สร้าง instance ของ FirestoreService
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _passWordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Stack(
            children: [
              ClipPath(
                clipper: BazierCurve(),
                child: Container(
                  color: const Color.fromARGB(255, 25, 98, 47),
                  height: 400,
                ),
              ),
              Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 360,
                  width: 360,
                ),
              ),
              Positioned(
                top: 140, // ปรับตำแหน่งให้อยู่ด้านบน
                left: 0,
                right: 0,

                child: ArcText(
                  text: 'WELCOME BACK',
                  textStyle: TextStyle(
                    fontSize: 45,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade300,
                    letterSpacing: 5,
                  ),
                  radius: -220, // ขนาดของเส้นวงกลมที่ใช้ในการโค้งข้อความ
                  startAngleAlignment: StartAngleAlignment.center,
                ),
              ),
            ],
          ),
          Form(
            key: _formKey,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 50),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Email',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10, right: 40, left: 40),
                  child: TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: "Please enter your email",
                      border: InputBorder.none, // ไม่มีเส้นขอบ
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(13.0), // ขอบมน
                        borderSide: BorderSide(
                          color: Colors.transparent,
                        ), // ให้เส้นขอบโปร่งใส
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade300,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(13.0), // ขอบมน
                        borderSide: BorderSide(
                          color: Colors.transparent,
                        ), // ให้เส้นขอบโปร่งใส
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an email';
                      } else if (!RegExp(
                        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                      ).hasMatch(value)) {
                        return 'Invalid email format';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.only(left: 50),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Password',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 40, left: 40),
                  child: TextFormField(
                    controller: _passWordController,
                    obscureText: true, // ซ่อนข้อความเมื่อพิมพ์
                    decoration: InputDecoration(
                      hintText: "Please enter your password",
                      border: InputBorder.none, // ไม่มีเส้นขอบ
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(13.0), // ขอบมน
                        borderSide: BorderSide(
                          color: Colors.transparent,
                        ), // ให้เส้นขอบโปร่งใส
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade300,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(13.0), // ขอบมน
                        borderSide: BorderSide(
                          color: Colors.transparent,
                        ), // ให้เส้นขอบโปร่งใส
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null; // ถ้าผ่านการตรวจสอบ ให้คืนค่า null
                    },
                  ),
                ),
                SizedBox(height: 1),
                Padding(
                  padding: const EdgeInsets.only(right: 25),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {},
                      child: Text(
                        'Forget password',
                        style: TextStyle(color: Colors.lightBlue[900]),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      var email = _emailController.text;
                      var password = _passWordController.text;
                      var uid = login(email, password);

                      if (uid == null) {
                        print('No uid');
                      } else {
                        // ใช้ StreamBuilder เพื่อดึง userId จาก snapshot
                        Stream<String> userIdStream = firestoreService
                            .getWhereUserIdStream(email);

                        print('useridSterm: $userIdStream');
                        userIdStream.listen((userId) {
                          var userProvider = Provider.of<UserProvider>(
                            context,
                            listen: false,
                          );
                          userProvider.setUserId(userId);

                          // นำทางไปยัง HomePage
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (builder) => HomePage()),
                          );
                        });
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 25, 98, 47),
                    minimumSize: Size(270, 60),
                  ),
                  child: Text(
                    'Login',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(right: 57, left: 57),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      minimumSize: Size(200, 60),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: BorderSide(color: Colors.black, width: 1),
                      ),
                    ),
                    onPressed: signInWithGoogle,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Image.asset(
                          'assets/images/googleicon.png',
                          height: 30,
                          width: 30,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Sing in with Google',
                          style: TextStyle(fontSize: 20, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: EdgeInsets.only(left: 65),
                  child: Row(
                    children: [
                      Text('Don’t have any account ?'),
                      SizedBox(width: 5),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (builder) => RegisterPage(),
                            ),
                          );
                        },
                        child: Text(
                          'Register Now',
                          style: TextStyle(color: Colors.lightBlue[900]),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        return null; // ผู้ใช้กดยกเลิกการล็อกอิน
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);

      String userEmail = googleUser.email;

      String userId = DateFormat('yyyyMMddHHmmss').format(DateTime.now());
      String userName = googleUser.displayName ?? '';
      String userPhoto =
          'https://static.vecteezy.com/system/resources/previews/019/879/186/non_2x/user-icon-on-transparent-background-free-png.png';

      final userRef = FirebaseFirestore.instance
          .collection('Customer')
          .doc(userEmail);
      final userDoc = await userRef.get();

      var userProvider = Provider.of<UserProvider>(context, listen: false);

      if (!userDoc.exists) {
        // สร้างเอกสารใหม่ใน Firestore ถ้ายังไม่มีข้อมูลผู้ใช้
        Customer newCustomer = Customer(
          userId: userId,
          name: userName,
          phoneNumber: '',
          email: userEmail,
          password: '',
          typeacc: 'customer',
          addresses: [],
          photo: userPhoto,
          bookingHistory: [],
        );

        await userRef.set({
          'userId': newCustomer.userId,
          'userName': newCustomer.name,
          'phoneNum': '',
          'userEmail': newCustomer.email,
          'userPassword': newCustomer.email,
          'userPhoto': newCustomer.photo,
          'typeacc': newCustomer.typeacc,
          'addresses': newCustomer.addresses,
          'bookingHistory': newCustomer.bookingHistory,
        });

        // บันทึก userId ใหม่ให้ Provider (เพราะเป็นการสมัครใหม่)
        userProvider.setUserId(userId);
      } else {
        print('userEmail :$userEmail');
        Stream<String> userIdStream = firestoreService.getWhereUserIdStream(
          userEmail,
        );
        print('userIdstream :$userIdStream');

        userIdStream.listen((userId) {
          print('userEmail :$userEmail');
          print('userId: $userId');
          userProvider.setUserId(userId);
        });
      }

      if (userCredential.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      }

      return userCredential.user;
    } catch (e) {
      print('Error during Google sign in: $e');
      return null;
    }
  }
}

Future<String?> login(String email, String password) async {
  try {
    final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    return credential.user?.uid;
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      print('No user found for that email');
    } else if (e.code == 'worng-password') {
      print('Wrong passowrd provided for that user');
    }
  }
}

class BazierCurve extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, size.height * 0.68); // เริ่มต้นจากมุมซ้าย

    // ส่วนโค้งเว้า (หลุม)
    path.quadraticBezierTo(
      size.width * 0.5, // จุดควบคุมให้อยู่กลางเส้น
      size.height * 1.1, // จุดควบคุมต่ำกว่าปกติ ทำให้เกิดหลุม
      size.width,
      size.height * 0.68,
    );
    path.lineTo(size.width, size.height * 0.68); // ข้างขวาสูงเท่ากับข้างซ้าย
    path.lineTo(size.width, 0); // ปิดเส้นขอบบน
    path.lineTo(0, 0); // ปิดเส้นขอบบนฝั่งซ้าย

    // path.lineTo(size.width, 0);

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldCliper) {
    return true;
  }
}
