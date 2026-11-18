import 'dart:convert';

import '../../domain/models/resume_data.dart';
import '../services/resume_storage_service.dart';
import '../services/sample_resume_data.dart';

/// Repository acting as the single source of truth for loading, persisting,
/// exporting, and importing [ResumeData].
class ResumeRepository {
  const ResumeRepository({required this.storageService});

  final ResumeStorageService storageService;

  Future<ResumeData> loadResume() async {
    try {
      final raw = await storageService.readRawResumeJson();
      if (raw == null || raw.trim().isEmpty) {
        return SampleResumeData.createDefault();
      }
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return ResumeData.fromJson(decoded);
      }
      return SampleResumeData.createDefault();
    } catch (_) {
      return SampleResumeData.createDefault();
    }
  }

  Future<void> saveResume(ResumeData data) async {
    final encoded = jsonEncode(data.toJson());
    await storageService.writeRawResumeJson(encoded);
  }

  Future<ResumeData> resetToSample() async {
    final sample = SampleResumeData.createDefault();
    await saveResume(sample);
    return sample;
  }

  Future<ResumeData> clearAll() async {
    final empty = ResumeData.empty();
    await saveResume(empty);
    return empty;
  }

  String exportPrettyJson(ResumeData data) {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(data.toJson());
  }

  ResumeData parseJson(String rawJson) {
    final decoded = jsonDecode(rawJson);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Root JSON must be an object.');
    }
    return ResumeData.fromJson(decoded);
  }
}
