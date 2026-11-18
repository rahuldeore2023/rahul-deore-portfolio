import 'package:flutter/foundation.dart';

/// A featured project entry with tech stack, optional link, and outcome bullets.
@immutable
class ProjectItem {
  const ProjectItem({
    required this.id,
    required this.name,
    required this.techStack,
    this.url = '',
    this.bullets = const [],
  });

  final String id;
  final String name;
  final String techStack;
  final String url;
  final List<String> bullets;

  ProjectItem copyWith({
    String? id,
    String? name,
    String? techStack,
    String? url,
    List<String>? bullets,
  }) {
    return ProjectItem(
      id: id ?? this.id,
      name: name ?? this.name,
      techStack: techStack ?? this.techStack,
      url: url ?? this.url,
      bullets: bullets ?? this.bullets,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'techStack': techStack,
    'url': url,
    'bullets': bullets,
  };

  factory ProjectItem.fromJson(Map<String, dynamic> json) {
    return ProjectItem(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      techStack: json['techStack'] as String? ?? '',
      url: json['url'] as String? ?? '',
      bullets: (json['bullets'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProjectItem &&
        other.id == id &&
        other.name == name &&
        other.techStack == techStack &&
        other.url == url &&
        listEquals(other.bullets, bullets);
  }

  @override
  int get hashCode =>
      Object.hash(id, name, techStack, url, Object.hashAll(bullets));
}
