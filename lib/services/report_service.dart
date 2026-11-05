/// Owner: Cuong. Builds the PDF of approved teams of a class (the generated file).
abstract interface class ReportService {
  /// Returns the PDF bytes. The content must match what the mentor sees (Lab 3 rubric).
  Future<List<int>> buildClassTeamsPdf(String classId);
}
