/// Owner: Cuong. Builds the PDF of approved teams of a class (the generated file).
abstract interface class ReportService {
  /// Returns the PDF bytes plus the number of teams printed. The content must
  /// match what the mentor sees (Lab 3 rubric: "generated file reflects what
  /// the user sees").
  Future<BuiltReport> buildClassTeamsPdf(String classId);
}

/// The generated file and the figures the mentor saw on screen.
class BuiltReport {
  const BuiltReport({required this.bytes, required this.teamCount});

  final List<int> bytes;

  /// Number of teams printed in the PDF (teams with 5-6 members).
  final int teamCount;
}
