import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../domain/models/education_item.dart';
import '../../../../core/widgets/section_card.dart';
import '../../providers/resume_providers.dart';

class EducationSectionForm extends ConsumerWidget {
  const EducationSectionForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final education = ref.watch(resumeProvider.select((r) => r.education));
    final rev = ref.watch(formRevisionProvider);
    final notifier = ref.read(resumeProvider.notifier);

    return SectionCard(
      title: 'Education',
      subtitle: 'Standard degree names; empty optional fields are automatically hidden in PDF',
      icon: Icons.school_outlined,
      trailing: FilledButton.tonalIcon(
        onPressed: notifier.addEducation,
        icon: const Icon(Icons.add, size: 18),
        label: const Text('Add Degree'),
      ),
      child: education.isEmpty
          ? const Text('No education entries yet. Tap "Add Degree" to add one.')
          : Column(
              children: [
                for (var i = 0; i < education.length; i++) ...[
                  _EducationCard(
                    key: ValueKey('${education[i].id}_$rev'),
                    item: education[i],
                    onChanged: notifier.updateEducation,
                    onDelete: () => notifier.removeEducation(education[i].id),
                  ),
                  if (i < education.length - 1) const SizedBox(height: 12),
                ],
              ],
            ),
    );
  }
}

class _EducationCard extends StatelessWidget {
  const _EducationCard({
    super.key,
    required this.item,
    required this.onChanged,
    required this.onDelete,
  });

  final EducationItem item;
  final ValueChanged<EducationItem> onChanged;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: item.degree,
                  decoration: const InputDecoration(
                    labelText: 'Degree *',
                    hintText: 'e.g., M.Sc. in Computer Science',
                  ),
                  onChanged: (v) => onChanged(item.copyWith(degree: v)),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Delete education',
                onPressed: onDelete,
                icon: Icon(Icons.delete_outline, color: colors.error),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextFormField(
            initialValue: item.institution,
            decoration: const InputDecoration(
              labelText: 'Institution *',
              hintText: 'e.g., Dr. D Y Patil ACS College',
            ),
            onChanged: (v) => onChanged(item.copyWith(institution: v)),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: item.location,
                  decoration: const InputDecoration(
                    labelText: 'Location (Optional)',
                    hintText: 'e.g., Pune, India',
                  ),
                  onChanged: (v) => onChanged(item.copyWith(location: v)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  initialValue: item.graduationYear,
                  decoration: const InputDecoration(
                    labelText: 'Graduation Year *',
                    hintText: 'e.g., 2018',
                  ),
                  onChanged: (v) =>
                      onChanged(item.copyWith(graduationYear: v)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  initialValue: item.grade,
                  decoration: const InputDecoration(
                    labelText: 'Grade / CGPA (Optional)',
                    hintText: 'e.g., 8.5 CGPA',
                  ),
                  onChanged: (v) => onChanged(item.copyWith(grade: v)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
