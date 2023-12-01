import 'dart:convert';

import 'message.dart';

/// Default class to serialize [Message] instances to JSON.
class MessageSerializer {
  MessageSerializer._();

  /// Default constructor returning the singleton instance of this class.
  factory MessageSerializer() => _instance ??= MessageSerializer._();

  static MessageSerializer? _instance;

  /// Yield a [Message] from some raw string arriving from a websocket.
  Message decode(dynamic rawData) {
    if(rawData is List<int>) {
      return Message.fromBinary(rawData);
    }
    else
      if(rawData is String) {
        return Message.fromJson(jsonDecode(rawData));
      }
    else {
      throw ArgumentError('Received a non-string or a non-list of integers');
    }
  }

  /// Given a [Message], return the raw string that would be sent through
  /// a websocket.
  Object encode(Message message) {
    try {
      if(message.isBinary) {
        return message.encode();
      }
      else {
        return jsonEncode(message.encode());
      }
    } catch(e) {
      print("Errror: $e");
      rethrow;
    }
  }
}
