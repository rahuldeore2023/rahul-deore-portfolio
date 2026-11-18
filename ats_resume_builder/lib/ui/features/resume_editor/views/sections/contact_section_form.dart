import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../domain/models/resume_data.dart';
import '../../../../core/widgets/section_card.dart';
import '../../providers/resume_providers.dart';

class ContactSectionForm extends ConsumerWidget {
  const ContactSectionForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contact = ref.watch(resumeProvider.select((r) => r.contact));
    final pageSize = ref.watch(resumeProvider.select((r) => r.pageSize));
    final rev = ref.watch(formRevisionProvider);
    final notifier = ref.read(resumeProvider.notifier);

    return SectionCard(
      title: 'Contact & Header',
      subtitle: 'Single phone with country code, city/country, and clean links',
      icon: Icons.person_outline,
      child: Column(
        children: [
          TextFormField(
            key: ValueKey('fullName_$rev'),
            initialValue: contact.fullName,
            decoration: const InputDecoration(
              labelText: 'Full Name *',
              hintText: 'e.g., Rahul Deore',
            ),
            onChanged: (v) =>
                notifier.updateContact(contact.copyWith(fullName: v)),
          ),
          const SizedBox(height: 12),
          TextFormField(
            key: ValueKey('headline_$rev'),
            initialValue: contact.headline,
            decoration: const InputDecoration(
              labelText: 'Target Role Headline *',
              hintText: 'e.g., Mobile App Developer | Flutter & Android (Kotlin, Java)',
            ),
            onChanged: (v) =>
                notifier.updateContact(contact.copyWith(headline: v)),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 520;
              final phoneField = TextFormField(
                key: ValueKey('phone_$rev'),
                initialValue: contact.phone,
                decoration: const InputDecoration(
                  labelText: 'Primary Phone *',
                  hintText: '+91 96236 14907',
                ),
                onChanged: (v) =>
                    notifier.updateContact(contact.copyWith(phone: v)),
              );
              final emailField = TextFormField(
                key: ValueKey('email_$rev'),
                initialValue: contact.email,
                decoration: const InputDecoration(
                  labelText: 'Email Address *',
                  hintText: 'name@example.com',
                ),
                onChanged: (v) =>
                    notifier.updateContact(contact.copyWith(email: v)),
              );

              if (isNarrow) {
                return Column(
                  children: [
                    phoneField,
                    const SizedBox(height: 12),
                    emailField,
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: phoneField),
                  const SizedBox(width: 12),
                  Expanded(child: emailField),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            key: ValueKey('location_$rev'),
            initialValue: contact.location,
            decoration: const InputDecoration(
              labelText: 'City & Country *',
              hintText: 'e.g., Mumbai, India',
            ),
            onChanged: (v) =>
                notifier.updateContact(contact.copyWith(location: v)),
          ),
          const SizedBox(height: 12),
          TextFormField(
            key: ValueKey('linkedin_$rev'),
            initialValue: contact.linkedInUrl,
            decoration: const InputDecoration(
              labelText: 'LinkedIn URL',
              hintText: 'https://www.linkedin.com/in/your-profile',
            ),
            onChanged: (v) =>
                notifier.updateContact(contact.copyWith(linkedInUrl: v)),
          ),
          const SizedBox(height: 12),
          TextFormField(
            key: ValueKey('portfolio_$rev'),
            initialValue: contact.portfolioOrGithubUrl,
            decoration: const InputDecoration(
              labelText: 'GitHub / Portfolio URL (Optional)',
              hintText: 'https://github.com/username',
            ),
            onChanged: (v) => notifier.updateContact(
              contact.copyWith(portfolioOrGithubUrl: v),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                'PDF Paper Size:',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SegmentedButton<ResumePageSize>(
                  segments: const [
                    ButtonSegment(
                      value: ResumePageSize.a4,
                      label: Text('A4'),
                    ),
                    ButtonSegment(
                      value: ResumePageSize.letter,
                      label: Text('US Letter'),
                    ),
                  ],
                  selected: {pageSize},
                  onSelectionChanged: (selection) {
                    if (selection.isNotEmpty) {
                      notifier.updatePageSize(selection.first);
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
