import 'package:firebase_auth/firebase_auth.dart';

class CheckTypeLogin {
  final User? user = FirebaseAuth.instance.currentUser;

  bool isLoggedInWithGoogle() {
    return user?.providerData.any((info) => info.providerId == 'google.com') ?? false;
  }
}