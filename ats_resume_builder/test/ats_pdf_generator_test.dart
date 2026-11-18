import 'dart:convert';

import 'package:ats_resume_builder/data/services/ats_pdf_generator.dart';
import 'package:ats_resume_builder/data/services/sample_resume_data.dart';
import 'package:ats_resume_builder/domain/models/experience_item.dart';
import 'package:ats_resume_builder/domain/models/resume_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const generator = AtsPdfGenerator();

  group('AtsPdfGenerator', () {
    test('generates valid A4 PDF bytes for sample resume', () async {
      final sample = SampleResumeData.createDefault();
      final bytes = await generator.generate(sample);

      expect(bytes, isNotEmpty);
      final header = ascii.decode(bytes.take(5).toList());
      expect(header, equals('%PDF-'));
    });

    test('generates valid US Letter PDF bytes', () async {
      final sample = SampleResumeData.createDefault().copyWith(
        pageSize: ResumePageSize.letter,
      );
      final bytes = await generator.generate(sample);

      expect(bytes, isNotEmpty);
      final header = ascii.decode(bytes.take(5).toList());
      expect(header, equals('%PDF-'));
    });

    test('paginates long 12-bullet experience cleanly without PdfException', () async {
      final sample = SampleResumeData.createDefault();
      final longRole = ExperienceItem(
        id: 'exp-long',
        role: 'Lead Mobile Engineer',
        company: 'Enterprise Corp',
        location: 'Mumbai, India',
        startDate: 'Jan 2024',
        endDate: '',
        isCurrent: true,
        bullets: List.generate(
          12,
          (i) => 'Delivered production milestone #${i + 1} across Dev, SIT, UAT, and Production.',
        ),
      );

      final bytes = await generator.generate(
        sample.copyWith(experiences: [longRole, ...sample.experiences]),
      );

      expect(bytes, isNotEmpty);
      final header = ascii.decode(bytes.take(5).toList());
      expect(header, equals('%PDF-'));
    });
  });
}
