import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shopping_app/core/service/secure_storage.dart';
import 'package:shopping_app/core/service/dio_client.dart';
import 'package:shopping_app/core/constants/api_constants.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  emailNotVerified,
  error,
}

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ✅ FIX 1: Tambahkan scopes email
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  AuthStatus _status = AuthStatus.initial;
  User? _firebaseUser;
  String? _backendToken;
  String? _errorMessage;
  String? _tempEmail;
  String? _tempPassword;

  AuthStatus get status => _status;
  User? get firebaseUser => _firebaseUser;
  String? get backendToken => _backendToken;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == AuthStatus.loading;

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading();
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _firebaseUser = credential.user;
      await _firebaseUser?.updateDisplayName(name);
      await _firebaseUser?.sendEmailVerification();
      _tempEmail = email;
      _tempPassword = password;
      _status = AuthStatus.emailNotVerified;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_mapFirebaseError(e.code));
      return false;
    } catch (e) {
      debugPrint('Error register: $e');
      _setError('Terjadi kesalahan. Coba lagi.');
      return false;
    }
  }

  Future<bool> loginAfterEmailVerification() async {
    _setLoading();
    try {
      // ✅ FIX 2: Null check sebelum akses _tempEmail & _tempPassword
      if (_tempEmail == null || _tempPassword == null) {
        _setError('Sesi habis. Silakan daftar ulang.');
        return false;
      }

      await _firebaseUser?.reload();
      _firebaseUser = _auth.currentUser;

      if (!(_firebaseUser?.emailVerified ?? false)) {
        _status = AuthStatus.emailNotVerified;
        notifyListeners();
        return false;
      }

      final credential = await _auth.signInWithEmailAndPassword(
        email: _tempEmail!,
        password: _tempPassword!,
      );
      _firebaseUser = credential.user;
      _tempEmail = null;
      _tempPassword = null;

      return await _verifyTokenToBackend();
    } on FirebaseAuthException catch (e) {
      _setError(_mapFirebaseError(e.code));
      return false;
    } catch (e) {
      debugPrint('Error loginAfterEmailVerification: $e');
      _setError('Terjadi kesalahan. Coba lagi.');
      return false;
    }
  }

  Future<bool> _verifyTokenToBackend() async {
    try {
      // ✅ FIX 3: Force refresh token agar selalu valid
      final firebaseToken = await _firebaseUser?.getIdToken(true);
      debugPrint('=== Sending token to backend ===');

      final response = await DioClient.instance.post(
        ApiConstants.verifyToken,
        data: {'firebase_token': firebaseToken},
      );

      debugPrint('=== Backend response: ${response.data} ===');

      final data = response.data['data'] as Map<String, dynamic>;
      final backendToken = data['access_token'] as String;

      await SecureStorageService.saveToken(backendToken);
      _backendToken = backendToken;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('=== Error _verifyTokenToBackend: $e ===');
      _setError('Gagal terhubung ke server. Coba lagi.');
      return false;
    }
  }

  Future<bool> loginWithEmail({
    required String email,
    required String password,
  }) async {
    _setLoading();
    try {
      debugPrint('=== STEP 1: Firebase signIn ===');
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _firebaseUser = credential.user;
      debugPrint(
        '=== STEP 2: emailVerified = ${_firebaseUser?.emailVerified} ===',
      );

      if (!(_firebaseUser?.emailVerified ?? false)) {
        _status = AuthStatus.emailNotVerified;
        notifyListeners();
        return false;
      }

      debugPrint('=== STEP 3: verifyTokenToBackend ===');
      return await _verifyTokenToBackend();
    } on FirebaseAuthException catch (e) {
      debugPrint('=== FirebaseAuthException: ${e.code} ===');
      _setError(_mapFirebaseError(e.code));
      return false;
    } catch (e) {
      debugPrint('=== ERROR loginWithEmail: $e ===');
      _setError('Terjadi kesalahan. Coba lagi.');
      return false;
    }
  }

  Future<bool> loginWithGoogle() async {
    _setLoading();
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User membatalkan login, kembalikan ke unauthenticated (bukan error)
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return false;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCred = await _auth.signInWithCredential(credential);
      _firebaseUser = userCred.user;
      return await _verifyTokenToBackend();
    } on FirebaseAuthException catch (e) {
      // ✅ FIX 4: Handle FirebaseAuthException secara spesifik
      debugPrint('=== FirebaseAuthException Google: ${e.code} ===');
      _setError(_mapFirebaseError(e.code));
      return false;
    } catch (e) {
      // ✅ FIX 4: Tidak expose detail error teknis ke user
      debugPrint('Error loginWithGoogle: $e');
      _setError('Gagal login dengan Google. Coba lagi.');
      return false;
    }
  }

  Future<void> resendVerificationEmail() async {
    try {
      await _firebaseUser?.sendEmailVerification();
    } catch (e) {
      debugPrint('Error resendVerificationEmail: $e');
    }
  }

  Future<bool> checkEmailVerified() async {
    try {
      await _firebaseUser?.reload();
      _firebaseUser = _auth.currentUser;
      if (_firebaseUser?.emailVerified ?? false) {
        return await _verifyTokenToBackend();
      }
      return false;
    } catch (e) {
      debugPrint('Error checkEmailVerified: $e');
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      await SecureStorageService.clearAll();
    } catch (e) {
      debugPrint('Error logout: $e');
    } finally {
      _firebaseUser = null;
      _backendToken = null;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    }
  }

  void _setLoading() {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _status = AuthStatus.error;
    _errorMessage = message;
    notifyListeners();
  }

  String _mapFirebaseError(String code) => switch (code) {
    'email-already-in-use' => 'Email sudah terdaftar. Gunakan email lain.',
    'user-not-found' => 'Akun tidak ditemukan. Silakan daftar.',
    'wrong-password' => 'Password salah. Coba lagi.',
    'invalid-email' => 'Format email tidak valid.',
    'weak-password' => 'Password terlalu lemah. Minimal 6 karakter.',
    'network-request-failed' => 'Tidak ada koneksi internet.',
    'invalid-credential' => 'Email atau password salah.',   // ✅ tambahan
    'too-many-requests' => 'Terlalu banyak percobaan. Coba lagi nanti.', // ✅ tambahan
    'user-disabled' => 'Akun ini telah dinonaktifkan.',    // ✅ tambahan
    _ => 'Terjadi kesalahan. Coba lagi.',
  };
}