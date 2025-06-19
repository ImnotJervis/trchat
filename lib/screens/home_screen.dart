import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_friend_screen.dart';
import 'chat_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final user = FirebaseAuth.instance.currentUser!;
  String? displayName;
  String? statusMessage;
  String? photoURL;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final doc = await FirebaseFirestore.instance.collection('users_data').doc(user.uid).get();
    final data = doc.data();
    setState(() {
      displayName = data?['displayName'] ?? user.email;
      statusMessage = data?['statusMessage'] ?? '';
      photoURL = data?['photoURL'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('홈'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddFriendScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ).then((_) => _loadUserProfile()),
          ),
        ],
      ),
      body: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              radius: 30,
              backgroundImage: photoURL != null ? NetworkImage(photoURL!) : null,
              child: photoURL == null ? const Icon(Icons.person, size: 30) : null,
            ),
            title: Text(displayName ?? user.email!),
            subtitle: Text(statusMessage ?? ''),
          ),
          const Divider(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('friends')
                  .doc(user.uid)
                  .collection('list')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final friendUid = docs[index].id;
                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance.collection('users_data').doc(friendUid).get(),
                      builder: (context, snap) {
                        if (!snap.hasData || !snap.data!.exists) return const SizedBox();
                        final data = snap.data!.data() as Map<String, dynamic>;
                        final name = data['displayName'] ?? data['email'];
                        final status = data['statusMessage'] ?? '';
                        final targetLang = data['targetLang'] ?? 'en';

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: data['photoURL'] != null
                                ? NetworkImage(data['photoURL'])
                                : null,
                            child: data['photoURL'] == null
                                ? const Icon(Icons.person)
                                : null,
                          ),
                          title: Text(name),
                          subtitle: Text(status),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(
                                receiverUid: friendUid,
                                receiverName: name,
                                targetLang: targetLang,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
