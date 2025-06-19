import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddFriendScreen extends StatefulWidget {
  const AddFriendScreen({super.key});

  @override
  State<AddFriendScreen> createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  final TextEditingController _emailController = TextEditingController();
  String? _searchResult;
  String? _searchUid;
  bool _isSearching = false;
  final user = FirebaseAuth.instance.currentUser!;

  Future<void> _searchUser() async {
    setState(() {
      _isSearching = true;
      _searchResult = null;
      _searchUid = null;
    });

    final email = _emailController.text.trim();

    try {
      final result = await FirebaseFirestore.instance
          .collection('users_data')
          .where('email', isEqualTo: email)
          .get();

      if (result.docs.isEmpty || result.docs.first.id == user.uid) {
        _searchResult = '사용자를 찾을 수 없거나 본인입니다.';
      } else {
        final data = result.docs.first.data();
        _searchResult = '${data['displayName']} (${data['email']})';
        _searchUid = result.docs.first.id;
      }
    } catch (e) {
      _searchResult = '검색 중 오류 발생';
    }

    setState(() => _isSearching = false);
  }

  Future<void> _addFriend() async {
    if (_searchUid == null) return;

    final ref = FirebaseFirestore.instance
        .collection('friends')
        .doc(user.uid)
        .collection('list')
        .doc(_searchUid);

    await ref.set({'addedAt': FieldValue.serverTimestamp()});
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('친구 추가')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: '이메일로 검색'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _isSearching ? null : _searchUser,
              child: const Text('검색'),
            ),
            const SizedBox(height: 20),
            if (_searchResult != null) Text(_searchResult!),
            if (_searchUid != null)
              ElevatedButton(
                onPressed: _addFriend,
                child: const Text('친구 추가'),
              )
          ],
        ),
      ),
    );
  }
}
