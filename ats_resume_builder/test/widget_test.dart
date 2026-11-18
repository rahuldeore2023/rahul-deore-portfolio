import 'package:ats_resume_builder/data/services/resume_storage_service.dart';
import 'package:ats_resume_builder/main.dart';
import 'package:ats_resume_builder/ui/features/resume_editor/providers/resume_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeStorageService extends ResumeStorageService {
  @override
  Future<String?> readRawResumeJson() async => null;

  @override
  Future<void> writeRawResumeJson(String jsonString) async {}

  @override
  Future<void> clear() async {}
}

void main() {
  testWidgets('renders ATS Resume Builder and opens live ATS Audit tab', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          resumeStorageServiceProvider.overrideWithValue(_FakeStorageService()),
        ],
        child: const AtsResumeBuilderApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('ATS Resume Builder'), findsOneWidget);
    expect(find.text('Contact & Header'), findsOneWidget);
    expect(find.textContaining('ATS '), findsWidgets);

    // Switch to ATS Audit tab via NavigationBar
    await tester.tap(find.text('ATS Audit'));
    await tester.pumpAndSettle();

    expect(find.text('ATS Compliance Checklist'), findsOneWidget);
    expect(find.text('Full Name & Target Role Headline'), findsOneWidget);
  });
}
