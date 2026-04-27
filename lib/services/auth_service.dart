import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Login dengan email & password.
  /// Melempar [FirebaseAuthException] jika gagal.
  static Future<UserCredential> login(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Daftar akun baru dengan email & password.
  /// Melempar [FirebaseAuthException] jika gagal.
  static Future<UserCredential> register(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Logout dari Firebase.
  static Future<void> logout() async {
    await _auth.signOut();
  }

  /// Mendapatkan user yang sedang login (null jika belum login).
  static User? getCurrentUser() {
    return _auth.currentUser;
  }

  /// Stream status autentikasi (berguna untuk auth gate).
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Konversi kode error Firebase ke pesan bahasa Indonesia.
  static String getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Email tidak terdaftar.';
      case 'wrong-password':
        return 'Password salah.';
      case 'invalid-credential':
        return 'Email atau password salah.';
      case 'email-already-in-use':
        return 'Email sudah digunakan akun lain.';
      case 'weak-password':
        return 'Password terlalu lemah (minimal 6 karakter).';
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan login. Coba lagi nanti.';
      default:
        return 'Terjadi kesalahan: ${e.message}';
    }
  }
}
