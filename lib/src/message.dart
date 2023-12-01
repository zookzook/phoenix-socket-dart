import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:logging/logging.dart';

import 'channel.dart';
import 'dart:convert';
import 'events.dart';
import 'socket.dart';
import 'payload.dart';

final Logger _logger = Logger('phoenix_socket.message');

const int pushMessage = 0;
const int replyMessage = 1;

/// Class that encapsulate a message being sent or received on a
/// [PhoenixSocket].
class Message extends Equatable {

  // JSON encoded message
  factory Message.fromJson(List<dynamic> parts) {
    _logger.finest('JSON message decoded from $parts');

    // if we found a reply then the payload
    // is in the response part
    if( parts[3] == "phx_reply") {
      final data = parts[4];
      final payload = JsonPayload(data['response']);
      final status = data['status'];
      return Message(joinRef: parts[0], ref: parts[1], topic: parts[2], event: parts[3], status: status, payload: payload);
    }
    else {
      final payload = JsonPayload(parts[4]);
      return Message(joinRef: parts[0], ref: parts[1], topic: parts[2], event: parts[3], payload: payload);
    }
  }

  // Binary encoded message
  factory Message.fromBinary(List<int> parts) {
    _logger.finest('Binary message decoded from raw $parts');

    if( parts[0] == pushMessage ) {
      final joinRefSize = parts[1];
      final topicSize = parts[2];
      final eventSize = parts[3];

      int pointer = 4;

      final joinRef = parts.sublist(pointer, pointer + joinRefSize);
      pointer = pointer + joinRefSize;

      final topic = parts.sublist(pointer, pointer + topicSize);
      pointer = pointer + topicSize;

      final event = parts.sublist(pointer, pointer + eventSize);
      pointer = pointer + eventSize;

      final payload = BinaryPayload(parts.sublist(pointer));
      return Message(joinRef: utf8.decode(joinRef), topic: utf8.decode(topic), event: utf8.decode(event), payload: payload);
    }
    else
      if(parts[0] == replyMessage) {
        final joinRefSize = parts[1];
        final refSize = parts[2];
        final topicSize = parts[3];
        final statusSize = parts[4];

        int pointer = 5;

        final joinRef = parts.sublist(pointer, pointer + joinRefSize);
        pointer = pointer + joinRefSize;

        final ref = parts.sublist(pointer, pointer + refSize);
        pointer = pointer + refSize;

        final topic = parts.sublist(pointer, pointer + topicSize);
        pointer = pointer + topicSize;

        final status = parts.sublist(pointer, pointer + statusSize);
        pointer = pointer + statusSize;

        final payload = BinaryPayload(parts.sublist(pointer));
        return Message(joinRef: utf8.decode(joinRef), ref: utf8.decode(ref), topic: utf8.decode(topic), payload: payload, event: PhoenixChannelEvent.reply, status: utf8.decode(status));
      }
      else {
        final topicSize = parts[1];
        final eventSize = parts[2];

        int pointer = 3;

        final topic = parts.sublist(pointer, pointer + topicSize);
        pointer = pointer + topicSize;

        final event = parts.sublist(pointer, pointer + eventSize);
        pointer = pointer + eventSize;

        final payload = BinaryPayload(parts.sublist(pointer));
        return Message(topic: utf8.decode(topic), event: utf8.decode(event), payload: payload);
      }
  }

  factory Message.fromStatus(String status) {
    return Message(event: PhoenixChannelEvent.reply, payload: JsonPayload({status: status}));
  }

  /// Given a unique reference, generate a heartbeat message.
  factory Message.heartbeat(String ref) {
    return Message(topic: 'phoenix', event: PhoenixChannelEvent.heartbeat, payload: JsonPayload({}), ref: ref);
  }

  /// Given a unique reference, generate a timeout message that
  /// will be used to error out a push.
  factory Message.timeoutFor(String ref) {
    return Message(event: PhoenixChannelEvent.makeKey(ref), payload: JsonPayload({'status': 'timeout', 'response': {}}));
  }

  // Simple constructor
  Message({this.joinRef, this.ref, this.topic, required this.event, this.payload, this.status});

  /// Reference of the channel on which the message is received.
  ///
  /// Used by the [PhoenixSocket] to route the message on the proper
  /// [PhoenixChannel].
  final String? joinRef;

  /// The unique identifier for this message.
  ///
  /// This identifier is used in the reply event name, allowing us
  /// to consider a message as a reply to a previous message.
  final String? ref;

  /// The topic of the channel on which this message is sent.
  final String? topic;

  /// The event name of this message.
  String event;

  /// The payload of this message.
  final Payload? payload;

  /// if the message is a reply we have a status
  final String? status;

  /// Encode a message to a JSON-encodable list of values.
  Object encode() {
    if(payload!.binary()) {
      return _encodeBinary();
    } // if
    else {
      return _encodeJson();
    } // else
  }

  // Encode a binary push message
  Object _encodeBinary() {
    List<int> parts = [];
    List<int> joinRefPart = _byteSize(joinRef!);
    List<int> refPart = _byteSize(ref!);
    List<int> topicPart = _byteSize(topic!);
    List<int> eventPart = _byteSize(event);

    // push constant is 0
    parts.add(0);
    parts.add(joinRefPart.length);
    parts.add(refPart.length);
    parts.add(topicPart.length);
    parts.add(eventPart.length);

    parts.addAll(joinRefPart);
    parts.addAll(refPart);
    parts.addAll(topicPart);
    parts.addAll(eventPart);
    parts.addAll((payload! as BinaryPayload).payload);

    _logger.finest('Binary message encoded to $parts');
    return parts;
  }

  List<int> _byteSize(String string) {
    if(string.length > 255) {
      return utf8.encode(string.substring(0, 255));
    }
    else {
      return utf8.encode(string);
    }
  }

  // encodes the JSON message
  Object _encodeJson() {
    final parts = [joinRef, ref, topic, event, payload!.toJson()];
    _logger.finest('Json message encoded to $parts');
    return parts;
  }

  @override
  List<Object?> get props => [joinRef, ref, topic, event, payload, status];

  @override
  bool get stringify => true;

  /// Whether the message is a reply message.
  bool get isReply => PhoenixChannelEvent.isReply(event);

  bool get isBinary => payload!.binary();

  void updateEvent() {
    event = PhoenixChannelEvent.makeKey(ref!);
  }
}
