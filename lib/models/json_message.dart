class Message {
  final String name;
  final String type;
  final String content;

  Message({required this.name, required this.type, required this.content});

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      name: json['name'] ?? "", // Provide a default value for name if it's null
      type: json['type'] ?? "", // Provide a default value for type if it's null
      content: json['content'] ??
          "", // Provide a default value for content if it's null
    );
  }
}
