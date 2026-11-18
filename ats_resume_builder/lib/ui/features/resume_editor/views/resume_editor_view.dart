import 'package:flutter/material.dart';

import 'sections/contact_section_form.dart';
import 'sections/education_section_form.dart';
import 'sections/experience_section_form.dart';
import 'sections/projects_section_form.dart';
import 'sections/skills_section_form.dart';
import 'sections/summary_section_form.dart';

/// Main scrollable form combining all ATS-standard resume sections.
class ResumeEditorView extends StatelessWidget {
  const ResumeEditorView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: const [
        ContactSectionForm(),
        SizedBox(height: 16),
        SummarySectionForm(),
        SizedBox(height: 16),
        SkillsSectionForm(),
        SizedBox(height: 16),
        ExperienceSectionForm(),
        SizedBox(height: 16),
        ProjectsSectionForm(),
        SizedBox(height: 16),
        EducationSectionForm(),
      ],
    );
  }
}
