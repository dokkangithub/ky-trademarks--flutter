import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:kyuser/presentation/Screens/chat%20screen/view/screen/chat_screen.dart';

import '../../model/chat_model.dart';

class AllChatsScreen extends StatelessWidget {

  // final List<ChatModel> chats = List.generate(
  //   10,
  //       (index) => ChatModel(
  //     name: 'User $index',
  //     lastMessage: 'This is the last message for User $index.',
  //     time: '12:${index}0 PM',
  //     unreadCount: index % 3 == 0 ? index : 0,
  //     profileImage: 'https://via.placeholder.com/150',
  //   ),
  // );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search chats',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),

          // Chat List
          // Expanded(
          //   child: AnimationLimiter(
          //     child: ListView.builder(
          //       physics: const BouncingScrollPhysics(),
          //       itemCount: chats.length,
          //       itemBuilder: (context, index) {
          //         final chat = chats[index];
          //         return AnimationConfiguration.staggeredList(
          //           position: index,
          //           duration: const Duration(milliseconds: 500),
          //           child: SlideAnimation(
          //             verticalOffset: 50.0,
          //             child: FadeInAnimation(
          //               child: GestureDetector(
          //                 onTap: () {
          //                   Navigator.push(
          //                     context,
          //                     MaterialPageRoute(
          //                       builder: (context) => ChatScreen(chatId: chat.name,),
          //                     ),
          //                   );
          //                 },
          //                 child: ChatTile(chat: chat),
          //               ),
          //             ),
          //           ),
          //         );
          //       },
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}

// class ChatTile extends StatelessWidget {
//   final ChatModel chat;
//
//   const ChatTile({Key? key, required this.chat}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(10),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.withOpacity(0.3),
//               spreadRadius: 2,
//               blurRadius: 5,
//               offset: const Offset(0, 3),
//             ),
//           ],
//         ),
//         child: ListTile(
//           leading: CircleAvatar(
//             radius: 25,
//             backgroundImage: NetworkImage(chat.profileImage),
//           ),
//           title: Text(chat.name, style: const TextStyle(fontWeight: FontWeight.bold)),
//           subtitle: Text(
//             chat.lastMessage,
//             overflow: TextOverflow.ellipsis,
//             maxLines: 1,
//             style: const TextStyle(color: Colors.grey),
//           ),
//           trailing: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(chat.time, style: const TextStyle(color: Colors.grey, fontSize: 12)),
//               if (chat.unreadCount > 0)
//                 Container(
//                   margin: const EdgeInsets.only(top: 5),
//                   padding: const EdgeInsets.all(5),
//                   decoration: BoxDecoration(
//                     color: Colors.red,
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Text(
//                     '${chat.unreadCount}',
//                     style: const TextStyle(color: Colors.white, fontSize: 12),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


