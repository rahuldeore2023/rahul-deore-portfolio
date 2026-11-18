import 'package:flutter/foundation.dart';

/// Contact header information formatted for ATS parsability.
@immutable
class ResumeContact {
  const ResumeContact({
    required this.fullName,
    required this.headline,
    required this.phone,
    required this.email,
    required this.location,
    this.linkedInUrl = '',
    this.portfolioOrGithubUrl = '',
  });

  final String fullName;
  final String headline;
  final String phone;
  final String email;
  final String location;
  final String linkedInUrl;
  final String portfolioOrGithubUrl;

  factory ResumeContact.empty() => const ResumeContact(
    fullName: '',
    headline: '',
    phone: '',
    email: '',
    location: '',
  );

  ResumeContact copyWith({
    String? fullName,
    String? headline,
    String? phone,
    String? email,
    String? location,
    String? linkedInUrl,
    String? portfolioOrGithubUrl,
  }) {
    return ResumeContact(
      fullName: fullName ?? this.fullName,
      headline: headline ?? this.headline,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      location: location ?? this.location,
      linkedInUrl: linkedInUrl ?? this.linkedInUrl,
      portfolioOrGithubUrl: portfolioOrGithubUrl ?? this.portfolioOrGithubUrl,
    );
  }

  Map<String, dynamic> toJson() => {
    'fullName': fullName,
    'headline': headline,
    'phone': phone,
    'email': email,
    'location': location,
    'linkedInUrl': linkedInUrl,
    'portfolioOrGithubUrl': portfolioOrGithubUrl,
  };

  factory ResumeContact.fromJson(Map<String, dynamic> json) {
    return ResumeContact(
      fullName: json['fullName'] as String? ?? '',
      headline: json['headline'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      location: json['location'] as String? ?? '',
      linkedInUrl: json['linkedInUrl'] as String? ?? '',
      portfolioOrGithubUrl: json['portfolioOrGithubUrl'] as String? ?? '',
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ResumeContact &&
        other.fullName == fullName &&
        other.headline == headline &&
        other.phone == phone &&
        other.email == email &&
        other.location == location &&
        other.linkedInUrl == linkedInUrl &&
        other.portfolioOrGithubUrl == portfolioOrGithubUrl;
  }

  @override
  int get hashCode => Object.hash(
    fullName,
    headline,
    phone,
    email,
    location,
    linkedInUrl,
    portfolioOrGithubUrl,
  );
}
