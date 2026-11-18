import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../domain/models/education_item.dart';
import '../../domain/models/experience_item.dart';
import '../../domain/models/project_item.dart';
import '../../domain/models/resume_data.dart';
import '../../domain/models/skill_group.dart';

/// Generates a strictly ATS-compliant, single-column, vector-text PDF resume.
///
/// Design choices optimized for ATS parsing and clean pagination:
/// - Single-column linear reading order (no multi-column tables or text boxes)
/// - Standard PDF Helvetica font (universally readable, zero glyph-mapping issues)
/// - Standard uppercase section headers (PROFESSIONAL SUMMARY, TECHNICAL SKILLS,
///   EXPERIENCE, PROJECTS, EDUCATION)
/// - Standard ASCII bullet characters (`-`) and clean spacing
/// - Zero embedded images, icons, skill bars, or decorative headers/footers
/// - Uses [pw.Inseparable] blocks so section headers, job titles, companies,
///   projects, and education entries never split awkwardly across page breaks
class AtsPdfGenerator {
  const AtsPdfGenerator();

  static const PdfColor _primaryText = PdfColor.fromInt(0xFF111827);
  static const PdfColor _secondaryText = PdfColor.fromInt(0xFF374151);
  static const PdfColor _ruleColor = PdfColor.fromInt(0xFF9CA3AF);

  /// Maximum bullets kept together in one indivisible block with the entry header.
  static const int _maxAtomicBullets = 6;

