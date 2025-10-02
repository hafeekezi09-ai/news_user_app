import 'package:cloud_firestore/cloud_firestore.dart';

class News {
  final String? id;                    
  final String title;
  final String content;
  final String imageUrl;
  final String type;                   
  final String status;                 
  final String? categoryId;            
  final String? authorId;              
  final DateTime? publishedAt;

  
  final bool isTrending;
  final int views;

  const News({
    this.id,
    required this.title,
    required this.content,
    required this.imageUrl,
    required this.type,
    required this.status,
    this.categoryId,
    this.authorId,
    this.publishedAt,
    this.isTrending = false,
    this.views = 0,
  });

  Map<String, dynamic> toMap({bool forCreate = false}) {
    final map = <String, dynamic>{
      'title': title.trim(),
      'content': content.trim(),
      'imageUrl': imageUrl.trim(),
      'type': type.toLowerCase(),
      'status': status.toLowerCase(),
      if (categoryId != null && categoryId!.isNotEmpty) 'categoryId': categoryId,
      if (authorId != null && authorId!.isNotEmpty) 'authorId': authorId,
      'isTrending': isTrending,
      'views': views,
    };
    
    if (forCreate && status.toLowerCase() == 'published') {
      map['publishedAt'] = FieldValue.serverTimestamp();
    }
    return map;
  }

  factory News.fromMap(String id, Map<String, dynamic> map) {
    return News(
      id: id,
      title: (map['title'] ?? '').toString(),
      content: (map['content'] ?? '').toString(),
      imageUrl: (map['imageUrl'] ?? '').toString(),
      type: (map['type'] ?? 'article').toString().toLowerCase(),
      status: (map['status'] ?? 'draft').toString().toLowerCase(),
      categoryId: (map['categoryId'] ?? '').toString().isEmpty ? null : map['categoryId'],
      authorId: (map['authorId'] ?? '').toString().isEmpty ? null : map['authorId'],
      publishedAt: map['publishedAt'] is Timestamp
          ? (map['publishedAt'] as Timestamp).toDate()
          : null,
      isTrending: map['isTrending'] as bool? ?? false,
      views: (map['views'] as num?)?.toInt() ?? 0,
    );
  }
}
