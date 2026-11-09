import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:teamup_exe/firebase/firestore_class_service.dart';

Future<void> tick() => Future<void>.delayed(Duration.zero);

void main() {
  test('combined data waits for each source then updates counts inputs', () async {
    final a = StreamController<int>();
    final b = StreamController<int>();
    final values = <List<int>>[];
    final sub = combineDataStreams([a.stream, b.stream]).listen(values.add);
    a.add(1);
    await tick();
    expect(values, isEmpty);
    b.add(2);
    await tick();
    a.add(3);
    await tick();
    expect(values, [[1, 2], [3, 2]]);
    await sub.cancel();
    expect(a.hasListener, isFalse);
    expect(b.hasListener, isFalse);
    await a.close();
    await b.close();
  });
  test('empty class list emits immediately', () async {
    expect(await combineDataStreams<int>([]).first, isEmpty);
  });
  test('switching accounts cancels old listener, suppresses old data', () async {
    final accounts = StreamController<String>();
    final first = StreamController<int>();
    final second = StreamController<int>();
    final values = <int>[];
    final sub = switchDataStream(accounts.stream,
        (uid) => uid == 'a' ? first.stream : second.stream).listen(values.add);
    accounts.add('a');
    await tick();
    first.add(1);
    await tick();
    accounts.add('b');
    await tick();
    expect(first.hasListener, isFalse);
    first.add(2);
    second.add(3);
    await tick();
    expect(values, [1, 3]);
    await sub.cancel();
    expect(accounts.hasListener, isFalse);
    expect(second.hasListener, isFalse);
    await accounts.close();
    await first.close();
    await second.close();
  });
  test('rapid switching selects final stream even during async cancellation', () async {
    final accounts = StreamController<int>();
    final old = StreamController<int>(onCancel: () => Future<void>.delayed(const Duration(milliseconds: 10)));
    final values = <int>[];
    final sub = switchDataStream(accounts.stream,
        (id) => id == 0 ? old.stream : Stream.value(id)).listen(values.add);
    accounts.add(0);
    await tick();
    accounts.add(1);
    accounts.add(2);
    await Future<void>.delayed(const Duration(milliseconds: 30));
    expect(values, [2]);
    await sub.cancel();
    await accounts.close();
    await old.close();
  });
}
