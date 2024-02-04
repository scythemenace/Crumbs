import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class Auth{
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> createUserWithEmailAndPassword({
  required String name,
  required String email,
  required String password,
}) async {
  try {
    await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Store user data in Firebase Firestore or Realtime Database
    await FirebaseFirestore.instance.collection('users').doc(_firebaseAuth.currentUser!.uid).set({
      'name': name,
      'email': email,
    });
  } catch (e) {
    // Handle errors
    print(e.toString());
  }
}

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}