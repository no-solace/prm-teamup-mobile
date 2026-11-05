import '../models/class_room.dart';
import '../models/proposal.dart';
import '../models/report.dart';
import '../models/student.dart';
import '../models/team.dart';
import '../services/app_error.dart';
import '../services/class_service.dart';
import '../services/proposal_service.dart';
import '../services/report_service.dart';
import '../services/storage_service.dart';

// Placeholders so main.dart compiles and runs from day 1. Each owner replaces
// their class with a real implementation in its own file (for example
// lib/firebase/firestore_class_service.dart) and updates providers.dart.
// Until then the screens show their error state with this message.
const _todo = UnknownError('Not implemented yet');

/// TODO(Dan): Firestore classes/{classId}, students, teams; CSV import.
class FirestoreClassService implements ClassService {
  @override
  Stream<List<ClassRoom>> watchMyClasses() => Stream.error(_todo);
  @override
  Stream<ClassRoom> watchClass(String classId) => Stream.error(_todo);
  @override
  Stream<List<Student>> watchStudents(String classId) => Stream.error(_todo);
  @override
  Stream<List<Team>> watchTeams(String classId) => Stream.error(_todo);
  @override
  Future<Student> getStudent(String classId, String mssv) => Future.error(_todo);
  @override
  Future<ImportPreview> parseImportFile({required String fileName, required List<int> bytes}) => Future.error(_todo);
  @override
  Future<ImportResult> importClass(ImportPreview preview) => Future.error(_todo);
}

/// TODO(Cuong): Firestore classes/{classId}/proposals; approve in a WriteBatch.
class FirestoreProposalService implements ProposalService {
  @override
  Stream<List<Proposal>> watchPending(String classId) => Stream.error(_todo);
  @override
  Stream<List<Proposal>> watchAllPending() => Stream.error(_todo);
  @override
  Stream<Proposal> watchProposal(String proposalId) => Stream.error(_todo);
  @override
  Future<void> savePending(List<Proposal> proposals) => Future.error(_todo);
  @override
  Future<Proposal> updateMembers(String proposalId,
          {required List<String> addStudentIds, required List<String> currentMemberIds}) =>
      Future.error(_todo);
  @override
  Future<void> approve(String proposalId) => Future.error(_todo);
  @override
  Future<void> undoApprove(String proposalId) => Future.error(_todo);
  @override
  Future<void> discard(String proposalId) => Future.error(_todo);
  @override
  Future<Proposal> createManual({required String classId, required String teamId, required List<String> addStudentIds}) =>
      Future.error(_todo);
}

/// TODO(Cuong): build the PDF with package:pdf.
class PdfReportService implements ReportService {
  @override
  Future<List<int>> buildClassTeamsPdf(String classId) => Future.error(_todo);
}

/// TODO(Cuong): upload to Storage reports/{uid}/..., metadata in Firestore reports.
class FirebaseStorageService implements StorageService {
  @override
  Stream<UploadEvent> uploadReport({required String classId, required List<int> bytes}) => Stream.error(_todo);
  @override
  Stream<List<Report>> watchMyReports() => Stream.error(_todo);
}
