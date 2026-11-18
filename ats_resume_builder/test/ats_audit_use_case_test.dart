import 'package:ats_resume_builder/data/services/sample_resume_data.dart';
import 'package:ats_resume_builder/domain/models/ats_audit_result.dart';
import 'package:ats_resume_builder/domain/models/education_item.dart';
import 'package:ats_resume_builder/domain/models/experience_item.dart';
import 'package:ats_resume_builder/domain/models/resume_data.dart';
import 'package:ats_resume_builder/domain/use_cases/ats_audit_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const useCase = AtsAuditUseCase();

  group('AtsAuditUseCase', () {
    test('scores ATS-optimized sample resume at 95 or higher', () {
      final sample = SampleResumeData.createDefault();
      final result = useCase.evaluate(sample);

      expect(result.score, greaterThanOrEqualTo(95));
      expect(result.criticalCount, equals(0));
      expect(result.estimatedPages, lessThanOrEqualTo(2));
    });

    test('flags dual phone numbers as critical', () {
      final sample = SampleResumeData.createDefault();
      final mutated = sample.copyWith(
        contact: sample.contact.copyWith(phone: '9623614907 / 7756026937'),
      );

      final result = useCase.evaluate(mutated);
      final phoneCheck = result.checks.firstWhere(
        (c) => c.id == 'contact_phone',
      );
      expect(phoneCheck.severity, AtsCheckSeverity.critical);
    });

    test('flags missing space after comma in text', () {
      final sample = SampleResumeData.createDefault();
      final mutated = sample.copyWith(
        summary:
            'Experienced developer skilled in Kotlin,Firebase and Flutter architecture with 7+ years building scalable mobile applications across platforms.',
      );

      final result = useCase.evaluate(mutated);
      final spacingCheck = result.checks.firstWhere(
        (c) => c.id == 'punctuation_spacing',
      );
      expect(spacingCheck.severity, AtsCheckSeverity.warning);
    });

    test('flags first-person pronouns in experience bullets', () {
      final sample = SampleResumeData.createDefault();
      final mutated = sample.copyWith(
        experiences: [
          const ExperienceItem(
            id: 'e1',
            role: 'Flutter Developer',
            company: 'Acme',
            location: 'Mumbai',
            startDate: 'Jul 2025',
            endDate: '',
            isCurrent: true,
            bullets: ['I led a team of 4 engineers to ship Flutter apps.'],
          ),
        ],
      );

      final result = useCase.evaluate(mutated);
      final expCheck = result.checks.firstWhere(
        (c) => c.id == 'experience_bullets',
      );
      expect(expCheck.severity, AtsCheckSeverity.warning);
    });

    test('flags blank education graduation year', () {
      final sample = SampleResumeData.createDefault();
      final mutated = sample.copyWith(
        education: [
          const EducationItem(
            id: 'ed1',
            degree: 'B.Sc. in Computer Science',
            institution: 'Sample College',
          ),
        ],
      );

      final result = useCase.evaluate(mutated);
      final eduCheck = result.checks.firstWhere(
        (c) => c.id == 'education_complete',
      );
      expect(eduCheck.severity, AtsCheckSeverity.warning);
    });

    test('empty resume receives low score with critical findings', () {
      final result = useCase.evaluate(ResumeData.empty());
      expect(result.score, lessThan(40));
      expect(result.criticalCount, greaterThanOrEqualTo(5));
    });
  });
}
