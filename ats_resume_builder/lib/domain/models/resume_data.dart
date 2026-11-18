import 'package:flutter/foundation.dart';

import 'education_item.dart';
import 'experience_item.dart';
import 'project_item.dart';
import 'resume_contact.dart';
import 'skill_group.dart';

/// Supported standard paper sizes for ATS PDF export.
enum ResumePageSize {
  a4('A4 (210 x 297 mm)'),
  letter('US Letter (8.5 x 11 in)');

  const ResumePageSize(this.label);
  final String label;
}

/// Complete immutable aggregate root representing a user's ATS resume.
@immutable
class ResumeData {
  const ResumeData({
    required this.contact,
    required this.summary,
    required this.skillGroups,
    required this.experiences,
    required this.projects,
    required this.education,
    this.pageSize = ResumePageSize.a4,
  });

  final ResumeContact contact;
  final String summary;
  final List<SkillGroup> skillGroups;
  final List<ExperienceItem> experiences;
  final List<ProjectItem> projects;
  final List<EducationItem> education;
  final ResumePageSize pageSize;

  factory ResumeData.empty() => ResumeData(
    contact: ResumeContact.empty(),
    summary: '',
    skillGroups: const [],
    experiences: const [],
    projects: const [],
    education: const [],
  );

  ResumeData copyWith({
    ResumeContact? contact,
    String? summary,
    List<SkillGroup>? skillGroups,
    List<ExperienceItem>? experiences,
    List<ProjectItem>? projects,
    List<EducationItem>? education,
    ResumePageSize? pageSize,
  }) {
    return ResumeData(
      contact: contact ?? this.contact,
      summary: summary ?? this.summary,
      skillGroups: skillGroups ?? this.skillGroups,
      experiences: experiences ?? this.experiences,
      projects: projects ?? this.projects,
      education: education ?? this.education,
      pageSize: pageSize ?? this.pageSize,
    );
  }

  Map<String, dynamic> toJson() => {
    'contact': contact.toJson(),
    'summary': summary,
    'skillGroups': skillGroups.map((e) => e.toJson()).toList(),
    'experiences': experiences.map((e) => e.toJson()).toList(),
    'projects': projects.map((e) => e.toJson()).toList(),
    'education': education.map((e) => e.toJson()).toList(),
    'pageSize': pageSize.name,
  };

  factory ResumeData.fromJson(Map<String, dynamic> json) {
    final pageSizeName = json['pageSize'] as String?;
    final parsedPageSize = ResumePageSize.values.firstWhere(
      (e) => e.name == pageSizeName,
      orElse: () => ResumePageSize.a4,
    );

    return ResumeData(
      contact: ResumeContact.fromJson(
        (json['contact'] as Map<String, dynamic>?) ?? const {},
      ),
      summary: json['summary'] as String? ?? '',
      skillGroups: (json['skillGroups'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(SkillGroup.fromJson)
          .toList(),
      experiences: (json['experiences'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(ExperienceItem.fromJson)
          .toList(),
      projects: (json['projects'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(ProjectItem.fromJson)
          .toList(),
      education: (json['education'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(EducationItem.fromJson)
          .toList(),
      pageSize: parsedPageSize,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ResumeData &&
        other.contact == contact &&
        other.summary == summary &&
        listEquals(other.skillGroups, skillGroups) &&
        listEquals(other.experiences, experiences) &&
        listEquals(other.projects, projects) &&
        listEquals(other.education, education) &&
        other.pageSize == pageSize;
  }

  @override
  int get hashCode => Object.hash(
    contact,
    summary,
    Object.hashAll(skillGroups),
    Object.hashAll(experiences),
    Object.hashAll(projects),
    Object.hashAll(education),
    pageSize,
  );
}
