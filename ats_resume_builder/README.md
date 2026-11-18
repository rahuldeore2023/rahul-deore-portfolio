# ATS Resume Builder (Flutter + Riverpod)

A Flutter application for authoring, auditing, and exporting **ATS-compatible resumes** built with **Riverpod 3** state management and clean layered architecture (`data`, `domain`, `ui`).

## Features

- **ATS-First PDF Export (`pdf` + `printing`)**:
  - Single-column, linear-reading-order vector PDF (selectable machine-readable text).
  - Standard Helvetica typography, uppercase standard section headers (`PROFESSIONAL SUMMARY`, `TECHNICAL SKILLS`, `EXPERIENCE`, `PROJECTS`, `EDUCATION`), clean spacing, and zero tables, icons, or images.
  - Supports **A4** and **US Letter** page formats with live preview, print, and share/download.
- **Live ATS Compatibility Checker**:
  - Reactively evaluates your resume via Riverpod (`atsAuditProvider`) and displays a weighted **0–100 ATS score**.
  - Checks single phone with country code, city/country location, valid email, summary length, categorized deduplicated skills, action-verb bullets (no first-person pronouns), quantified impact metrics, `MMM YYYY` date consistency, comma-spacing hygiene, complete education entries, and 1–2 page length guidance.
- **Riverpod State Management**:
  - Immutable domain models (`ResumeData`, `ResumeContact`, `SkillGroup`, `ExperienceItem`, `ProjectItem`, `EducationItem`).
  - `ResumeNotifier` (`NotifierProvider`) with auto-persistence via `SharedPreferences` + JSON import/export backup.
- **Responsive Layout**:
  - **Desktop / Tablet (`>= 960px`)**: Side-by-side Resume Editor + Live PDF / ATS Audit panel.
  - **Mobile (`< 960px`)**: Bottom `NavigationBar` switching between Editor, ATS Audit, and PDF Preview.

## Project Structure

```text
lib/
├── main.dart
├── data/
│   ├── repositories/
│   │   └── resume_repository.dart
│   └── services/
│       ├── ats_pdf_generator.dart
│       ├── resume_storage_service.dart
│       └── sample_resume_data.dart
├── domain/
│   ├── models/
│   │   ├── ats_audit_result.dart
│   │   ├── education_item.dart
│   │   ├── experience_item.dart
│   │   ├── project_item.dart
│   │   ├── resume_contact.dart
│   │   ├── resume_data.dart
│   │   └── skill_group.dart
│   └── use_cases/
│       └── ats_audit_use_case.dart
└── ui/
    ├── core/
    │   ├── theme/app_theme.dart
    │   └── widgets/
    │       ├── bullet_list_editor.dart
    │       └── section_card.dart
    └── features/
        ├── ats_audit/views/ats_audit_view.dart
        ├── pdf_preview/views/ats_pdf_preview_view.dart
        └── resume_editor/
            ├── providers/resume_providers.dart
            └── views/
                ├── home_screen.dart
                ├── resume_editor_view.dart
                └── sections/
```

## Getting Started

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```
