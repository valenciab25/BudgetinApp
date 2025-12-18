import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ---------------- GOOGLE SIGN IN ----------------
  Future<User?> signInWithGoogle() async {
    try {
      // 1. GoogleSignIn instance
      final googleSignIn = GoogleSignIn(
        scopes: ['email'],
      );

      // 2. Pilih akun
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null;

      // 3. Ambil authentication (ACCESS TOKEN + ID TOKEN)
      final googleAuth = await googleUser.authentication;

      // 4. Buat credential Firebase
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      // 5. Login ke Firebase
      final userCredential =
      await _auth.signInWithCredential(credential);

      return userCredential.user;
    } catch (e) {
      print("GOOGLE SIGN IN ERROR: $e");
      return null;
    }
  }

  // ---------------- EMAIL LOGIN ----------------
  Future<User?> loginEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      print("EMAIL LOGIN ERROR: $e");
      rethrow;
    }
  }

  // ---------------- EMAIL REGISTER ----------------
  Future<User?> registerEmail(String email, String password) async {
    try {
      final credential =
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      print("EMAIL REGISTER ERROR: $e");
      rethrow;
    }
  }

  // ---------------- LOGOUT ----------------
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await GoogleSignIn().signOut();
    } catch (e) {
      print("SIGN OUT ERROR: $e");
    }
  }
}
