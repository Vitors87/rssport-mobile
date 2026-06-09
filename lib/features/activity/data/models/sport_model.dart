class SportModel {
  final String id;
  final String type;
  final String name;
  final String? description;

  const SportModel({
    required this.id,
    required this.type,
    required this.name,
    this.description,
  });

  factory SportModel.fromJson(Map<String, dynamic> json) {
    return SportModel(
      id: json['id'] as String,
      type: json['type'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
    );
  }
}
