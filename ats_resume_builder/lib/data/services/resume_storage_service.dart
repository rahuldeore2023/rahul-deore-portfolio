import 'package:shared_preferences/shared_preferences.dart';

/// Low-level local storage wrapper using [SharedPreferences].
class ResumeStorageService {
  const ResumeStorageService();

  static const String _resumeKey = 'ats_resume_builder_saved_resume_v4';

  Future<String?> readRawResumeJson() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_resumeKey);
  }

  Future<void> writeRawResumeJson(String jsonString) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_resumeKey, jsonString);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_resumeKey);
  }
}
