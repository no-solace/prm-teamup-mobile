import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' hide PhoneCodeSent;
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mocktail/mocktail.dart';
import 'package:teamup_exe/firebase/firebase_auth_service.dart';
import 'package:teamup_exe/firebase/firestore_mentor_profile_service.dart';
import 'package:teamup_exe/models/app_user.dart';
import 'package:teamup_exe/services/app_error.dart';
import 'package:teamup_exe/services/auth_service.dart';

class _Auth extends Mock implements FirebaseAuth {}

class _Google extends Mock implements GoogleSignIn {}

class _User extends Mock implements User {}

class _Result extends Mock implements UserCredential {}

class _Profile extends Mock implements FirestoreMentorProfileService {}

void main() {
  late _Auth auth;
  late _Google google;
  late _User user;
  late _Result result;
  late _Profile profile;
  late FirebaseAuthService service;
  setUpAll(() {
    registerFallbackValue(
      PhoneAuthProvider.credential(
        verificationId: 'test-id',
        smsCode: '123456',
      ),
    );
    registerFallbackValue(Duration.zero);
  });
  setUp(() {
    auth = _Auth();
    google = _Google();
    user = _User();
    result = _Result();
    profile = _Profile();
    when(() => user.uid).thenReturn('test-uid');
    when(() => user.displayName).thenReturn(null);
    when(() => user.email).thenReturn('mentor@example.com');
    when(() => user.phoneNumber).thenReturn(null);
    when(() => user.photoURL).thenReturn(null);
    when(() => result.user).thenReturn(user);
    service = FirebaseAuthService(
      auth: auth,
      google: google,
      profileService: profile,
    );
  });
  test('restored session opens only after mentor profile exists', () async {
    final ready = Completer<void>();
    when(() => auth.userChanges()).thenAnswer((_) => Stream.value(user));
    when(() => auth.currentUser).thenReturn(user);
    when(() => profile.ensure(user)).thenAnswer((_) => ready.future);
    when(() => profile.watch('test-uid')).thenAnswer(
      (_) => Stream.value({'displayName': 'Lan', 'role': 'mentor'}),
    );

    var emitted = false;
    final session = service.authStateChanges().first.then((value) {
      emitted = true;
      return value;
    });
    await pumpEventQueue();
    expect(emitted, false);

    ready.complete();
    final restored = await session;
    expect(restored?.uid, 'test-uid');
    expect(restored?.role, UserRole.mentor);
    verify(() => profile.ensure(user)).called(1);
  });
  test('an account without a profile needs onboarding; a student profile maps its team', () async {
    final profiles = StreamController<Map<String, dynamic>?>();
    when(() => auth.userChanges()).thenAnswer((_) => Stream.value(user));
    when(() => auth.currentUser).thenReturn(user);
    when(() => profile.ensure(user)).thenAnswer((_) async {});
    when(() => profile.watch('test-uid')).thenAnswer((_) => profiles.stream);

    final seen = <AppUser?>[];
    final sub = service.authStateChanges().listen(seen.add);
    profiles.add(null);
    await pumpEventQueue();
    expect(seen.single?.needsOnboarding, isTrue);

    profiles.add({
      'displayName': 'An',
      'role': 'leader',
      'classId': 'c1',
      'teamId': 't1',
      'studentId': 'S1',
      'mentorUid': 'm1',
    });
    await pumpEventQueue();
    expect(seen.last?.isLeader, isTrue);
    expect(seen.last?.topicId, 'c1_t1');
    await sub.cancel();
    await profiles.close();
  });
  test(
    'a sign-out during profile provisioning cannot expose an old user',
    () async {
      final ready = Completer<void>();
      when(() => auth.userChanges()).thenAnswer((_) => Stream.value(user));
      when(() => auth.currentUser).thenReturn(user);
      when(() => profile.ensure(user)).thenAnswer((_) => ready.future);
      when(() => profile.watch('test-uid')).thenAnswer(
        (_) => Stream.value({'displayName': 'Lan', 'role': 'mentor'}),
      );

      final session = service.authStateChanges().first;
      await pumpEventQueue();
      when(() => auth.currentUser).thenReturn(null);
      ready.complete();
      expect(await session, isNull);
    },
  );
  test('a missing mentor permission blocks session routing', () async {
    when(() => auth.userChanges()).thenAnswer((_) => Stream.value(user));
    when(() => auth.currentUser).thenReturn(user);
    when(() => profile.ensure(user))
        .thenThrow(const PermissionDeniedError('This account is not a mentor'));

    await expectLater(
      service.authStateChanges().first,
      throwsA(isA<PermissionDeniedError>()),
    );
  });
  test(
    'email login uses normalized email and preserves password bytes',
    () async {
      when(
        () => auth.signInWithEmailAndPassword(
          email: 'mentor@example.com',
          password: '  secret  ',
        ),
      ).thenAnswer((_) async => result);
      final mapped = await service.signInWithEmail(
        email: ' mentor@example.com ',
        password: '  secret  ',
      );
      expect(mapped.uid, 'test-uid');
      expect(mapped.displayName, 'mentor@example.com');
      verifyNever(() => google.initialize());
    },
  );
  test(
    'email registration invokes Firebase create, not password sign in',
    () async {
      when(
        () => auth.createUserWithEmailAndPassword(
          email: 'mentor@example.com',
          password: 'secret',
        ),
      ).thenAnswer((_) async => result);
      expect(
        (await service.registerWithEmail(
          email: 'mentor@example.com',
          password: 'secret',
        )).uid,
        'test-uid',
      );
      verify(
        () => auth.createUserWithEmailAndPassword(
          email: 'mentor@example.com',
          password: 'secret',
        ),
      ).called(1);
    },
  );
  test(
    'SDK network exceptions are mapped and malformed email makes no request',
    () async {
      when(
        () => auth.signInWithEmailAndPassword(
          email: 'mentor@example.com',
          password: 'secret',
        ),
      ).thenThrow(FirebaseAuthException(code: 'network-request-failed'));
      await expectLater(
        service.signInWithEmail(
          email: 'mentor@example.com',
          password: 'secret',
        ),
        throwsA(isA<NetworkError>()),
      );
      await expectLater(
        service.signInWithEmail(email: 'invalid', password: 'secret'),
        throwsA(isA<ValidationError>()),
      );
    },
  );
  test('Google initialization can retry after transient failure', () async {
    var calls = 0;
    when(() => google.initialize()).thenAnswer((_) async {
      if (calls++ == 0) throw StateError('temporary initialization error');
    });
    when(() => google.authenticate()).thenThrow(
      const GoogleSignInException(code: GoogleSignInExceptionCode.canceled),
    );
    await expectLater(service.signInWithGoogle(), throwsA(isA<UnknownError>()));
    await expectLater(
      service.signInWithGoogle(),
      throwsA(isA<CancelledError>()),
    );
    verify(() => google.initialize()).called(2);
  });
  test('Firebase still signs out when Google cleanup fails', () async {
    when(() => google.initialize()).thenAnswer((_) async {});
    when(() => google.authenticate()).thenThrow(
      const GoogleSignInException(code: GoogleSignInExceptionCode.canceled),
    );
    await expectLater(
      service.signInWithGoogle(),
      throwsA(isA<CancelledError>()),
    );
    when(() => google.signOut()).thenThrow(StateError('Google unavailable'));
    when(() => auth.signOut()).thenAnswer((_) async {});
    when(() => auth.currentUser).thenReturn(null);
    await service.signOut();
    verify(() => auth.signOut()).called(1);
  });
  test('email/phone signout does not initialize Google', () async {
    when(() => auth.signOut()).thenAnswer((_) async {});
    await service.signOut();
    verifyNever(() => google.initialize());
    verifyNever(() => google.signOut());
  });
  test(
    'SMS resend passes native token; cancel ignores late callback',
    () async {
      final requests = <Invocation>[];
      when(
        () => auth.verifyPhoneNumber(
          phoneNumber: any(named: 'phoneNumber'),
          timeout: any(named: 'timeout'),
          forceResendingToken: any(named: 'forceResendingToken'),
          verificationCompleted: any(named: 'verificationCompleted'),
          verificationFailed: any(named: 'verificationFailed'),
          codeSent: any(named: 'codeSent'),
          codeAutoRetrievalTimeout: any(named: 'codeAutoRetrievalTimeout'),
        ),
      ).thenAnswer((call) async {
        requests.add(call);
        (call.namedArguments[#codeSent] as void Function(String, int?))(
          'verification-${requests.length}',
          42,
        );
      });
      final events = <PhoneAuthEvent>[];
      final first = service.requestPhoneCode('+84912345678').listen(events.add);
      await pumpEventQueue();
      expect(events.single, isA<PhoneCodeSent>());
      final second = service
          .requestPhoneCode('+84912345678', resend: true)
          .listen(events.add);
      await pumpEventQueue();
      expect(requests.last.namedArguments[#forceResendingToken], 42);
      service.cancelPhoneVerification();
      final count = events.length;
      (requests.last.namedArguments[#codeSent] as void Function(String, int?))(
        'late-code',
        99,
      );
      await pumpEventQueue();
      expect(events.length, count);
      await expectLater(
        service.confirmPhoneCode('123456'),
        throwsA(isA<ValidationError>()),
      );
      await first.cancel();
      await second.cancel();
    },
  );
}
