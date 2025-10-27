import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../../model/fastApiModel/chatMessageModel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:dio/dio.dart';


class ChatProvider with ChangeNotifier {
  final String baseWsUrl;
  final String baseApiUrl;

  IOWebSocketChannel? _channel;
  List<ChatMessage> messages = [];
  String? currentOtherUserId;

  ChatProvider({required this.baseWsUrl, required this.baseApiUrl});

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  /// Connect to WebSocket
  Future<void> connect(String otherUserId) async {
    currentOtherUserId = otherUserId;
    final token = await _getToken();
    if (token == null) return;

    final url = '$baseWsUrl/ws/chat/$otherUserId?token=$token';
    _channel = IOWebSocketChannel.connect(url);

    _channel!.stream.listen((event) {
      final data = jsonDecode(event);
      if (data['message'] != null) {
        final msg = ChatMessage.fromJson(data);
        messages.add(msg);
        notifyListeners();
      }
    }, onDone: () {
      debugPrint('WebSocket disconnected');
    }, onError: (err) {
      debugPrint('WebSocket error: $err');
    });
  }

  /// Disconnect WebSocket
  void disconnect() {
    _channel?.sink.close();
    _channel = null;
    currentOtherUserId = null;
  }

  /// Send message via WebSocket (or fallback REST)
  void sendMessage(String text, {String? roomId}) async {
    if (_channel != null) {
      _channel!.sink.add(jsonEncode({
        'message': text,
        if (roomId != null) 'room_id': roomId,
      }));

      // Add optimistic UI message
      messages.add(ChatMessage(
        id : 0,
        fromId: 'me',
        toId: currentOtherUserId!,
        message: text,
        timestamp: DateTime.now(),
        isRead: false,
      ));
      notifyListeners();
    } else {
      await _sendViaRest(text, roomId: roomId);
    }
  }

  /// Fallback REST send
  Future<void> _sendViaRest(String text, {String? roomId}) async {
    final token = await _getToken();
    if (token == null) return;

    final dio = Dio();
    dio.options.headers['Authorization'] = 'Bearer $token';
    final body = {
      'receiver_id': currentOtherUserId,
      'message': text,
      if (roomId != null) 'room_id': roomId,
    };

    try {
      await dio.post('$baseApiUrl/chat/send', data: body);
    } catch (e) {
      debugPrint('REST send failed: $e');
    }
  }

  /// Load chat history
  Future<void> loadHistory(String roomId) async {
    final token = await _getToken();
    if (token == null) return;

    final dio = Dio();
    dio.options.headers['Authorization'] = 'Bearer $token';

    try {
      final res = await dio.get('$baseApiUrl/chat/$roomId');
      messages = (res.data as List)
          .map((j) => ChatMessage.fromJson(j))
          .toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Load history failed: $e');
    }
  }

  /// Mark messages read
  Future<void> markRead(String roomId) async {
    final token = await _getToken();
    if (token == null) return;

    final dio = Dio();
    dio.options.headers['Authorization'] = 'Bearer $token';

    try {
      await dio.post('$baseApiUrl/chat/$roomId/read');
      for (var msg in messages) msg.isRead = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Mark read failed: $e');
    }
  }}