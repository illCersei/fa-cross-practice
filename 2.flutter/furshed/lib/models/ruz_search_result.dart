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
      id: (json['id'] as String?) ?? '',
      label: (json['label'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      type: (json['type'] as String?) ?? '',
    );
  }

  bool get isPerson => type == 'person' || type == 'lecturer';
  String get scheduleType => isPerson ? 'person' : 'group';
}
