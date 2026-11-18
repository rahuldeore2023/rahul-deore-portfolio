import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/section_card.dart';
import '../../providers/resume_providers.dart';

class SummarySectionForm extends ConsumerWidget {
  const SummarySectionForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(resumeProvider.select((r) => r.summary));
    final rev = ref.watch(formRevisionProvider);
    final notifier = ref.read(resumeProvider.notifier);

    final wordCount = summary.trim().isEmpty
        ? 0
        : summary.trim().split(RegExp(r'\s+')).length;

    return SectionCard(
      title: 'Professional Summary',
      subtitle: 'Aim for 40-90 words rich in target role keywords ($wordCount words)',
      icon: Icons.subject_outlined,
      child: TextFormField(
        key: ValueKey('summary_$rev'),
        initialValue: summary,
        minLines: 4,
        maxLines: 7,
        decoration: const InputDecoration(
          hintText:
              'Summarize years of experience, core tech stack, architecture strengths, and domain impact...',
        ),
        onChanged: notifier.updateSummary,
      ),
    );
  }
}
