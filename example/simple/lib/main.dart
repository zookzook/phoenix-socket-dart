import 'dart:async';

import 'package:phoenix_socket/phoenix_socket.dart';
import 'package:uuid/uuid.dart';
import 'package:logging/logging.dart';

void main() async {
  Logger.root.level = Level.FINEST;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });
  final socket = PhoenixSocket('ws://localhost:4001/socket/websocket?token=540f6ea8-c980-46dd-a040-c9a62958487a&app_version=10.0.0&vsn=2.0.0&binary=true&platform=macos');
  await socket.connect();
  var channel = socket.addChannel(topic: 'collaborators:540f6ea8-c980-46dd-a040-c9a62958487a');
  await channel.join().future;
  await for (var message in channel.messages) {
    print("received ${message.event} with payload ${message.payload}");
  }
}
