import '../models/ats_audit_result.dart';
import '../models/resume_data.dart';

/// Evaluates a [ResumeData] object against real-world ATS parsing and
/// recruiter screening rules, returning a weighted 0-100 score and
/// actionable check results.
class AtsAuditUseCase {
  const AtsAuditUseCase();

  static final RegExp _emailRegex = RegExp(
    r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
  );
  static final RegExp _firstPersonRegex = RegExp(
    r'^\s*(i|my|me|we|our)\b',
    caseSensitive: false,
  );
  static final RegExp _metricRegex = RegExp(
    r'(\d+\s?%|\d+\+|\b\d+\s?(ms|s|x|k|m|users|downloads|apps|developers|engineers|team|clients|modules|screens|environments|releases)\b)',
    caseSensitive: false,
  );
  static final RegExp _monthYearRegex = RegExp(
    r'^(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\s+\d{4}$',
  );
  static final RegExp _missingSpaceAfterCommaRegex = RegExp(r',[A-Za-z]');

  AtsAuditResult evaluate(ResumeData resume) {
    final checks = <AtsCheckItem>[];

    // 1. Contact: Full Name & Headline
    final hasName = resume.contact.fullName.trim().isNotEmpty;
    final hasHeadline = resume.contact.headline.trim().isNotEmpty;
    checks.add(
      AtsCheckItem(
        id: 'contact_identity',
        category: 'Contact',
        title: 'Full Name & Target Role Headline',
        detail: hasName && hasHeadline
            ? 'Clear name and target headline help ATS index your seniority and domain.'
            : 'Add both your full name and a clear target role headline (e.g., Mobile App Developer | Flutter & Android).',
        severity: hasName && hasHeadline
            ? AtsCheckSeverity.pass
            : AtsCheckSeverity.critical,
        weight: 10,
      ),
    );

    // 2. Contact: Single Phone Number & Country Code
    final phone = resume.contact.phone.trim();
    final hasMultiplePhones = phone.contains('/') || phone.contains(',');
    final hasCountryCode = phone.startsWith('+');
    if (phone.isEmpty) {
      checks.add(
        const AtsCheckItem(
          id: 'contact_phone',
          category: 'Contact',
          title: 'Phone Number',
          detail: 'Add one primary phone number with country code (e.g., +91 96236 14907).',
          severity: AtsCheckSeverity.critical,
          weight: 8,
        ),
      );
    } else if (hasMultiplePhones) {
      checks.add(
        const AtsCheckItem(
          id: 'contact_phone',
          category: 'Contact',
          title: 'Single Primary Phone Number',
          detail: 'Avoid listing multiple numbers separated by "/" or "," — ATS parsers often merge or reject them.',
          severity: AtsCheckSeverity.critical,
          weight: 8,
        ),
      );
    } else if (!hasCountryCode) {
      checks.add(
        const AtsCheckItem(
          id: 'contact_phone',
          category: 'Contact',
          title: 'Phone Country Code',
          detail: 'Prefix your phone number with a country code (e.g., +91) for international ATS compatibility.',
          severity: AtsCheckSeverity.warning,
          weight: 8,
        ),
      );
    } else {
      checks.add(
        const AtsCheckItem(
          id: 'contact_phone',
          category: 'Contact',
          title: 'Phone Number Format',
          detail: 'Single phone number with country code parses reliably across ATS platforms.',
          severity: AtsCheckSeverity.pass,
          weight: 8,
        ),
      );
    }

    // 3. Contact: Email & Location
    final validEmail = _emailRegex.hasMatch(resume.contact.email.trim());
    final hasLocation = resume.contact.location.trim().isNotEmpty;
    checks.add(
      AtsCheckItem(
        id: 'contact_email_location',
        category: 'Contact',
        title: 'Valid Email & City/Country Location',
        detail: validEmail && hasLocation
            ? 'Email is valid and city/country location supports ATS geographic filters.'
            : !validEmail
                ? 'Provide a valid email address.'
                : 'Add your city and country (e.g., Mumbai, India) so location-based ATS filters match your profile.',
        severity: validEmail && hasLocation
            ? AtsCheckSeverity.pass
            : AtsCheckSeverity.critical,
        weight: 10,
      ),
    );

    // 4. Professional Summary
    final summaryWords = _countWords(resume.summary);
    if (summaryWords == 0) {
      checks.add(
        const AtsCheckItem(
          id: 'summary',
          category: 'Summary',
          title: 'Professional Summary',
          detail: 'Add a concise 40-90 word professional summary with core role keywords.',
          severity: AtsCheckSeverity.critical,
          weight: 10,
        ),
      );
    } else if (summaryWords < 30 || summaryWords > 110) {
      checks.add(
        AtsCheckItem(
          id: 'summary',
          category: 'Summary',
          title: 'Professional Summary Length',
          detail: 'Current summary is $summaryWords words. Aim for 35-100 words for ideal recruiter scan speed.',
          severity: AtsCheckSeverity.warning,
          weight: 10,
        ),
      );
    } else {
      checks.add(
        AtsCheckItem(
          id: 'summary',
          category: 'Summary',
          title: 'Professional Summary',
          detail: 'Well-sized ($summaryWords words) and placed under a standard heading.',
          severity: AtsCheckSeverity.pass,
          weight: 10,
        ),
      );
    }

    // 5. Skills: Categorization, Duplicates & Count
    final allSkills = resume.skillGroups
        .expand((g) => g.skills)
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final lowerSkills = allSkills.map((s) => s.toLowerCase()).toList();
    final uniqueSkills = lowerSkills.toSet();
    final hasDuplicates = uniqueSkills.length != lowerSkills.length;
    final hasUncategorized =
        resume.skillGroups.any((g) => g.category.trim().isEmpty);

    if (allSkills.length < 6) {
      checks.add(
        AtsCheckItem(
          id: 'skills_quality',
          category: 'Skills',
          title: 'Technical Skills Coverage',
          detail: 'Only ${allSkills.length} skills listed. Add at least 8-15 relevant technical skills grouped by category.',
          severity: AtsCheckSeverity.critical,
          weight: 12,
        ),
      );
    } else if (hasDuplicates || hasUncategorized) {
      checks.add(
        AtsCheckItem(
          id: 'skills_quality',
          category: 'Skills',
          title: 'Clean Categorized Skills',
          detail: hasDuplicates
              ? 'Duplicate skill entries detected. Deduplicate your skills list to avoid keyword stuffing flags.'
              : 'Give every skill group a clear category label (e.g., Languages, Frameworks, Databases).',
          severity: AtsCheckSeverity.warning,
          weight: 12,
        ),
      );
    } else {
      checks.add(
        AtsCheckItem(
          id: 'skills_quality',
          category: 'Skills',
          title: 'Clean Categorized Skills',
          detail: '${allSkills.length} unique skills cleanly organized into ${resume.skillGroups.length} categories.',
          severity: AtsCheckSeverity.pass,
          weight: 12,
        ),
      );
    }

    // 6. Experience Presence & Action-Verb Style (no first-person pronouns)
    final allExpBullets = resume.experiences
        .expand((e) => e.bullets)
        .map((b) => b.trim())
        .where((b) => b.isNotEmpty)
        .toList();
    final firstPersonBullets =
        allExpBullets.where((b) => _firstPersonRegex.hasMatch(b)).length;

    if (resume.experiences.isEmpty || allExpBullets.isEmpty) {
      checks.add(
        const AtsCheckItem(
          id: 'experience_bullets',
          category: 'Experience',
          title: 'Work Experience & Action Verbs',
          detail: 'Add your work history with 3-5 achievement bullets per role starting with strong action verbs.',
          severity: AtsCheckSeverity.critical,
          weight: 12,
        ),
      );
    } else if (firstPersonBullets > 0) {
      checks.add(
        AtsCheckItem(
          id: 'experience_bullets',
          category: 'Experience',
          title: 'Action-Verb Bullet Style',
          detail: '$firstPersonBullets bullet(s) start with first-person pronouns ("I", "My", "We"). Start bullets directly with action verbs (e.g., "Architected", "Led", "Optimized").',
          severity: AtsCheckSeverity.warning,
          weight: 12,
        ),
      );
    } else {
      checks.add(
        AtsCheckItem(
          id: 'experience_bullets',
          category: 'Experience',
          title: 'Action-Verb Bullet Style',
          detail: 'All ${allExpBullets.length} experience bullets avoid first-person pronouns.',
          severity: AtsCheckSeverity.pass,
          weight: 12,
        ),
      );
    }

    // 7. Quantified Impact Metrics
    final allBullets = [
      ...allExpBullets,
      ...resume.projects.expand((p) => p.bullets),
    ];
    final quantifiedCount =
        allBullets.where((b) => _metricRegex.hasMatch(b)).length;
    if (quantifiedCount == 0) {
      checks.add(
        const AtsCheckItem(
          id: 'quantified_impact',
          category: 'Impact',
          title: 'Quantified Achievements',
          detail: 'No measurable metrics found. Add concrete numbers (e.g., "reduced load time by 25%", "mentored 4 engineers", "99.5% crash-free sessions").',
          severity: AtsCheckSeverity.critical,
          weight: 10,
        ),
      );
    } else if (quantifiedCount < 3) {
      checks.add(
        AtsCheckItem(
          id: 'quantified_impact',
          category: 'Impact',
          title: 'Quantified Achievements',
          detail: 'Found $quantifiedCount quantified bullet(s). Aim for at least 3+ measurable outcomes across your roles.',
          severity: AtsCheckSeverity.warning,
          weight: 10,
        ),
      );
    } else {
      checks.add(
        AtsCheckItem(
          id: 'quantified_impact',
          category: 'Impact',
          title: 'Quantified Achievements',
          detail: '$quantifiedCount bullets include measurable metrics and outcomes.',
          severity: AtsCheckSeverity.pass,
          weight: 10,
        ),
      );
    }

    // 8. Standardized Date Format (MMM YYYY)
    final invalidDates = <String>[];
    for (final exp in resume.experiences) {
      final start = exp.startDate.trim();
      final end = exp.endDate.trim();
      if (start.isEmpty || !_monthYearRegex.hasMatch(start)) {
        invalidDates.add(start.isEmpty ? '(missing start)' : start);
      }
      if (!exp.isCurrent && (end.isEmpty || !_monthYearRegex.hasMatch(end))) {
        invalidDates.add(end.isEmpty ? '(missing end)' : end);
      }
    }
    checks.add(
      AtsCheckItem(
        id: 'date_format',
        category: 'Formatting',
        title: 'Standardized Dates (MMM YYYY)',
        detail: invalidDates.isEmpty && resume.experiences.isNotEmpty
            ? 'All employment dates follow the universal "MMM YYYY" format (e.g., Jul 2025 - Present).'
            : 'Use "MMM YYYY" format (e.g., Jul 2025) for all dates. Check: ${invalidDates.take(3).join(', ')}.',
        severity: invalidDates.isEmpty && resume.experiences.isNotEmpty
            ? AtsCheckSeverity.pass
            : AtsCheckSeverity.warning,
        weight: 8,
      ),
    );

    // 9. Comma-Spacing Hygiene (Tokenization Safety)
    final fullText = _collectAllText(resume);
    final hasSpacingGlitch = _missingSpaceAfterCommaRegex.hasMatch(fullText);
    checks.add(
      AtsCheckItem(
        id: 'punctuation_spacing',
        category: 'Formatting',
        title: 'Keyword Tokenization & Spacing',
        detail: hasSpacingGlitch
            ? 'Missing space after a comma detected (e.g., "Coroutine,Firebase"). Add spaces after commas so ATS tokenizers index every keyword separately.'
            : 'No comma-spacing glitches detected — keywords tokenize cleanly.',
        severity: hasSpacingGlitch
            ? AtsCheckSeverity.warning
            : AtsCheckSeverity.pass,
        weight: 8,
      ),
    );

    // 10. Education Completeness
    final hasEducation = resume.education.isNotEmpty;
    final incompleteEducation = resume.education.any(
      (e) =>
          e.degree.trim().isEmpty ||
          e.institution.trim().isEmpty ||
          e.graduationYear.trim().isEmpty,
    );
    checks.add(
      AtsCheckItem(
        id: 'education_complete',
        category: 'Education',
        title: 'Education Completeness',
        detail: !hasEducation
            ? 'Add at least one education entry with degree, institution, and graduation year.'
            : incompleteEducation
                ? 'One or more education entries are missing a degree, institution, or graduation year.'
                : 'Education entries are complete with clean degree names and graduation years.',
        severity: !hasEducation
            ? AtsCheckSeverity.critical
            : incompleteEducation
                ? AtsCheckSeverity.warning
                : AtsCheckSeverity.pass,
        weight: 6,
      ),
    );

    // 11. Page Length Estimate
    final wordCount = _countWords(fullText);
    final estimatedPages = wordCount == 0 ? 1 : ((wordCount / 480).ceil()).clamp(1, 5);
    checks.add(
      AtsCheckItem(
        id: 'length_check',
        category: 'Length',
        title: 'Optimal Resume Length (1-2 Pages)',
        detail: estimatedPages <= 2
            ? 'Estimated $estimatedPages page(s) ($wordCount words) — ideal for ATS and recruiter review.'
            : 'Estimated $estimatedPages pages ($wordCount words). Tighten older bullets to fit within 2 pages.',
        severity: estimatedPages <= 2
            ? AtsCheckSeverity.pass
            : AtsCheckSeverity.warning,
        weight: 6,
      ),
    );

    // Compute weighted score
    var totalWeight = 0;
    var earnedScore = 0.0;
    for (final check in checks) {
      totalWeight += check.weight;
      switch (check.severity) {
        case AtsCheckSeverity.pass:
          earnedScore += check.weight;
        case AtsCheckSeverity.warning:
          earnedScore += check.weight * 0.5;
        case AtsCheckSeverity.critical:
          earnedScore += 0;
      }
    }

    final normalizedScore =
        totalWeight == 0 ? 0 : ((earnedScore / totalWeight) * 100).round();

    return AtsAuditResult(
      score: normalizedScore.clamp(0, 100),
      checks: checks,
      wordCount: wordCount,
      estimatedPages: estimatedPages,
    );
  }

  String _collectAllText(ResumeData resume) {
    final buffer = StringBuffer()
      ..writeln(resume.contact.fullName)
      ..writeln(resume.contact.headline)
      ..writeln(resume.contact.location)
      ..writeln(resume.summary);

    for (final g in resume.skillGroups) {
      buffer
        ..writeln(g.category)
        ..writeln(g.skills.join(', '));
    }
    for (final e in resume.experiences) {
      buffer
        ..writeln(e.role)
        ..writeln(e.company)
        ..writeln(e.location);
      for (final b in e.bullets) {
        buffer.writeln(b);
      }
    }
    for (final p in resume.projects) {
      buffer
        ..writeln(p.name)
        ..writeln(p.techStack);
      for (final b in p.bullets) {
        buffer.writeln(b);
      }
    }
    for (final ed in resume.education) {
      buffer
        ..writeln(ed.degree)
        ..writeln(ed.institution)
        ..writeln(ed.graduationYear);
    }
    return buffer.toString();
  }

  int _countWords(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return 0;
    return trimmed.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
  }
}
