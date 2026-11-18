import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../domain/models/ats_audit_result.dart';
import '../../resume_editor/providers/resume_providers.dart';

/// Live ATS compatibility scorecard powered reactively by [atsAuditProvider].
class AtsAuditView extends ConsumerWidget {
  const AtsAuditView({super.key});

  Color _scoreColor(int score, ColorScheme colors) {
    if (score >= 85) return const Color(0xFF15803D);
    if (score >= 65) return const Color(0xFFB45309);
    return colors.error;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audit = ref.watch(atsAuditProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final scoreColor = _scoreColor(audit.score, colors);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                SizedBox(
                  width: 84,
                  height: 84,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: audit.score / 100,
                        strokeWidth: 8,
                        backgroundColor: colors.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation(scoreColor),
                      ),
                      Center(
                        child: Text(
                          '${audit.score}',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: scoreColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        audit.ratingLabel,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: scoreColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${audit.wordCount} words • Est. ${audit.estimatedPages} page(s) • Single-column vector PDF',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _SummaryBadge(
                            label: '${audit.passedCount} Passed',
                            color: const Color(0xFF15803D),
                          ),
                          if (audit.warningCount > 0)
                            _SummaryBadge(
                              label: '${audit.warningCount} Warnings',
                              color: const Color(0xFFB45309),
                            ),
                          if (audit.criticalCount > 0)
                            _SummaryBadge(
                              label: '${audit.criticalCount} Critical',
                              color: colors.error,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'ATS Compliance Checklist',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        for (final check in audit.checks) ...[
          _AtsCheckTile(check: check),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _SummaryBadge extends StatelessWidget {
  const _SummaryBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _AtsCheckTile extends StatelessWidget {
  const _AtsCheckTile({required this.check});

  final AtsCheckItem check;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final (icon, tint) = switch (check.severity) {
      AtsCheckSeverity.pass => (
        Icons.check_circle_outline,
        const Color(0xFF15803D),
      ),
      AtsCheckSeverity.warning => (
        Icons.warning_amber_rounded,
        const Color(0xFFB45309),
      ),
      AtsCheckSeverity.critical => (Icons.error_outline, colors.error),
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: tint, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          check.title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        check.category,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    check.detail,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
