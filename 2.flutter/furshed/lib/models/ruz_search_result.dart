class RuzSearchResult {
  const RuzSearchResult({
    required this.id,
    required this.label,
    required this.description,
    required this.type,
  });

  final String id;
  final String label;
  final String description;
  final String type;

  factory RuzSearchResult.fromJson(Map<String, dynamic> json) {
    return RuzSearchResult(
      id: json['id']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
    );
  }

  bool get isPerson => type == 'person' || type == 'lecturer';
  String get scheduleType => isPerson ? 'person' : 'group';
}
