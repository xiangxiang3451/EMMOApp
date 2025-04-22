// features/chat/views/chat_screen.dart
import 'package:emmo/services/authentication_service.dart';
import 'package:emmo/features/chat/models/message_model.dart';
import 'package:emmo/services/firebase_service.dart';
import 'package:emmo/services/gpt_service.dart';
import 'package:flutter/material.dart';
import 'package:emmo/features/chat/view_models/chat_view_model.dart';
import 'package:provider/provider.dart';
import 'package:emmo/services/language.dart';  // 引入I18N类

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 在创建Provider之前先获取依赖
    final gptService = Provider.of<GPTService>(context, listen: false);
    final firebaseService = Provider.of<FirebaseService>(context, listen: false);
    Provider.of<AuthenticationService>(context, listen: false);

    return ChangeNotifierProvider(
      create: (_) => ChatViewModel(
        gptService: gptService,
        firebaseService: firebaseService,
        currentUserEmail: AuthenticationService.currentUserEmail,
      ),
      child: const Scaffold(
        body: _ChatBody(),
      ),
    );
  }
}

class _ChatBody extends StatelessWidget {
  const _ChatBody();

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ChatViewModel>(context);
    final textController = TextEditingController();
    final scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (viewModel.messages.isNotEmpty) {
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      }
    });

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: viewModel.messages.length,
              itemBuilder: (context, index) {
                final message = viewModel.messages[index];
                if (message.role == 'system') return const SizedBox.shrink();
                
                return _MessageBubble(
                  message: message,
                  isUser: message.role == 'user',
                );
              },
            ),
          ),
          if (viewModel.errorMessage != null)
            Text(
              viewModel.errorMessage!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          const SizedBox(height: 10),
          if (viewModel.isSummaryShown)
            _RestartButton(viewModel: viewModel)
          else if (viewModel.isInputVisible)
            _ChatInput(
              controller: textController,
              onSend: () {
                viewModel.sendMessage(textController.text);
                textController.clear();
              },
            )
          else
            _ActionButtons(viewModel: viewModel),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isUser;

  const _MessageBubble({
    required this.message,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isUser 
              ? Theme.of(context).primaryColor 
              : Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          message.content,
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}

class _ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _ChatInput({
    required this.controller,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: I18N.translate('enter_your_feelings'), // 使用I18N进行翻译
              border: const OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: onSend,
          child: Text(I18N.translate('send')), // 使用I18N进行翻译
        ),
      ],
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final ChatViewModel viewModel;

  const _ActionButtons({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton(
          onPressed: viewModel.continueConversation,
          child: Text(I18N.translate('continue')), // 使用I18N进行翻译
        ),
        ElevatedButton(
          onPressed: viewModel.endAndSummarizeConversation,
          child: Text(I18N.translate('end_and_summarize')), // 使用I18N进行翻译
        ),
      ],
    );
  }
}

class _RestartButton extends StatelessWidget {
  final ChatViewModel viewModel;

  const _RestartButton({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: viewModel.restartConversation,
        child: Text(I18N.translate('restart_conversation')), // 使用I18N进行翻译
      ),
    );
  }
}
