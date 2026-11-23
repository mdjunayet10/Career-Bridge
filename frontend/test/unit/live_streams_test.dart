import 'dart:async';
import 'package:career_bridge/core/services/live_streams.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('latest snapshots update two open consumers without reload or restart',
      () async {
    final jobs = StreamController<Object>.broadcast(sync: true);
    final companies = StreamController<Object>.broadcast(sync: true);
    final events = <List<Object>>[];
    final combined = combineLatest([jobs.stream, companies.stream]);
    final otherEvents = <List<Object>>[];
    final subscription = combined.listen(events.add);
    final otherSubscription =
        combineLatest([jobs.stream, companies.stream]).listen(otherEvents.add);
    jobs.add('initial jobs');
    await Future<void>.delayed(Duration.zero);
    expect(events, isEmpty);
    companies.add('approved companies');
    await Future<void>.delayed(Duration.zero);
    expect(events.single, ['initial jobs', 'approved companies']);
    jobs.add('new published job');
    await Future<void>.delayed(Duration.zero);
    expect(events.last, ['new published job', 'approved companies']);
    expect(otherEvents.last, ['new published job', 'approved companies']);
    await subscription.cancel();
    expect(jobs.hasListener, isTrue);
    await otherSubscription.cancel();
    expect(jobs.hasListener, isFalse);
    expect(companies.hasListener, isFalse);
    await jobs.close();
    await companies.close();
  });
  test('switching accounts or job sets drops old listeners and late events',
      () async {
    final accounts = StreamController<String>(sync: true);
    final old = StreamController<int>.broadcast(sync: true);
    final current = StreamController<int>.broadcast(sync: true);
    final values = <int>[];
    final subscription = switchLatest(accounts.stream,
            (account) => account == 'old' ? old.stream : current.stream)
        .listen(values.add);
    accounts.add('old');
    await Future<void>.delayed(Duration.zero);
    old.add(1);
    await Future<void>.delayed(Duration.zero);
    accounts.add('current');
    await Future<void>.delayed(Duration.zero);
    old.add(99);
    current.add(2);
    await Future<void>.delayed(Duration.zero);
    expect(values, [1, 2]);
    expect(old.hasListener, isFalse);
    await subscription.cancel();
    expect(current.hasListener, isFalse);
    await accounts.close();
    await old.close();
    await current.close();
  });
}
