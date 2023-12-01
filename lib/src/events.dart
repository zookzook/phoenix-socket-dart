import 'package:equatable/equatable.dart';

import 'channel.dart';
import 'socket.dart';

/// Base socket event
abstract class PhoenixSocketEvent extends Equatable {
  @override
  bool get stringify => true;
}

/// Open event for a [PhoenixSocket].
class PhoenixSocketOpenEvent extends PhoenixSocketEvent {
  @override
  List<Object?> get props => [];
}

/// Close event for a [PhoenixSocket].
class PhoenixSocketCloseEvent extends PhoenixSocketEvent {
  /// Default constructor for this close event.
  PhoenixSocketCloseEvent({
    this.reason,
    this.code,
  });

  /// The reason the socket was closed.
  final String? reason;

  /// The code of the socket close.
  final int? code;

  @override
  List<Object?> get props => [code, reason];
}

/// Error event for a [PhoenixSocket].
class PhoenixSocketErrorEvent extends PhoenixSocketEvent {
  /// Default constructor for the error event.
  PhoenixSocketErrorEvent({
    this.error,
    this.stacktrace,
  });

  /// The error that happened on the socket
  final dynamic error;

  /// The stacktrace associated with the error.
  final dynamic stacktrace;

  @override
  List<Object?> get props => [error];
}

class PhoenixChannelEvent {

  static const String close = 'phx_close';
  static const String error = 'phx_error';
  static const String join = 'phx_join';
  static const String reply = 'phx_reply';
  static const String leave = 'phx_leave';
  static const String chanReply = 'chan_reply';
  static const String heartbeat = 'heartbeat';

  /// The constant set of possible internal channel event names.
  static Set<String> statuses = {close, error, join, reply, leave};

  static String makeKey(String ref) => '${chanReply}_$ref';

  /// Whether the event name is an 'reply' event
  static bool isReply(String value) =>
      value.startsWith(chanReply) ||
      value.startsWith(reply);

}
