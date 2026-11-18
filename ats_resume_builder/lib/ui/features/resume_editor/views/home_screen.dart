import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

import '../../ats_audit/views/ats_audit_view.dart';
import '../../pdf_preview/views/ats_pdf_preview_view.dart';
import '../providers/resume_providers.dart';
import 'resume_editor_view.dart';

enum _MenuAction { exportJson, importJson, resetSample, clearAll }

/// Responsive root screen:
/// - Wide screens (>= 960px): Side-by-side Editor + Live PDF/ATS Preview pane.
/// - Compact screens (< 960px): Bottom NavigationBar switching Editor, Audit, PDF.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _exportPdf(BuildContext context, WidgetRef ref) async {
    final resume = ref.read(resumeProvider);
    final generator = ref.read(atsPdfGeneratorProvider);
    final bytes = await generator.generate(resume);
    final name = resume.contact.fullName.trim().isEmpty
        ? 'ATS_Resume.pdf'
        : '${resume.contact.fullName.trim().replaceAll(RegExp(r'\s+'), '_')}_ATS_Resume.pdf';

    await Printing.sharePdf(bytes: bytes, filename: name);
  }

  Future<void> _handleMenuAction(
    BuildContext context,
    WidgetRef ref,
    _MenuAction action,
  ) async {
    final notifier = ref.read(resumeProvider.notifier);
    final revisionNotifier = ref.read(formRevisionProvider.notifier);

    switch (action) {
      case _MenuAction.exportJson:
        final json = notifier.exportPrettyJson();
        await Clipboard.setData(ClipboardData(text: json));
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Resume JSON copied to clipboard.'),
            ),
          );
        }
      case _MenuAction.importJson:
        await _showImportJsonDialog(context, ref);
      case _MenuAction.resetSample:
        await notifier.resetToSample();
        revisionNotifier.bump();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Loaded ATS-optimized sample resume.'),
            ),
          );
        }
      case _MenuAction.clearAll:
        await notifier.clearResume();
        revisionNotifier.bump();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cleared all resume fields.'),
            ),
          );
        }
    }
  }

  Future<void> _showImportJsonDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final controller = TextEditingController();
    final imported = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Import Resume JSON'),
        content: SizedBox(
          width: 480,
          child: TextField(
            controller: controller,
            minLines: 6,
            maxLines: 12,
            decoration: const InputDecoration(
              hintText: 'Paste previously exported resume JSON here...',
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              try {
                ref
                    .read(resumeProvider.notifier)
                    .importFromJson(controller.text);
                ref.read(formRevisionProvider.notifier).bump();
                Navigator.of(dialogContext).pop(true);
              } catch (e) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(content: Text('Invalid JSON: $e')),
                );
              }
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );
    controller.dispose();

    if (imported == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Resume imported successfully.')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audit = ref.watch(atsAuditProvider);
    final selectedTab = ref.watch(selectedTabProvider);
    final desktopRightTab = ref.watch(desktopPreviewTabProvider);
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 960;
    final isCompactBar = width < 600;

    final scoreColor = audit.score >= 85
        ? const Color(0xFF15803D)
        : audit.score >= 65
            ? const Color(0xFFB45309)
            : Theme.of(context).colorScheme.error;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ATS Resume Builder',
          style: TextStyle(fontWeight: FontWeight.w700),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                if (isWide) {
                  ref.read(desktopPreviewTabProvider.notifier).select(1);
                } else {
                  ref.read(selectedTabProvider.notifier).select(1);
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isCompactBar ? 8 : 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: scoreColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: scoreColor.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.verified_user_outlined,
                      size: 16,
                      color: scoreColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isCompactBar
                          ? 'ATS ${audit.score}'
                          : 'ATS ${audit.score}/100',
                      style: TextStyle(
                        color: scoreColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          if (isCompactBar)
            IconButton(
              tooltip: 'Export ATS PDF',
              onPressed: () => _exportPdf(context, ref),
              icon: const Icon(Icons.picture_as_pdf_outlined),
            )
          else
            FilledButton.icon(
              onPressed: () => _exportPdf(context, ref),
              icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
              label: const Text('Export PDF'),
            ),
          PopupMenuButton<_MenuAction>(
            tooltip: 'More options',
            onSelected: (action) => _handleMenuAction(context, ref, action),
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: _MenuAction.exportJson,
                child: ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.copy_all_outlined),
                  title: Text('Copy Resume JSON'),
                ),
              ),
              PopupMenuItem(
                value: _MenuAction.importJson,
                child: ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.file_upload_outlined),
                  title: Text('Import Resume JSON'),
                ),
              ),
              PopupMenuDivider(),
              PopupMenuItem(
                value: _MenuAction.resetSample,
                child: ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.restore_outlined),
                  title: Text('Reset to ATS Sample'),
                ),
              ),
              PopupMenuItem(
                value: _MenuAction.clearAll,
                child: ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.delete_sweep_outlined),
                  title: Text('Clear All Fields'),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: isWide
          ? Row(
              children: [
                const Expanded(
                  flex: 6,
                  child: ResumeEditorView(),
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: SegmentedButton<int>(
                          segments: [
                            const ButtonSegment(
                              value: 0,
                              icon: Icon(Icons.picture_as_pdf_outlined),
                              label: Text('Live ATS PDF'),
                            ),
                            ButtonSegment(
                              value: 1,
                              icon: const Icon(Icons.fact_check_outlined),
                              label: Text('ATS Audit (${audit.score})'),
                            ),
                          ],
                          selected: {desktopRightTab},
                          onSelectionChanged: (sel) {
                            if (sel.isNotEmpty) {
                              ref
                                  .read(desktopPreviewTabProvider.notifier)
                                  .select(sel.first);
                            }
                          },
                        ),
                      ),
                      const Divider(height: 1),
                      Expanded(
                        child: desktopRightTab == 0
                            ? const AtsPdfPreviewView()
                            : const AtsAuditView(),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : switch (selectedTab) {
              0 => const ResumeEditorView(),
              1 => const AtsAuditView(),
              _ => const AtsPdfPreviewView(),
            },
      bottomNavigationBar: isWide
          ? null
          : NavigationBar(
              selectedIndex: selectedTab,
              onDestinationSelected: (idx) =>
                  ref.read(selectedTabProvider.notifier).select(idx),
              destinations: [
                const NavigationDestination(
                  icon: Icon(Icons.edit_document),
                  label: 'Editor',
                ),
                NavigationDestination(
                  icon: Badge(
                    isLabelVisible:
                        audit.criticalCount + audit.warningCount > 0,
                    label: Text('${audit.criticalCount + audit.warningCount}'),
                    child: const Icon(Icons.fact_check_outlined),
                  ),
                  label: 'ATS Audit',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.picture_as_pdf_outlined),
                  label: 'PDF Preview',
                ),
              ],
            ),
    );
  }
}
