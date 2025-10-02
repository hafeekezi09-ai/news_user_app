class Category {
  final String? id; 
  final String name;
  final String type; 
  final String? coverUrl;
  final String? content;
  final String? featureTitle;
  final String? featureContent;
  final String? featureImageUrl;

  Category({
    this.id,
    required this.name,
    required this.type,
    this.coverUrl,
    this.content,
    this.featureTitle,
    this.featureContent,
    this.featureImageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'coverUrl': coverUrl,
      'content': content,
      'featureTitle': featureTitle,
      'featureContent': featureContent,
      'featureImageUrl': featureImageUrl,
    };
  }

  factory Category.fromMap(String id, Map<String, dynamic> data) {
    return Category(
      id: id,
      name: (data['name'] ?? '').toString(),
      type: (data['type'] ?? 'article').toString(),
      coverUrl: data['coverUrl'] as String?,
      content: data['content'] as String?,
      featureTitle: data['featureTitle'] as String?,
      featureContent: data['featureContent'] as String?,
      featureImageUrl: data['featureImageUrl'] as String?,
    );
  }
}
