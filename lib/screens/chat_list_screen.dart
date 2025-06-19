import 'package:flutter/material.dart';
import 'chat_screen.dart'; // 채팅방 UI

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<String> dummyChats = [
      '친구 A',
      '친구 B',
      '친구 C',
      '언어 교환 파트너',
      '테스트 사용자',
    ];

    return ListView.builder(
      itemCount: dummyChats.length,
      itemBuilder: (context, index) {
        final chatName = dummyChats[index];
        return ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person)),
          title: Text(chatName),
          subtitle: const Text('마지막 메시지 미리보기...'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatScreen(
                  receiverUid: '상대 UID',
                  receiverName: '상대 이름',
                  targetLang: 'ko', // 또는 동적으로 가져온 언어 설정
                ),
              ),
            );
          },
        );
      },
    );
  }
}
