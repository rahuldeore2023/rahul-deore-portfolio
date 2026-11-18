import 'package:flutter/foundation.dart';

/// A single work experience entry with ATS-friendly date formatting and bullets.
@immutable
class ExperienceItem {
  const ExperienceItem({
    required this.id,
    required this.role,
    required this.company,
    required this.location,
    required this.startDate,
    required this.endDate,
    this.isCurrent = false,
    this.bullets = const [],
  });

  final String id;
  final String role;
  final String company;
  final String location;
  final String startDate;
  final String endDate;
  final bool isCurrent;
  final List<String> bullets;

  String get formattedDateRange {
    final start = startDate.trim();
    final end = isCurrent ? 'Present' : endDate.trim();
    if (start.isEmpty && end.isEmpty) return '';
    if (start.isEmpty) return end;
    if (end.isEmpty) return start;
    return '$start - $end';
  }

  ExperienceItem copyWith({
    String? id,
    String? role,
    String? company,
    String? location,
    String? startDate,
    String? endDate,
    bool? isCurrent,
    List<String>? bullets,
  }) {
    return ExperienceItem(
      id: id ?? this.id,
      role: role ?? this.role,
      company: company ?? this.company,
      location: location ?? this.location,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isCurrent: isCurrent ?? this.isCurrent,
      bullets: bullets ?? this.bullets,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'role': role,
    'company': company,
    'location': location,
    'startDate': startDate,
    'endDate': endDate,
    'isCurrent': isCurrent,
    'bullets': bullets,
  };

  factory ExperienceItem.fromJson(Map<String, dynamic> json) {
    return ExperienceItem(
      id: json['id'] as String? ?? '',
      role: json['role'] as String? ?? '',
      company: json['company'] as String? ?? '',
      location: json['location'] as String? ?? '',
      startDate: json['startDate'] as String? ?? '',
      endDate: json['endDate'] as String? ?? '',
      isCurrent: json['isCurrent'] as bool? ?? false,
      bullets: (json['bullets'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExperienceItem &&
        other.id == id &&
        other.role == role &&
        other.company == company &&
        other.location == location &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.isCurrent == isCurrent &&
        listEquals(other.bullets, bullets);
  }

  @override
  int get hashCode => Object.hash(
    id,
    role,
    company,
    location,
    startDate,
    endDate,
    isCurrent,
    Object.hashAll(bullets),
  );
}
