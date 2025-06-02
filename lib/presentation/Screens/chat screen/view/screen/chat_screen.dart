import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kyuser/presentation/Widget/loading_widget.dart';
import 'package:provider/provider.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import '../../../../../resources/Color_Manager.dart';
import '../../model/message_model.dart';
import '../../view_model/chat_provider.dart';

class ChatScreen extends StatelessWidget {
  final String chatId;

  const ChatScreen({Key? key, required this.chatId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatViewModel(chatId),
      child: Consumer<ChatViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              toolbarHeight: 60,
              systemOverlayStyle: SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.light,
              ),
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ColorManager.primaryByOpacity.withOpacity(0.9),
                      ColorManager.primary,
                    ],

                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        ColorManager.primaryByOpacity.withOpacity(0.9),
                        ColorManager.primary,
                      ],

                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 18, right: 18, top: 18),
                    child: SizedBox(height: 70,),
                  ),
                ),
              ),
              title: Text('admin',style: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.w500),),
            ),
            body: viewModel.isLoading
                ? Center(child: LoadingWidget())
                : Chat(
              scrollPhysics: const BouncingScrollPhysics(),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              messages: viewModel.messages.map((msg) {
                if (msg.type == 'text') {
                  return types.TextMessage(
                    author: msg.author,
                    id: msg.id,
                    text: msg.text!,
                    createdAt: msg.createdAt,
                  );
                }
                else if (msg.type == 'image') {
                  return types.ImageMessage(
                    author: msg.author,
                    id: msg.id,
                    size: 10,
                    name: msg.name!,
                    uri: msg.uri!,
                    createdAt: msg.createdAt,
                  );
                }
                else if (msg.type == 'audio') {
                  return types.FileMessage(
                    author: msg.author,
                    id: msg.id,
                    name: msg.name!,
                    size: msg.size!,
                    uri: msg.uri!,
                    createdAt: msg.createdAt,
                  );
                }
                else if (msg.type == 'file') {
                  return types.FileMessage(
                    author: msg.author,
                    id: msg.id,
                    name: msg.name!,
                    size: msg.size!,
                    uri: msg.uri!,
                    createdAt: msg.createdAt,
                  );
                }
                return null;
              }).whereType<types.Message>().toList(),
              onSendPressed: (partialText) {
                final message = ChatMessage(
                  id: '',
                  type: 'text',
                  author: types.User(id: viewModel.userId!),
                  text: partialText.text,
                  createdAt: DateTime.now().millisecondsSinceEpoch,
                );
                viewModel.sendMessage(message);
              },
              onAttachmentPressed: () {
                viewModel.handleAttachmentPressed(context);
              },
              onMessageTap: (context, types.Message message) {
                print(message.type.name);
                viewModel.onMessageTap(message,context);
              },
              theme: DefaultChatTheme(
                inputTextCursorColor: ColorManager.white,
                inputPadding: const EdgeInsets.fromLTRB(24, 15, 24, 15),
                inputBackgroundColor: Colors.white,
                inputTextColor: Colors.white,
                inputMargin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                inputTextStyle: const TextStyle(color: Colors.black),
                inputBorderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(10),
                  right: Radius.circular(10),
                ),
                inputContainerDecoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ColorManager.primaryByOpacity.withOpacity(0.9),
                      ColorManager.primary,
                    ],
                  ),
                  border: Border.all(color: Colors.grey, width: 1.0),
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(40),
                    right: Radius.circular(40),
                  ),
                ),
                primaryColor: ColorManager.primary,
                backgroundColor: ColorManager.white,
              ),
              user: types.User(id: viewModel.userId ?? 'user-id'),
            ),

          );
        },
      ),
    );
  }
}
