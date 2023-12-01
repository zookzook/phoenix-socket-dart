abstract class Payload {
  bool binary();
  Map<String, dynamic> toJson();
  // todo: umbenennen für das IPC Zeugs
  Object encode();
}

class BinaryPayload extends Payload {

  final List<int> payload;

  BinaryPayload(this.payload);

  @override
  bool binary() {
    return true;
  }

  @override
  Map<String, dynamic> toJson() {
    return {};
  }

  @override
  Object encode() {
    return payload;
  }
}

class JsonPayload extends Payload {

  final Map<String, dynamic> payload;

  JsonPayload(this.payload);

  @override
  bool binary() {
    return false;
  }

  @override
  Map<String, dynamic> toJson() {
    return payload;
  }

  @override
  Object encode() {
    return payload;
  }
}