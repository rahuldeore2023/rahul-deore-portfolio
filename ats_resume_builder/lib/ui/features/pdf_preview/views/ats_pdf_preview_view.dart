import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../../../../domain/models/resume_data.dart';
import '../../resume_editor/providers/resume_providers.dart';

/// Live ATS-compliant vector PDF preview with built-in print and share actions.
class AtsPdfPreviewView extends ConsumerWidget {
  const AtsPdfPreviewView({super.key});

  String _safeFileName(ResumeData resume) {
    final base = resume.contact.fullName.trim().isEmpty
        ? 'ATS_Resume'
        : resume.contact.fullName.trim().replaceAll(RegExp(r'\s+'), '_');
    return '${base}_ATS_Resume.pdf';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resume = ref.watch(resumeProvider);
    final generator = ref.watch(atsPdfGeneratorProvider);
    final colors = Theme.of(context).colorScheme;

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: colors.primaryContainer.withValues(alpha: 0.45),
            border: Border(
              bottom: BorderSide(color: colors.outlineVariant),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.verified_outlined,
                size: 18,
                color: colors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'ATS-Safe Output: Single-column linear text • Standard Helvetica • Zero tables or images',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: PdfPreview(
            key: ValueKey(resume.hashCode),
            build: (_) => generator.generate(resume),
            pdfFileName: _safeFileName(resume),
            initialPageFormat: resume.pageSize == ResumePageSize.letter
                ? PdfPageFormat.letter
                : PdfPageFormat.a4,
            canChangeOrientation: false,
            canChangePageFormat: false,
            canDebug: false,
            allowPrinting: true,
            allowSharing: true,
          ),
        ),
      ],
    );
  }
}
