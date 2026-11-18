import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../domain/models/project_item.dart';
import '../../../../core/widgets/bullet_list_editor.dart';
import '../../../../core/widgets/section_card.dart';
import '../../providers/resume_providers.dart';

class ProjectsSectionForm extends ConsumerWidget {
  const ProjectsSectionForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(resumeProvider.select((r) => r.projects));
    final rev = ref.watch(formRevisionProvider);
    final notifier = ref.read(resumeProvider.notifier);

    return SectionCard(
      title: 'Featured Projects',
      subtitle: 'Highlight shipped apps, exact tech stack, and what you delivered',
      icon: Icons.rocket_launch_outlined,
      trailing: FilledButton.tonalIcon(
        onPressed: notifier.addProject,
        icon: const Icon(Icons.add, size: 18),
        label: const Text('Add Project'),
      ),
      child: projects.isEmpty
          ? const Text('No projects added yet. Tap "Add Project" to showcase key work.')
          : Column(
              children: [
                for (var i = 0; i < projects.length; i++) ...[
                  _ProjectCard(
                    key: ValueKey('${projects[i].id}_$rev'),
                    item: projects[i],
                    onChanged: notifier.updateProject,
                    onDelete: () => notifier.removeProject(projects[i].id),
                  ),
                  if (i < projects.length - 1) const SizedBox(height: 14),
                ],
              ],
            ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({
    super.key,
    required this.item,
    required this.onChanged,
    required this.onDelete,
  });

  final ProjectItem item;
  final ValueChanged<ProjectItem> onChanged;
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
                  initialValue: item.name,
                  decoration: const InputDecoration(
                    labelText: 'Project Name *',
                    hintText: 'e.g., FinoPay - Digital Banking App',
                  ),
                  onChanged: (v) => onChanged(item.copyWith(name: v)),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Delete project',
                onPressed: onDelete,
                icon: Icon(Icons.delete_outline, color: colors.error),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextFormField(
            initialValue: item.techStack,
            decoration: const InputDecoration(
              labelText: 'Tech Stack',
              hintText: 'e.g., Flutter, Dart, Riverpod, Firebase, REST APIs',
            ),
            onChanged: (v) => onChanged(item.copyWith(techStack: v)),
          ),
          const SizedBox(height: 10),
          TextFormField(
            initialValue: item.url,
            decoration: const InputDecoration(
              labelText: 'App Store / Play Store / GitHub URL (Optional)',
              hintText: 'https://play.google.com/store/apps/details?id=...',
            ),
            onChanged: (v) => onChanged(item.copyWith(url: v)),
          ),
          const Divider(height: 20),
          BulletListEditor(
            bullets: item.bullets,
            hintText: 'Describe what you built and the measurable impact',
            onChanged: (next) => onChanged(item.copyWith(bullets: next)),
          ),
        ],
      ),
    );
  }
}
