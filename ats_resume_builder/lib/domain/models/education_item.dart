import 'package:flutter/foundation.dart';

/// An education entry. Optional fields (graduationYear, grade) are omitted from
/// PDF output when empty so blank labels never appear.
@immutable
class EducationItem {
  const EducationItem({
    required this.id,
    required this.degree,
    required this.institution,
    this.location = '',
    this.graduationYear = '',
    this.grade = '',
  });

  final String id;
  final String degree;
  final String institution;
  final String location;
  final String graduationYear;
  final String grade;

  EducationItem copyWith({
    String? id,
    String? degree,
    String? institution,
    String? location,
    String? graduationYear,
    String? grade,
  }) {
    return EducationItem(
      id: id ?? this.id,
      degree: degree ?? this.degree,
      institution: institution ?? this.institution,
      location: location ?? this.location,
      graduationYear: graduationYear ?? this.graduationYear,
      grade: grade ?? this.grade,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'degree': degree,
    'institution': institution,
    'location': location,
    'graduationYear': graduationYear,
    'grade': grade,
  };

  factory EducationItem.fromJson(Map<String, dynamic> json) {
    return EducationItem(
      id: json['id'] as String? ?? '',
      degree: json['degree'] as String? ?? '',
      institution: json['institution'] as String? ?? '',
      location: json['location'] as String? ?? '',
      graduationYear: json['graduationYear'] as String? ?? '',
      grade: json['grade'] as String? ?? '',
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EducationItem &&
        other.id == id &&
        other.degree == degree &&
        other.institution == institution &&
        other.location == location &&
        other.graduationYear == graduationYear &&
        other.grade == grade;
  }

  @override
  int get hashCode =>
      Object.hash(id, degree, institution, location, graduationYear, grade);
}
