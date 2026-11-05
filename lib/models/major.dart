/// Majors used for matching (Lab 2 persona, R3: matching is by major only).
enum Major {
  se('SE', 'Software Engineering'),
  ai('AI', 'Artificial Intelligence'),
  mkt('MKT', 'Marketing'),
  gd('GD', 'Graphic Design');

  const Major(this.code, this.label);

  final String code;
  final String label;

  static Major? fromCode(String? code) {
    if (code == null) return null;
    final c = code.trim().toUpperCase();
    for (final m in Major.values) {
      if (m.code == c) return m;
    }
    return null;
  }
}

/// Team size rules (R1): minimum 5, maximum 6.
abstract final class TeamRules {
  static const int minMembers = 5;
  static const int maxMembers = 6;
  static const int targetMajors = 3;
}
