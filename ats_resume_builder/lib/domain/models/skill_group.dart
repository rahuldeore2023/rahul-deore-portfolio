import 'package:flutter/foundation.dart';

/// A categorized group of technical skills (e.g., Languages: Kotlin, Java, Dart).
@immutable
class SkillGroup {
  const SkillGroup({
    required this.id,
    required this.category,
    required this.skills,
  });

  final String id;
  final String category;
  final List<String> skills;

  SkillGroup copyWith({
    String? id,
    String? category,
    List<String>? skills,
  }) {
    return SkillGroup(
      id: id ?? this.id,
      category: category ?? this.category,
      skills: skills ?? this.skills,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'category': category,
    'skills': skills,
  };

  factory SkillGroup.fromJson(Map<String, dynamic> json) {
    return SkillGroup(
      id: json['id'] as String? ?? '',
      category: json['category'] as String? ?? '',
      skills: (json['skills'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SkillGroup &&
        other.id == id &&
        other.category == category &&
        listEquals(other.skills, skills);
  }

  @override
  int get hashCode => Object.hash(id, category, Object.hashAll(skills));
}
