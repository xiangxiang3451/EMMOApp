// features/chat/views/chat_screen.dart
import 'package:emmo/services/authentication_service.dart';
import 'package:emmo/features/chat/models/message_model.dart';
import 'package:emmo/services/firebase_service.dart';
import 'package:emmo/services/gpt_service.dart';
import 'package:flutter/material.dart';
import 'package:emmo/features/chat/view_models/chat_view_model.dart';
import 'package:provider/provider.dart';

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
      child: Scaffold(
        appBar: AppBar(title: const Text('Emotion Chat')),
        body: const _ChatBody(),
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
            decoration: const InputDecoration(
              labelText: 'Enter your feelings',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: onSend,
          child: const Text('Send'),
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
          child: const Text('Continue'),
        ),
        ElevatedButton(
          onPressed: viewModel.endAndSummarizeConversation,
          child: const Text('End & Summarize'),
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
        child: const Text('Restart Conversation'),
      ),
    );
  }
}