import '../../domain/models/education_item.dart';
import '../../domain/models/experience_item.dart';
import '../../domain/models/project_item.dart';
import '../../domain/models/resume_contact.dart';
import '../../domain/models/resume_data.dart';
import '../../domain/models/skill_group.dart';

/// Provides an ATS-optimized baseline resume template demonstrating clean
/// single-column structure, categorized skills, standardized MMM YYYY dates,
/// and action-verb, metric-driven bullets.
class SampleResumeData {
  const SampleResumeData._();

  static ResumeData createDefault() {
    return const ResumeData(
      contact: ResumeContact(
        fullName: 'Rahul Deore',
        headline: 'Senior Mobile App Developer | Flutter & Android (Kotlin, Java)',
        phone: '+91 96236 14907',
        email: 'rahuldeore.flutter.2024@gmail.com',
        location: 'Mumbai, India',
        linkedInUrl: 'https://www.linkedin.com/in/rahul-deore-a39800193/',
        portfolioOrGithubUrl: '',
      ),
      summary:
          'Senior Mobile Application Developer with 7+ years of experience designing, building, and '
          'scaling production Android (Kotlin, Java) and Flutter (Android, iOS, Web) applications. '
          'Specialized in Clean Architecture, MVVM, BLoC, and Riverpod state management, with hands-on '
          'ownership of mobile security, performance optimization, CI/CD automation, end-to-end '
          'multi-environment deployments (Dev, SIT, UAT, Production), and mentoring developers.',
      skillGroups: [
        SkillGroup(
          id: 'sg-languages',
          category: 'Languages',
          skills: ['Kotlin', 'Java', 'Dart'],
        ),
        SkillGroup(
          id: 'sg-frameworks',
          category: 'Frameworks & Platforms',
          skills: [
            'Flutter (Android, iOS, Web)',
            'Android SDK',
            'FlutterFlow',
            'Material Design',
          ],
        ),
        SkillGroup(
          id: 'sg-architecture',
          category: 'Architecture & State Management',
          skills: [
            'Clean Architecture',
            'MVVM',
            'SOLID Principles',
            'BLoC',
            'Riverpod',
            'ViewModel',
          ],
        ),
        SkillGroup(
          id: 'sg-backend',
          category: 'Networking, Backend & Storage',
          skills: [
            'REST APIs',
            'GraphQL',
            'Firebase',
            'Cloud Firestore',
            'FCM',
            'SQLite',
            'Hive',
            'JSON',
            'XML',
          ],
        ),
        SkillGroup(
          id: 'sg-devops',
          category: 'Tools, Security & Testing',
          skills: [
            'Android Studio',
            'Xcode',
            'Gradle',
            'CocoaPods',
            'CI/CD Pipelines',
            'Release Management (Dev, SIT, UAT, Production)',
            'Git',
            'Microsoft Azure',
            'ProGuard',
            'SSL Pinning',
            'AES-256 Encryption',
            'Unit Testing',
            'Agile/Scrum',
          ],
        ),
      ],
      experiences: [
        ExperienceItem(
          id: 'exp-idealake',
          role: 'Flutter & Android Developer',
          company: 'Idealake Technologies',
          location: 'Mumbai, India',
          startDate: 'Jul 2025',
          endDate: '',
          isCurrent: true,
          bullets: [
            'Architected scalable enterprise mobile solutions in Flutter and FlutterFlow using Bedrock multi-layer architecture (L1, L2, L3) and modular custom components.',
            'Owned end-to-end code deployment and release promotion across 4 environments (Dev, SIT, UAT, Production), ensuring reliable production rollouts.',
            'Coordinated environment-specific build configurations, release sign-offs, and defect resolution with QA, DevOps, and stakeholders across SIT and UAT cycles.',
            'Led peer code reviews and mentored 4 developers on Clean Architecture, code quality standards, and sprint delivery.',
            'Collaborated directly with enterprise clients to translate complex business requirements into maintainable, on-time production releases.',
          ],
        ),
        ExperienceItem(
          id: 'exp-tecplix',
          role: 'Flutter & Android Developer',
          company: 'Tecplix Technologies',
          location: 'Mumbai, India',
          startDate: 'Nov 2024',
          endDate: 'May 2025',
          bullets: [
            'Migrated and refactored legacy Native Android (Java) codebase into modular Clean Architecture, improving maintainability.',
            'Revamped core UI screens with Material Design and responsive components to improve usability across device sizes.',
            'Implemented structured local caching and modular REST API integration layers for reliable offline support and maintainability.',
            'Hardened application security and performance with ProGuard obfuscation, SSL pinning, and encrypted local storage.',
            'Implemented CI pipelines in an Agile cross-functional team to automate builds and accelerate release cycles.',
          ],
        ),
        ExperienceItem(
          id: 'exp-reflections',
          role: 'Senior Software Engineer',
          company: 'Reflections Info Systems',
          location: 'Pune, India',
          startDate: 'Jul 2022',
          endDate: 'Nov 2024',
          bullets: [
            'Developed and maintained production cross-platform mobile apps using Flutter and Native Android.',
            'Implemented MVVM with ViewModel for Android modules and BLoC state management for Flutter apps.',
            'Optimized app startup and rendering pipelines, reducing cold app load time by 25%.',
            'Mentored junior engineers on unit testing, architecture patterns, and clean code best practices.',
          ],
        ),
        ExperienceItem(
          id: 'exp-aurus',
          role: 'Software Developer',
          company: 'Aurus',
          location: 'Pune, India',
          startDate: 'Mar 2020',
          endDate: 'Jul 2022',
          bullets: [
            'Engineered scalable Flutter applications across fintech and enterprise domains with focus on smooth UX.',
            'Implemented predictable state management using BLoC and Riverpod for testable, modular codebases.',
            'Integrated Firebase Realtime Database, Cloud Firestore, and Cloud Storage for live data synchronization.',
            'Led Agile sprint planning with product stakeholders to scope technical milestones and deliver releases on schedule.',
          ],
        ),
        ExperienceItem(
          id: 'exp-codetentacles',
          role: 'Application Developer',
          company: 'Code Tentacles',
          location: 'Pune, India',
          startDate: 'Dec 2018',
          endDate: 'Feb 2020',
          bullets: [
            'Built and maintained multi-domain mobile applications in Flutter with reusable custom widget libraries.',
            'Integrated REST APIs for seamless bidirectional data synchronization between mobile clients and backend services.',
            'Authored unit tests and participated in peer code reviews to uphold release stability.',
          ],
        ),
      ],
      projects: [
        ProjectItem(
          id: 'proj-finopay',
          name: 'FinoPay - Digital Banking Application',
          techStack:
              'Android, Flutter, Android Studio, Gradle, SQLite, Firebase Push Notifications (FCM), UPI, AES-256',
          url:
              'https://play.google.com/store/apps/details?id=com.finopaymentbank.mobile',
          bullets: [
            'Developed secure mobile banking modules supporting UPI payments, CASA wallets, bill payments, and mobile recharges.',
            'Implemented regulatory KYC and cKYC customer onboarding flows aligned with Indian banking compliance standards.',
            'Applied AES-256 encryption and secure local persistence for offline data protection and fast transaction retrieval.',
          ],
        ),
        ProjectItem(
          id: 'proj-pidilite',
          name: 'Pidilite EHS - Incident Reporting App',
          techStack: 'Flutter, Dart, Android, iOS, Xcode, Android Studio, CocoaPods, Microsoft Azure',
          url: '',
          bullets: [
            'Built a cross-platform mobile incident reporting app in Flutter (Android & iOS) to eliminate friction from the legacy web-portal login flow.',
            'Streamlined field incident submission and Microsoft Azure backend integration, improving field user accessibility and reporting efficiency.',
          ],
        ),
      ],
      education: [
        EducationItem(
          id: 'edu-msc',
          degree: 'M.Sc. in Computer Science',
          institution: 'Dr. D Y Patil ACS College',
          location: 'Pune, India',
          graduationYear: '2018',
          grade: '',
        ),
        EducationItem(
          id: 'edu-bsc',
          degree: 'B.Sc. in Computer Science',
          institution: 'K V N Naik College',
          location: 'Nashik, India',
          graduationYear: '2016',
          grade: '',
        ),
      ],
      pageSize: ResumePageSize.a4,
    );
  }
}
