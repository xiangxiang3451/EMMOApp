// features/chat/view_models/chat_view_model.dart
import 'package:emmo/services/firebase_service.dart';
import 'package:emmo/services/gpt_service.dart';
import 'package:flutter/material.dart';
import 'package:emmo/features/chat/models/message_model.dart';

class ChatViewModel with ChangeNotifier {
  final GPTService _gptService;
  final FirebaseService _firebaseService;
  final String? currentUserEmail;

  ChatViewModel({
    required GPTService gptService,
    required FirebaseService firebaseService,
    required this.currentUserEmail,
  })  : _gptService = gptService,
        _firebaseService = firebaseService {
    _initializeChat();
  }

  List<MessageModel> _messages = [];
  List<MessageModel> get messages => _messages;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isInputVisible = true;
  bool get isInputVisible => _isInputVisible;

  bool _isSummaryShown = false;
  bool get isSummaryShown => _isSummaryShown;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void _initializeChat() {
    _messages = [
      MessageModel(
        role: 'system',
        content: 'You are a helpful assistant specialized in managing emotions.',
      ),
      MessageModel(
        role: 'assistant',
        content: 'Hello! How are you feeling now?',
      ),
    ];
  }

  Future<void> sendMessage(String text) async {
    if (text.isEmpty) return;

    // Add user message
    _addMessage(MessageModel(role: 'user', content: text));
    _isInputVisible = false;
    _errorMessage = null;

    // Get GPT response
    try {
      _isLoading = true;
      notifyListeners();

      final gptMessages = _messages.map((m) => {'role': m.role, 'content': m.content}).toList();
      final response = await _gptService.getEmotionResponse(gptMessages);

      _addMessage(MessageModel(role: 'assistant', content: response));
    } catch (e) {
      _errorMessage = 'Failed to get response: $e';
      _addMessage(MessageModel(
        role: 'assistant',
        content: 'Sorry, I encountered an error. Please try again.',
      ));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void continueConversation() {
    _isInputVisible = true;
    notifyListeners();
  }

  Future<void> endAndSummarizeConversation() async {
    try {
      _isLoading = true;
      notifyListeners();

      final gptMessages = _messages.map((m) => {'role': m.role, 'content': m.content}).toList();
      final summary = await _gptService.summarizeChat(gptMessages);

      _addMessage(MessageModel(role: 'assistant', content: summary));
      _isSummaryShown = true;
    } catch (e) {
      _errorMessage = 'Failed to summarize: $e';
      _addMessage(MessageModel(
        role: 'assistant',
        content: 'Sorry, I couldn\'t summarize our conversation.',
      ));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> restartConversation() async {
    if (currentUserEmail != null && _isSummaryShown) {
      try {
        final lastMessage = _messages.lastWhere((m) => m.role == 'assistant');
        await _firebaseService.saveChatSummary(
          currentUserEmail!,
          lastMessage.content,
        );
      } catch (e) {
        _errorMessage = 'Failed to save summary: $e';
        notifyListeners();
        return;
      }
    }

    _messages.clear();
    _initializeChat();
    _isInputVisible = true;
    _isSummaryShown = false;
    _errorMessage = null;
    notifyListeners();
  }

  void _addMessage(MessageModel message) {
    _messages.add(message);
    notifyListeners();
  }
}