import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

// Хранилище данных
final Map<String, String> _users = {};
final Map<String, WebSocketChannel> _connections = {};
final List<Map<String, dynamic>> _messages = [];

void main() async {
  // Сначала объявляем обработчик WebSocket
  final wsHandler = webSocketHandler((WebSocketChannel webSocket) {
    print('Новое подключение WebSocket');
    final connectionId = DateTime.now().millisecondsSinceEpoch.toString();
    _connections[connectionId] = webSocket;

    webSocket.stream.listen(
          (message) => _handleMessage(webSocket, message),
      onDone: () => _handleDisconnect(webSocket),
      onError: (error) => print('WebSocket error: $error'),
    );
  });

  // HTTP сервер для регистрации/входа
  final handler = const Pipeline().addHandler((Request request) async {
    if (request.url.path == 'register' && request.method == 'POST') {
      return _handleRegister(await request.readAsString());
    } else if (request.url.path == 'login' && request.method == 'POST') {
      return _handleLogin(await request.readAsString());
    } else if (request.url.path == 'health' && request.method == 'GET') {
      return Response.ok('Server is running');
    }
    return Response.notFound('Not found');
  });

  // Запускаем серверы
  final server = await serve(handler, 'localhost', 8080);
  final wsServer = await serve(wsHandler, 'localhost', 8081);

  print('✅ HTTP сервер запущен на http://localhost:${server.port}');
  print('✅ WebSocket сервер запущен на ws://localhost:${wsServer.port}');
  print('✅ Проверка здоровья: http://localhost:${server.port}/health');
}

Response _handleRegister(String body) {
  try {
    final data = jsonDecode(body);
    final email = data['email'];
    final password = data['password'];

    if (email == null || password == null) {
      return Response(400, body: jsonEncode({'error': 'Email and password required'}));
    }

    if (_users.containsKey(email)) {
      return Response(400, body: jsonEncode({'error': 'User already exists'}));
    }

    _users[email] = password;
    print('✅ Новый пользователь: $email');
    return Response.ok(jsonEncode({'success': true, 'email': email}));
  } catch (e) {
    return Response(400, body: jsonEncode({'error': 'Invalid JSON format'}));
  }
}

Response _handleLogin(String body) {
  try {
    final data = jsonDecode(body);
    final email = data['email'];
    final password = data['password'];

    if (email == null || password == null) {
      return Response(400, body: jsonEncode({'error': 'Email and password required'}));
    }

    if (_users[email] != password) {
      return Response(401, body: jsonEncode({'error': 'Invalid credentials'}));
    }

    print('✅ Успешный вход: $email');
    return Response.ok(jsonEncode({'success': true, 'email': email}));
  } catch (e) {
    return Response(400, body: jsonEncode({'error': 'Invalid JSON format'}));
  }
}

void _handleMessage(WebSocketChannel webSocket, dynamic message) {
  try {
    final data = jsonDecode(message);
    final text = data['text'];
    final email = data['email'];

    if (text == null || email == null) {
      webSocket.sink.add(jsonEncode({'error': 'Text and email required'}));
      return;
    }

    final messageData = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'text': text,
      'sender': email,
      'timestamp': DateTime.now().toIso8601String(),
    };

    _messages.add(messageData);
    print('📨 Новое сообщение от $email: $text');
    _broadcast(messageData);
  } catch (e) {
    print('❌ Ошибка обработки сообщения: $e');
    webSocket.sink.add(jsonEncode({'error': 'Invalid message format'}));
  }
}

void _broadcast(Map<String, dynamic> message) {
  final messageJson = jsonEncode({
    'type': 'new_message',
    'data': message
  });

  _connections.forEach((id, socket) {
    try {
      socket.sink.add(messageJson);
    } catch (e) {
      print('❌ Ошибка отправки сообщения соединению $id: $e');
    }
  });
}

void _handleDisconnect(WebSocketChannel webSocket) {
  final entry = _connections.entries.firstWhere(
          (entry) => entry.value == webSocket,
      orElse: () => MapEntry('', webSocket)
  );

  if (entry.key.isNotEmpty) {
    _connections.remove(entry.key);
    print('🔌 Отключено соединение: ${entry.key}');
  }
}