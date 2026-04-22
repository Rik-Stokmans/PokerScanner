import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;
  static final _db = FirebaseFirestore.instance;

  static User? get currentUser => _auth.currentUser;
  static String? get currentUid => _auth.currentUser?.uid;

  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  static Future<UserModel> signIn(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await _db.collection('users').doc(cred.user!.uid).update({'status': 'online'});
    final doc = await _db.collection('users').doc(cred.user!.uid).get();
    return UserModel.fromMap(cred.user!.uid, doc.data()!);
  }

  static Future<UserModel> register(
      String username, String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = UserModel(
      id: cred.user!.uid,
      username: username.trim(),
      email: email.trim(),
      status: 'online',
      createdAt: DateTime.now(),
    );
    await _db.collection('users').doc(cred.user!.uid).set(user.toMap());
    return user;
  }

  static Future<void> signOut() async {
    final uid = currentUid;
    if (uid != null) {
      await _db.collection('users').doc(uid).update({
        'status': 'offline',
        'currentGameId': null,
      });
    }
    await _auth.signOut();
  }
}
