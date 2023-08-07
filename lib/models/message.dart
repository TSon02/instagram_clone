class Message {
  String? toId;
  String? msg;
  String? read;
  Type? type;
  String? fromId;
  String? sent;

  Message(
      {required this.toId,
      required this.msg,
      required this.read,
      required this.type,
      required this.fromId,
      required this.sent});

  Message.fromJson(Map<String, dynamic> json) {
    toId = json['toId'];
    msg = json['msg'];
    read = json['read'];
    type = json['type'] == Type.image.name ? Type.image : Type.text;
    fromId = json['fromId'];
    sent = json['sent'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['toId'] = toId;
    data['msg'] = msg;
    data['read'] = read;
    data['type'] = type!.name;
    data['fromId'] = fromId;
    data['sent'] = sent;
    return data;
  }
}

enum Type { text, image }
