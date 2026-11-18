import 'package:flutter/foundation.dart';

enum AtsCheckSeverity { pass, warning, critical }

@immutable
class AtsCheckItem {
  const AtsCheckItem({
    required this.id,
    required this.category,
    required this.title,
    required this.detail,
    required this.severity,
    required this.weight,
  });

  final String id;
  final String category;
  final String title;
  final String detail;
  final AtsCheckSeverity severity;
  final int weight;
}

@immutable
class AtsAuditResult {
  const AtsAuditResult({
    required this.score,
    required this.checks,
    required this.wordCount,
    required this.estimatedPages,
  });

  final int score;
  final List<AtsCheckItem> checks;
  final int wordCount;
  final int estimatedPages;

  int get passedCount =>
      checks.where((c) => c.severity == AtsCheckSeverity.pass).length;
  int get warningCount =>
      checks.where((c) => c.severity == AtsCheckSeverity.warning).length;
  int get criticalCount =>
      checks.where((c) => c.severity == AtsCheckSeverity.critical).length;

  String get ratingLabel {
    if (score >= 90) return 'Excellent ATS Readiness';
    if (score >= 75) return 'Good ATS Readiness';
    if (score >= 55) return 'Needs Optimization';
    return 'High ATS Risk';
  }
}
