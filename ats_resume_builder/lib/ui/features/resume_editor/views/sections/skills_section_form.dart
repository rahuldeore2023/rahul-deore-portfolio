import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../domain/models/skill_group.dart';
import '../../../../core/widgets/section_card.dart';
import '../../providers/resume_providers.dart';

class SkillsSectionForm extends ConsumerWidget {
  const SkillsSectionForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(resumeProvider.select((r) => r.skillGroups));
    final rev = ref.watch(formRevisionProvider);
    final notifier = ref.read(resumeProvider.notifier);

    return SectionCard(
      title: 'Technical Skills',
      subtitle: 'Group skills by category with comma-separated values (no duplicates)',
      icon: Icons.code_outlined,
      trailing: FilledButton.tonalIcon(
        onPressed: () => notifier.addSkillGroup(),
        icon: const Icon(Icons.add, size: 18),
        label: const Text('Add Group'),
      ),
      child: groups.isEmpty
          ? const Text('No skill groups yet. Tap "Add Group" to start.')
          : Column(
              children: [
                for (var i = 0; i < groups.length; i++) ...[
                  _SkillGroupTile(
                    key: ValueKey('${groups[i].id}_$rev'),
                    group: groups[i],
                    onChanged: notifier.updateSkillGroup,
                    onDelete: () => notifier.removeSkillGroup(groups[i].id),
                  ),
                  if (i < groups.length - 1) const SizedBox(height: 12),
                ],
              ],
            ),
    );
  }
}

class _SkillGroupTile extends StatelessWidget {
  const _SkillGroupTile({
    super.key,
    required this.group,
    required this.onChanged,
    required this.onDelete,
  });

  final SkillGroup group;
  final ValueChanged<SkillGroup> onChanged;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
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
                  initialValue: group.category,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    hintText: 'e.g., Languages, Frameworks, Databases',
                  ),
                  onChanged: (v) => onChanged(group.copyWith(category: v)),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Delete skill group',
                onPressed: onDelete,
                icon: Icon(Icons.delete_outline, color: colors.error),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextFormField(
            initialValue: group.skills.join(', '),
            minLines: 1,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Skills (comma-separated)',
              hintText: 'e.g., Kotlin, Java, Dart',
            ),
            onChanged: (v) {
              final parsed = v
                  .split(',')
                  .map((s) => s.trim())
                  .where((s) => s.isNotEmpty)
                  .toList();
              onChanged(group.copyWith(skills: parsed));
            },
          ),
        ],
      ),
    );
  }
}
