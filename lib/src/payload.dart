abstract class Payload {
  bool isBinary();

  Map<String, dynamic> toJson();
}

class BinaryPayload extends Payload {

  final List<int> payload;

  BinaryPayload(this.payload);

  @override
  bool isBinary() {
    return true;
  }

  @override
  Map<String, dynamic> toJson() {
    return {'binary': payload};
  }
}

class JsonPayload extends Payload {

  final Map<String, dynamic> payload;

  JsonPayload(this.payload);

  @override
  bool isBinary() {
    return false;
  }

  @override
  Map<String, dynamic> toJson() {
    return payload;
  }

}