import 'package:ats_resume_builder/data/services/resume_storage_service.dart';
import 'package:ats_resume_builder/ui/features/resume_editor/providers/resume_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _InMemoryStorageService extends ResumeStorageService {
  String? _raw;

  @override
  Future<String?> readRawResumeJson() async => _raw;

  @override
  Future<void> writeRawResumeJson(String jsonString) async {
    _raw = jsonString;
  }

  @override
  Future<void> clear() async {
    _raw = null;
  }
}

void main() {
  group('Riverpod ResumeNotifier & atsAuditProvider', () {
    late ProviderContainer container;
    late _InMemoryStorageService storage;

    setUp(() {
      storage = _InMemoryStorageService();
      container = ProviderContainer(
        overrides: [
          resumeStorageServiceProvider.overrideWithValue(storage),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('updates contact and reactively recomputes ATS audit score', () {
      final initialScore = container.read(atsAuditProvider).score;
      expect(initialScore, greaterThanOrEqualTo(95));

      final currentContact = container.read(resumeProvider).contact;
      container
          .read(resumeProvider.notifier)
          .updateContact(currentContact.copyWith(location: '', email: 'bad'));

      final updatedScore = container.read(atsAuditProvider).score;
      expect(updatedScore, lessThan(initialScore));
    });

    test('adds and removes skill groups and experiences cleanly', () {
      final notifier = container.read(resumeProvider.notifier);

      final initialSkillCount =
          container.read(resumeProvider).skillGroups.length;
      notifier.addSkillGroup(
        category: 'Cloud',
        skills: ['GCP', 'Firebase'],
      );
      expect(
        container.read(resumeProvider).skillGroups.length,
        initialSkillCount + 1,
      );

      final addedId = container.read(resumeProvider).skillGroups.last.id;
      notifier.removeSkillGroup(addedId);
      expect(
        container.read(resumeProvider).skillGroups.length,
        initialSkillCount,
      );

      final initialExpCount = container.read(resumeProvider).experiences.length;
      notifier.addExperience();
      expect(
        container.read(resumeProvider).experiences.length,
        initialExpCount + 1,
      );
    });

    test('exports and re-imports JSON without data loss', () {
      final notifier = container.read(resumeProvider.notifier);
      final original = container.read(resumeProvider);
      final jsonText = notifier.exportPrettyJson();

      notifier.updateSummary('Temporary modified summary');
      expect(
        container.read(resumeProvider).summary,
        'Temporary modified summary',
      );

      notifier.importFromJson(jsonText);
      expect(container.read(resumeProvider), equals(original));
    });
  });
}
