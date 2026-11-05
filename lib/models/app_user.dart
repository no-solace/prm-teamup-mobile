/// The signed-in mentor (users/{uid}).
class AppUser {
  const AppUser({
    required this.uid,
    required this.displayName,
    this.email,
    this.photoUrl,
    this.role = 'mentor',
  });

  final String uid;
  final String displayName;

  /// Shown on S6 only. Never sent to Analytics or Crashlytics (no PII).
  final String? email;
  final String? photoUrl;
  final String role;

  /// Avatar initials on S6 (for example "LN").
  String get initials {
    final parts = displayName.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}
