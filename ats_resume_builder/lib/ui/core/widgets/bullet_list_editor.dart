import 'package:flutter/material.dart';

/// Editable list of achievement bullets encouraging action-verb phrasing.
class BulletListEditor extends StatelessWidget {
  const BulletListEditor({
    super.key,
    required this.bullets,
    required this.onChanged,
    this.hintText = 'Start with an action verb & add a metric (e.g., Reduced load time by 25%)',
  });

  final List<String> bullets;
  final ValueChanged<List<String>> onChanged;
  final String hintText;

  void _updateAt(int index, String value) {
    final updated = [...bullets];
    updated[index] = value;
    onChanged(updated);
  }

  void _removeAt(int index) {
    final updated = [...bullets]..removeAt(index);
    onChanged(updated);
  }

  void _addBullet() {
    onChanged([...bullets, '']);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Achievement Bullets',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton.icon(
              onPressed: _addBullet,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Bullet'),
            ),
          ],
        ),
        const SizedBox(height: 4),
        for (var i = 0; i < bullets.length; i++) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10, right: 8),
                  child: Text(
                    '•',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: TextFormField(
                    key: ValueKey('bullet_${i}_${bullets.length}'),
                    initialValue: bullets[i],
                    minLines: 1,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: hintText,
                      hintStyle: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    onChanged: (val) => _updateAt(i, val),
                  ),
                ),
                IconButton(
                  tooltip: 'Remove bullet',
                  onPressed: () => _removeAt(i),
                  icon: const Icon(Icons.delete_outline, size: 20),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
