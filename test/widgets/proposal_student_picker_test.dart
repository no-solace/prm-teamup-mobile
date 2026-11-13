import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamup_exe/models/major.dart';
import 'package:teamup_exe/models/student.dart';
import 'package:teamup_exe/widgets/proposal_student_picker.dart';

/// S11 / S13 — the shared student picker.
///
/// Lab 2 handoff: the meta line reads "team, N of 6", ticking a student that
/// would push the team past six shows "Max 6 members" and the caller locks
/// its confirm button; unchecking clears the error and unlocks it.
void main() {
  Student student(String mssv, String name) => Student(
    mssv: mssv,
    fullName: name,
    major: Major.se,
    classId: 'c1',
  );

  final students = [
    student('SE001', 'An'),
    student('SE002', 'Binh'),
    student('AI003', 'Chi'),
  ];

  Future<void> pump(
    WidgetTester tester, {
    required Set<String> selected,
    required int capacity,
    int currentSize = 0,
    String? teamName = 'FinLite',
    ValueChanged<bool>? onValidity,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProposalStudentPicker(
            students: students,
            selected: selected,
            capacity: capacity,
            currentSize: currentSize,
            teamName: teamName,
            onChanged: (_) {},
            onValidityChanged: onValidity,
          ),
        ),
      ),
    );
  }

  testWidgets('S11 shows the Lab 2 meta line "team, N of 6"', (tester) async {
    await pump(tester, selected: {'SE001'}, capacity: 2, currentSize: 4);

    expect(find.text('FinLite, 5 of 6'), findsOneWidget);
  });

  testWidgets('S13 refuses the pick that would exceed six and shows the error', (
    tester,
  ) async {
    var valid = true;
    await pump(
      tester,
      selected: {'SE001'},
      capacity: 1,
      currentSize: 5,
      onValidity: (v) => valid = v,
    );

    // The team already has 5 members and one is selected: the next tick
    // would make seven.
    await tester.tap(find.byType(Checkbox).at(1));
    await tester.pump();

    expect(find.text('Max 6 members'), findsOneWidget);
    expect(valid, isFalse, reason: 'the confirm button must be locked');
  });

  testWidgets('S13 clears the error once a student is unchecked', (tester) async {
    var valid = true;
    await pump(
      tester,
      selected: {'SE001'},
      capacity: 1,
      currentSize: 5,
      onValidity: (v) => valid = v,
    );

    await tester.tap(find.byType(Checkbox).at(1));
    await tester.pump();
    expect(find.text('Max 6 members'), findsOneWidget);

    // Unchecking the selected student brings the team back to five and
    // unlocks the button.
    await tester.tap(find.byType(Checkbox).at(0));
    await tester.pump();

    expect(find.text('Max 6 members'), findsNothing);
    expect(valid, isTrue);
  });

  testWidgets('a full team shows the error from the first frame', (tester) async {
    var valid = true;
    await pump(
      tester,
      selected: const {},
      capacity: 0,
      currentSize: 6,
      onValidity: (v) => valid = v,
    );
    await tester.pump();

    expect(find.text('Max 6 members'), findsOneWidget);
    expect(valid, isFalse);
  });

  testWidgets('S21 shows the empty state when nothing matches', (tester) async {
    await pump(tester, selected: const {}, capacity: 3);
    expect(find.text('No student results'), findsNothing);

    await tester.enterText(find.byType(TextField), 'ZZZNOONE');
    await tester.pump();

    expect(find.text('No student results'), findsOneWidget);
    expect(find.byType(Checkbox), findsNothing);
  });
}
