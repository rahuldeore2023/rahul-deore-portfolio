import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../data/repositories/resume_repository.dart';
import '../../../../data/services/ats_pdf_generator.dart';
import '../../../../data/services/resume_storage_service.dart';
import '../../../../data/services/sample_resume_data.dart';
import '../../../../domain/models/ats_audit_result.dart';
import '../../../../domain/models/education_item.dart';
import '../../../../domain/models/experience_item.dart';
import '../../../../domain/models/project_item.dart';
import '../../../../domain/models/resume_contact.dart';
import '../../../../domain/models/resume_data.dart';
import '../../../../domain/models/skill_group.dart';
import '../../../../domain/use_cases/ats_audit_use_case.dart';

// ---------------------------------------------------------------------------
// Dependency Injection Providers
// ---------------------------------------------------------------------------

final resumeStorageServiceProvider = Provider<ResumeStorageService>(
  (ref) => const ResumeStorageService(),
);

final resumeRepositoryProvider = Provider<ResumeRepository>(
  (ref) => ResumeRepository(
    storageService: ref.watch(resumeStorageServiceProvider),
  ),
);

final atsAuditUseCaseProvider = Provider<AtsAuditUseCase>(
  (ref) => const AtsAuditUseCase(),
);

final atsPdfGeneratorProvider = Provider<AtsPdfGenerator>(
  (ref) => const AtsPdfGenerator(),
);

// ---------------------------------------------------------------------------
// Primary Resume State Notifier
// ---------------------------------------------------------------------------

final resumeProvider = NotifierProvider<ResumeNotifier, ResumeData>(
  ResumeNotifier.new,
);

/// Manages the immutable [ResumeData] state and auto-persists changes via
/// [ResumeRepository].
class ResumeNotifier extends Notifier<ResumeData> {
  static const _uuid = Uuid();
  bool _hydrated = false;

  @override
  ResumeData build() {
    if (!_hydrated) {
      _hydrated = true;
      Future.microtask(_hydrateFromStorage);
    }
    return SampleResumeData.createDefault();
  }

  ResumeRepository get _repository => ref.read(resumeRepositoryProvider);

  Future<void> _hydrateFromStorage() async {
    final loaded = await _repository.loadResume();
    if (ref.mounted) {
      state = loaded;
    }
  }

  void _commit(ResumeData next) {
    state = next;
    unawaited(_repository.saveResume(next));
  }

  // ---- Header & Summary ----

  void updateContact(ResumeContact contact) {
    _commit(state.copyWith(contact: contact));
  }

  void updateSummary(String summary) {
    _commit(state.copyWith(summary: summary));
  }

  void updatePageSize(ResumePageSize pageSize) {
    _commit(state.copyWith(pageSize: pageSize));
  }

  // ---- Skill Groups ----

  void addSkillGroup({String category = '', List<String> skills = const []}) {
    final newGroup = SkillGroup(
      id: _uuid.v4(),
      category: category,
      skills: skills,
    );
    _commit(state.copyWith(skillGroups: [...state.skillGroups, newGroup]));
  }

  void updateSkillGroup(SkillGroup updated) {
    final nextList = state.skillGroups
        .map((g) => g.id == updated.id ? updated : g)
        .toList();
    _commit(state.copyWith(skillGroups: nextList));
  }

  void removeSkillGroup(String id) {
    final nextList = state.skillGroups.where((g) => g.id != id).toList();
    _commit(state.copyWith(skillGroups: nextList));
  }

  // ---- Work Experience ----

  void addExperience() {
    final newItem = ExperienceItem(
      id: _uuid.v4(),
      role: '',
      company: '',
      location: '',
      startDate: '',
      endDate: '',
      bullets: const [''],
    );
    _commit(state.copyWith(experiences: [newItem, ...state.experiences]));
  }

  void updateExperience(ExperienceItem updated) {
    final nextList = state.experiences
        .map((e) => e.id == updated.id ? updated : e)
        .toList();
    _commit(state.copyWith(experiences: nextList));
  }

  void removeExperience(String id) {
    final nextList = state.experiences.where((e) => e.id != id).toList();
    _commit(state.copyWith(experiences: nextList));
  }

  void moveExperience(int oldIndex, int newIndex) {
    final list = [...state.experiences];
    if (oldIndex < 0 || oldIndex >= list.length) return;
    if (newIndex < 0 || newIndex >= list.length) return;
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    _commit(state.copyWith(experiences: list));
  }

  // ---- Projects ----

  void addProject() {
    final newItem = ProjectItem(
      id: _uuid.v4(),
      name: '',
      techStack: '',
      bullets: const [''],
    );
    _commit(state.copyWith(projects: [...state.projects, newItem]));
  }

  void updateProject(ProjectItem updated) {
    final nextList = state.projects
        .map((p) => p.id == updated.id ? updated : p)
        .toList();
    _commit(state.copyWith(projects: nextList));
  }

  void removeProject(String id) {
    final nextList = state.projects.where((p) => p.id != id).toList();
    _commit(state.copyWith(projects: nextList));
  }

  // ---- Education ----

  void addEducation() {
    final newItem = EducationItem(
      id: _uuid.v4(),
      degree: '',
      institution: '',
    );
    _commit(state.copyWith(education: [...state.education, newItem]));
  }

  void updateEducation(EducationItem updated) {
    final nextList = state.education
        .map((e) => e.id == updated.id ? updated : e)
        .toList();
    _commit(state.copyWith(education: nextList));
  }

  void removeEducation(String id) {
    final nextList = state.education.where((e) => e.id != id).toList();
    _commit(state.copyWith(education: nextList));
  }

  // ---- Reset / Import / Export ----

  Future<void> resetToSample() async {
    final sample = await _repository.resetToSample();
    state = sample;
  }

  Future<void> clearResume() async {
    final empty = await _repository.clearAll();
    state = empty;
  }

  String exportPrettyJson() => _repository.exportPrettyJson(state);

  void importFromJson(String rawJson) {
    final parsed = _repository.parseJson(rawJson);
    _commit(parsed);
  }
}

// ---------------------------------------------------------------------------
// Derived & UI State Providers
// ---------------------------------------------------------------------------

/// Reactively computes the live ATS audit score whenever [resumeProvider] changes.
final atsAuditProvider = Provider<AtsAuditResult>((ref) {
  final resume = ref.watch(resumeProvider);
  final useCase = ref.watch(atsAuditUseCaseProvider);
  return useCase.evaluate(resume);
});

/// Tracks the currently selected navigation tab on compact screens
/// (0 = Editor, 1 = ATS Audit, 2 = PDF Preview).
final selectedTabProvider = NotifierProvider<SelectedTabNotifier, int>(
  SelectedTabNotifier.new,
);

class SelectedTabNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void select(int index) => state = index;
}

/// Tracks the currently active right-hand panel on wide desktop/tablet screens
/// (0 = PDF Preview, 1 = ATS Audit).
final desktopPreviewTabProvider =
    NotifierProvider<DesktopPreviewTabNotifier, int>(
      DesktopPreviewTabNotifier.new,
    );

class DesktopPreviewTabNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void select(int index) => state = index;
}

/// Tracks a monotonic revision counter when forcing complete form rebuilds
/// (e.g., after Reset to Sample, Clear All, or Import JSON).
final formRevisionProvider = NotifierProvider<FormRevisionNotifier, int>(
  FormRevisionNotifier.new,
);

class FormRevisionNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void bump() => state = state + 1;
}
