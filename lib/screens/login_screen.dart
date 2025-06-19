import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isSigningIn = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('로그인')),
      body: Center(
        child: _isSigningIn
            ? const CircularProgressIndicator()
            : Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.login),
              label: const Text('Google로 로그인'),
              onPressed: _signInWithGoogle,
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isSigningIn = true;
      _errorMessage = null;
    });

    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() => _isSigningIn = false);
        return;
      }

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user!;
      final uid = user.uid;

      final userDoc = FirebaseFirestore.instance.collection('users_data').doc(uid);
      final snapshot = await _safeGetUserDoc(userDoc);

      if (!snapshot.exists) {
        await userDoc.set({
          'uid': uid,
          'email': user.email,
          'displayName': user.displayName ?? user.email,
          'photoURL': user.photoURL,
          'statusMessage': '',
          'targetLang': 'en',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      debugPrint('로그인 오류: $e');
      setState(() {
        _errorMessage = '로그인에 실패했습니다.\n네트워크 상태를 확인해주세요.';
      });
    } finally {
      setState(() => _isSigningIn = false);
    }
  }

  Future<DocumentSnapshot> _safeGetUserDoc(DocumentReference ref) async {
    int retry = 0;
    while (retry < 3) {
      try {
        return await ref.get();
      } catch (e) {
        await Future.delayed(Duration(milliseconds: 500 * (retry + 1)));
        retry++;
      }
    }
    throw Exception('Firestore 연결 실패');
  }
}
