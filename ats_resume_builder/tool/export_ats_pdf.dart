import 'dart:io';

import 'package:ats_resume_builder/data/services/ats_pdf_generator.dart';
import 'package:ats_resume_builder/data/services/sample_resume_data.dart';
import 'package:flutter_test/flutter_test.dart';

/// Utility entrypoint to export the default ATS-optimized PDF directly to the
/// portfolio website's `assets/` folder.
///
/// Run with:
/// `flutter test tool/export_ats_pdf.dart`
void main() {
  test('exports ATS PDF to portfolio_website/assets', () async {
    const generator = AtsPdfGenerator();
    final resume = SampleResumeData.createDefault();
    final bytes = await generator.generate(resume);

    final outFile = File.fromUri(
      Directory.current.uri.resolve(
        '../portfolio_website/assets/Rahul_Deore_ATS_Resume.pdf',
      ),
    );
    outFile.parent.createSync(recursive: true);
    outFile.writeAsBytesSync(bytes);

    expect(outFile.existsSync(), isTrue);
    expect(outFile.lengthSync(), greaterThan(1000));
  });
}
