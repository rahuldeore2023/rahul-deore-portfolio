import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../domain/models/experience_item.dart';
import '../../../../core/widgets/bullet_list_editor.dart';
import '../../../../core/widgets/section_card.dart';
import '../../providers/resume_providers.dart';

class ExperienceSectionForm extends ConsumerWidget {
  const ExperienceSectionForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final experiences = ref.watch(resumeProvider.select((r) => r.experiences));
    final rev = ref.watch(formRevisionProvider);
    final notifier = ref.read(resumeProvider.notifier);

    return SectionCard(
      title: 'Work Experience',
      subtitle: 'Reverse-chronological order, MMM YYYY dates, action-verb bullets',
      icon: Icons.work_outline,
      trailing: FilledButton.tonalIcon(
        onPressed: notifier.addExperience,
        icon: const Icon(Icons.add, size: 18),
        label: const Text('Add Role'),
      ),
      child: experiences.isEmpty
          ? const Text('No roles added yet. Tap "Add Role" to add experience.')
          : Column(
              children: [
                for (var i = 0; i < experiences.length; i++) ...[
                  _ExperienceCard(
                    key: ValueKey('${experiences[i].id}_$rev'),
                    item: experiences[i],
                    canMoveUp: i > 0,
                    canMoveDown: i < experiences.length - 1,
                    onMoveUp: () => notifier.moveExperience(i, i - 1),
                    onMoveDown: () => notifier.moveExperience(i, i + 1),
                    onChanged: notifier.updateExperience,
                    onDelete: () => notifier.removeExperience(experiences[i].id),
                  ),
                  if (i < experiences.length - 1) const SizedBox(height: 14),
                ],
              ],
            ),
    );
  }
}

class _ExperienceCard extends StatelessWidget {
  const _ExperienceCard({
    super.key,
    required this.item,
    required this.canMoveUp,
    required this.canMoveDown,
    required this.onMoveUp,
    required this.onMoveDown,
    required this.onChanged,
    required this.onDelete,
  });

  final ExperienceItem item;
  final bool canMoveUp;
  final bool canMoveDown;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;
  final ValueChanged<ExperienceItem> onChanged;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.role.trim().isEmpty
                      ? 'New Position'
                      : '${item.role} ${item.company.isNotEmpty ? '• ${item.company}' : ''}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                tooltip: 'Move up',
                onPressed: canMoveUp ? onMoveUp : null,
                icon: const Icon(Icons.arrow_upward, size: 18),
              ),
              IconButton(
                tooltip: 'Move down',
                onPressed: canMoveDown ? onMoveDown : null,
                icon: const Icon(Icons.arrow_downward, size: 18),
              ),
              IconButton(
                tooltip: 'Delete role',
                onPressed: onDelete,
                icon: Icon(Icons.delete_outline, color: colors.error, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: item.role,
            decoration: const InputDecoration(
              labelText: 'Job Title *',
              hintText: 'e.g., Senior Flutter & Android Developer',
            ),
            onChanged: (v) => onChanged(item.copyWith(role: v)),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: item.company,
                  decoration: const InputDecoration(
                    labelText: 'Company *',
                    hintText: 'e.g., Idealake Technologies',
                  ),
                  onChanged: (v) => onChanged(item.copyWith(company: v)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  initialValue: item.location,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    hintText: 'e.g., Mumbai, India',
                  ),
                  onChanged: (v) => onChanged(item.copyWith(location: v)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: item.startDate,
                  decoration: const InputDecoration(
                    labelText: 'Start Date (MMM YYYY)',
                    hintText: 'e.g., Jul 2025',
                  ),
                  onChanged: (v) => onChanged(item.copyWith(startDate: v)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  enabled: !item.isCurrent,
                  initialValue: item.isCurrent ? 'Present' : item.endDate,
                  decoration: const InputDecoration(
                    labelText: 'End Date (MMM YYYY)',
                    hintText: 'e.g., May 2025',
                  ),
                  onChanged: (v) => onChanged(item.copyWith(endDate: v)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            controlAffinity: ListTileControlAffinity.leading,
            title: const Text('I currently work here'),
            value: item.isCurrent,
            onChanged: (checked) => onChanged(
              item.copyWith(isCurrent: checked ?? false),
            ),
          ),
          const Divider(height: 16),
          BulletListEditor(
            bullets: item.bullets,
            onChanged: (nextBullets) =>
                onChanged(item.copyWith(bullets: nextBullets)),
          ),
        ],
      ),
    );
  }
}
