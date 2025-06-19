import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final user = FirebaseAuth.instance.currentUser!;
  final nameController = TextEditingController();
  final statusController = TextEditingController();
  String? photoURL;
  String selectedLang = 'en';

  final langMap = {
    'en': '영어',
    'ko': '한국어',
    'ja': '일본어',
    'zh': '중국어',
    'es': '스페인어',
    'de': '독일어',
    'fr': '프랑스어',
  };

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final doc = await FirebaseFirestore.instance.collection('users_data').doc(user.uid).get();
    final data = doc.data() ?? {};
    nameController.text = data['displayName'] ?? user.email!;
    statusController.text = data['statusMessage'] ?? '';
    photoURL = data['photoURL'];
    selectedLang = data['targetLang'] ?? 'en';
    setState(() {});
  }

  Future<void> _saveProfile() async {
    await FirebaseFirestore.instance.collection('users_data').doc(user.uid).update({
      'displayName': nameController.text.trim(),
      'statusMessage': statusController.text.trim(),
      'targetLang': selectedLang,
    });

    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final ref = FirebaseStorage.instance.ref('profile_images/${user.uid}.jpg');
      await ref.putFile(File(image.path));
      final url = await ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('users_data').doc(user.uid).update({
        'photoURL': url,
      });

      setState(() => photoURL = url);
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 40,
                backgroundImage: photoURL != null ? NetworkImage(photoURL!) : null,
                child: photoURL == null ? const Icon(Icons.camera_alt, size: 40) : null,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: '이름'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: statusController,
              decoration: const InputDecoration(labelText: '상태 메시지'),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: selectedLang,
              items: langMap.entries
                  .map((e) => DropdownMenuItem(
                value: e.key,
                child: Text(e.value),
              ))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => selectedLang = val);
              },
              decoration: const InputDecoration(labelText: '기본 번역 언어'),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _saveProfile,
              icon: const Icon(Icons.save),
              label: const Text('저장'),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: const Text('로그아웃'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
