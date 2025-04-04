import 'package:firebase_auth/firebase_auth.dart';

class APIs {
  static FirebaseAuth auth = FirebaseAuth.instance;

  // Check if user is signed in
  static User? get user => auth.currentUser;
}