  Future<Uint8List> generate(ResumeData resume) async {
    final regularFont = pw.Font.helvetica();
    final boldFont = pw.Font.helveticaBold();
    final italicFont = pw.Font.helveticaOblique();

    final pdf = pw.Document(
      title: resume.contact.fullName.isEmpty
          ? 'ATS Resume'
          : '${resume.contact.fullName} - Resume',
      author: resume.contact.fullName,
      creator: 'ATS Resume Builder (Flutter + Riverpod)',
      subject: resume.contact.headline,
    );

    final pageFormat = resume.pageSize == ResumePageSize.letter
        ? PdfPageFormat.letter
        : PdfPageFormat.a4;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        margin: const pw.EdgeInsets.symmetric(horizontal: 38, vertical: 34),
        theme: pw.ThemeData.withFont(
          base: regularFont,
          bold: boldFont,
          italic: italicFont,
        ),
        build: (context) => [
          pw.Inseparable(child: _buildHeader(resume)),
          ..._buildSummarySection(resume.summary),
          ..._buildSkillsSection(resume.skillGroups),
          ..._buildExperienceSection(resume.experiences),
          ..._buildProjectsSection(resume.projects),
          ..._buildEducationSection(resume.education),
        ],
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildHeader(ResumeData resume) {
    final c = resume.contact;
    final contactParts = <String>[
      if (c.location.trim().isNotEmpty) c.location.trim(),
      if (c.phone.trim().isNotEmpty) c.phone.trim(),
      if (c.email.trim().isNotEmpty) c.email.trim(),
    ];
    final linkParts = <String>[
      if (c.linkedInUrl.trim().isNotEmpty) c.linkedInUrl.trim(),
      if (c.portfolioOrGithubUrl.trim().isNotEmpty)
        c.portfolioOrGithubUrl.trim(),
    ];

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          c.fullName.trim().isEmpty ? 'YOUR NAME' : c.fullName.trim(),
          style: pw.TextStyle(
            fontSize: 20,
            fontWeight: pw.FontWeight.bold,
            color: _primaryText,
          ),
        ),
        if (c.headline.trim().isNotEmpty) ...[
          pw.SizedBox(height: 3),
          pw.Text(
            c.headline.trim(),
            style: pw.TextStyle(
              fontSize: 10.5,
              fontWeight: pw.FontWeight.bold,
              color: _secondaryText,
            ),
          ),
        ],
        if (contactParts.isNotEmpty) ...[
          pw.SizedBox(height: 4),
          pw.Text(
            contactParts.join('  |  '),
            style: const pw.TextStyle(fontSize: 9.2, color: _primaryText),
          ),
        ],
        if (linkParts.isNotEmpty) ...[
          pw.SizedBox(height: 2),
          pw.Text(
            linkParts.join('  |  '),
            style: const pw.TextStyle(fontSize: 9.0, color: _secondaryText),
          ),
        ],
        pw.SizedBox(height: 10),
      ],
    );
  }

  pw.Widget _buildSectionHeader(String title) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 10.5,
            fontWeight: pw.FontWeight.bold,
            letterSpacing: 0.6,
            color: _primaryText,
          ),
        ),
        pw.SizedBox(height: 2),
        pw.Container(height: 0.8, color: _ruleColor),
        pw.SizedBox(height: 5),
      ],
    );
  }

  /// Keeps a section header glued to its first content widget so headings are
  /// never orphaned at the bottom of a page.
  pw.Widget _keepHeaderWithFirst(String title, pw.Widget firstWidget) {
    return pw.Inseparable(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(title),
          firstWidget,
        ],
      ),
    );
  }

  List<pw.Widget> _buildSummarySection(String summary) {
    final trimmed = summary.trim();
    if (trimmed.isEmpty) return const [];

    final summaryText = pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Text(
        trimmed,
        style: const pw.TextStyle(
          fontSize: 9.8,
          lineSpacing: 2.2,
          color: _primaryText,
        ),
      ),
    );

    if (trimmed.length <= 2000) {
      return [_keepHeaderWithFirst('PROFESSIONAL SUMMARY', summaryText)];
    }

    return [
      _buildSectionHeader('PROFESSIONAL SUMMARY'),
      summaryText,
    ];
  }

  List<pw.Widget> _buildSkillsSection(List<SkillGroup> groups) {
    final nonEmpty = groups.where((g) => g.skills.isNotEmpty).toList();
    if (nonEmpty.isEmpty) return const [];

    return [
      _keepHeaderWithFirst('TECHNICAL SKILLS', _buildSkillLine(nonEmpty.first)),
      ...nonEmpty.skip(1).map((g) => pw.Inseparable(child: _buildSkillLine(g))),
      pw.SizedBox(height: 8),
    ];
  }

  pw.Widget _buildSkillLine(SkillGroup group) {
    final cleanSkills = group.skills
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .join(', ');
    final category = group.category.trim();

    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 3),
      child: pw.RichText(
        text: pw.TextSpan(
          style: const pw.TextStyle(
            fontSize: 9.5,
            lineSpacing: 1.8,
            color: _primaryText,
          ),
          children: [
            if (category.isNotEmpty)
              pw.TextSpan(
                text: '$category: ',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            pw.TextSpan(text: cleanSkills),
          ],
        ),
      ),
    );
  }

  List<pw.Widget> _buildExperienceSection(List<ExperienceItem> items) {
    if (items.isEmpty) return const [];

    final widgets = <pw.Widget>[];
    for (var i = 0; i < items.length; i++) {
      final blocks = _buildExperienceBlocks(items[i]);
      if (i == 0) {
        widgets.add(_keepHeaderWithFirst('EXPERIENCE', blocks.first));
        widgets.addAll(blocks.skip(1));
      } else {
        widgets.addAll(blocks);
      }
    }
    return widgets;
  }

  /// Keeps normal-length experience items completely intact on one page.
  /// For unusually long roles (> [_maxAtomicBullets] bullets), keeps the role
  /// title, company, and first 2 bullets inseparable while allowing extra
  /// bullets to wrap cleanly across pages without overflowing.
  List<pw.Widget> _buildExperienceBlocks(ExperienceItem item) {
    final cleanBullets = item.bullets
        .map((b) => b.trim())
        .where((b) => b.isNotEmpty)
        .toList();

    final headerWidget = _buildExperienceHeader(item);

    if (cleanBullets.length <= _maxAtomicBullets) {
      return [
        pw.Inseparable(
          child: pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 9),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                headerWidget,
                if (cleanBullets.isNotEmpty) ...[
                  pw.SizedBox(height: 3.5),
                  ...cleanBullets.map(_buildBullet),
                ],
              ],
            ),
          ),
        ),
      ];
    }

    final leadingBullets = cleanBullets.take(2).toList();
    final trailingBullets = cleanBullets.skip(2).toList();

    return [
      pw.Inseparable(
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            headerWidget,
            pw.SizedBox(height: 3.5),
            ...leadingBullets.map(_buildBullet),
          ],
        ),
      ),
      ...trailingBullets.map((b) => pw.Inseparable(child: _buildBullet(b))),
      pw.SizedBox(height: 9),
    ];
  }

  pw.Widget _buildExperienceHeader(ExperienceItem item) {
    final dateText = item.formattedDateRange;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Expanded(
              child: pw.Text(
                item.role.trim(),
                style: pw.TextStyle(
                  fontSize: 10.2,
                  fontWeight: pw.FontWeight.bold,
                  color: _primaryText,
                ),
              ),
            ),
            if (dateText.isNotEmpty)
              pw.Text(
                dateText,
                style: pw.TextStyle(
                  fontSize: 9.2,
                  fontWeight: pw.FontWeight.bold,
                  color: _secondaryText,
                ),
              ),
          ],
        ),
        pw.SizedBox(height: 1.5),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Expanded(
              child: pw.Text(
                item.company.trim(),
                style: pw.TextStyle(
                  fontSize: 9.5,
                  fontStyle: pw.FontStyle.italic,
                  color: _secondaryText,
                ),
              ),
            ),
            if (item.location.trim().isNotEmpty)
              pw.Text(
                item.location.trim(),
                style: const pw.TextStyle(
                  fontSize: 9.2,
                  color: _secondaryText,
                ),
              ),
          ],
        ),
      ],
    );
  }

  List<pw.Widget> _buildProjectsSection(List<ProjectItem> items) {
    if (items.isEmpty) return const [];

    final widgets = <pw.Widget>[];
    for (var i = 0; i < items.length; i++) {
      final blocks = _buildProjectBlocks(items[i]);
      if (i == 0) {
        widgets.add(_keepHeaderWithFirst('PROJECTS', blocks.first));
        widgets.addAll(blocks.skip(1));
      } else {
        widgets.addAll(blocks);
      }
    }
    return widgets;
  }

  List<pw.Widget> _buildProjectBlocks(ProjectItem item) {
    final cleanBullets = item.bullets
        .map((b) => b.trim())
        .where((b) => b.isNotEmpty)
        .toList();

    final headerWidget = _buildProjectHeader(item);

    if (cleanBullets.length <= _maxAtomicBullets) {
      return [
        pw.Inseparable(
          child: pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 8),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                headerWidget,
                if (cleanBullets.isNotEmpty) ...[
                  pw.SizedBox(height: 3),
                  ...cleanBullets.map(_buildBullet),
                ],
              ],
            ),
          ),
        ),
      ];
    }

    final leadingBullets = cleanBullets.take(2).toList();
    final trailingBullets = cleanBullets.skip(2).toList();

    return [
      pw.Inseparable(
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            headerWidget,
            pw.SizedBox(height: 3),
            ...leadingBullets.map(_buildBullet),
          ],
        ),
      ),
      ...trailingBullets.map((b) => pw.Inseparable(child: _buildBullet(b))),
      pw.SizedBox(height: 8),
    ];
  }

  pw.Widget _buildProjectHeader(ProjectItem item) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          item.name.trim(),
          style: pw.TextStyle(
            fontSize: 10.0,
            fontWeight: pw.FontWeight.bold,
            color: _primaryText,
          ),
        ),
        if (item.techStack.trim().isNotEmpty) ...[
          pw.SizedBox(height: 1.5),
          pw.RichText(
            text: pw.TextSpan(
              style: const pw.TextStyle(
                fontSize: 9.2,
                color: _secondaryText,
              ),
              children: [
                pw.TextSpan(
                  text: 'Tech Stack: ',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.TextSpan(text: item.techStack.trim()),
              ],
            ),
          ),
        ],
        if (item.url.trim().isNotEmpty) ...[
          pw.SizedBox(height: 1.5),
          pw.Text(
            item.url.trim(),
            style: const pw.TextStyle(fontSize: 8.8, color: _secondaryText),
          ),
        ],
      ],
    );
  }

  List<pw.Widget> _buildEducationSection(List<EducationItem> items) {
    if (items.isEmpty) return const [];

    return [
      _keepHeaderWithFirst('EDUCATION', _buildEducationItem(items.first)),
      ...items.skip(1).map((e) => pw.Inseparable(child: _buildEducationItem(e))),
    ];
  }

  pw.Widget _buildEducationItem(EducationItem item) {
    final subParts = <String>[
      if (item.institution.trim().isNotEmpty) item.institution.trim(),
      if (item.location.trim().isNotEmpty) item.location.trim(),
      if (item.grade.trim().isNotEmpty) 'Grade: ${item.grade.trim()}',
    ];

    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Expanded(
                child: pw.Text(
                  item.degree.trim(),
                  style: pw.TextStyle(
                    fontSize: 9.8,
                    fontWeight: pw.FontWeight.bold,
                    color: _primaryText,
                  ),
                ),
              ),
              if (item.graduationYear.trim().isNotEmpty)
                pw.Text(
                  item.graduationYear.trim(),
                  style: pw.TextStyle(
                    fontSize: 9.2,
                    fontWeight: pw.FontWeight.bold,
                    color: _secondaryText,
                  ),
                ),
            ],
          ),
          if (subParts.isNotEmpty) ...[
            pw.SizedBox(height: 1.5),
            pw.Text(
              subParts.join('  |  '),
              style: const pw.TextStyle(fontSize: 9.2, color: _secondaryText),
            ),
          ],
        ],
      ),
    );
  }

  pw.Widget _buildBullet(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(left: 8, bottom: 2.2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 10,
            child: pw.Text(
              '-',
              style: pw.TextStyle(
                fontSize: 9.5,
                fontWeight: pw.FontWeight.bold,
                color: _primaryText,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              text,
              style: const pw.TextStyle(
                fontSize: 9.5,
                lineSpacing: 1.8,
                color: _primaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
