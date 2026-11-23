import 'dart:async';

/// Retains the latest authorized snapshot from each query; no polling or reloads.
Stream<List<Object>> combineLatest(List<Stream<Object>> sources) {
  late StreamController<List<Object>> output;
  final subscriptions = <StreamSubscription<Object>>[];
  final values = List<Object?>.filled(sources.length, null);
  final ready = List<bool>.filled(sources.length, false);
  var active = true;
  var done = 0;
  void error(Object error, StackTrace stack) {
    if (active) output.addError(error, stack);
  }

  output = StreamController<List<Object>>(
    onListen: () {
      if (sources.isEmpty) {
        output.add([]);
        output.close();
        return;
      }
      for (var index = 0; index < sources.length; index++) {
        final position = index;
        subscriptions.add(sources[index].listen(
            (value) {
              if (!active) return;
              values[position] = value;
              ready[position] = true;
              if (ready.every((value) => value)) {
                output.add(values.cast<Object>().toList(growable: false));
              }
            },
            onError: error,
            onDone: () {
              done++;
              if (active && (!ready[position] || done == sources.length)) {
                active = false;
                output.close();
              }
            }));
      }
    },
    onCancel: () async {
      active = false;
      await Future.wait(
          subscriptions.map((subscription) => subscription.cancel()));
    },
  );
  return output.stream;
}

/// Replaces dependent query listeners when the account/company/job set changes.
Stream<R> switchLatest<T, R>(
    Stream<T> source, Stream<R> Function(T value) select) {
  late StreamController<R> output;
  StreamSubscription<T>? outer;
  StreamSubscription<R>? inner;
  var generation = 0;
  var active = true;
  var sourceDone = false;
  var innerDone = true;
  void error(Object error, StackTrace stack) {
    if (active) output.addError(error, stack);
  }

  output = StreamController<R>(onListen: () {
    outer = source.listen(
        (value) async {
          final current = ++generation;
          innerDone = false;
          await inner?.cancel();
          if (!active || current != generation) return;
          try {
            inner = select(value).listen((event) {
              if (active && current == generation) output.add(event);
            }, onError: (Object failure, StackTrace stack) {
              if (current == generation) error(failure, stack);
            }, onDone: () {
              if (current != generation) return;
              innerDone = true;
              if (active && sourceDone) output.close();
            });
          } catch (failure, stack) {
            error(failure, stack);
          }
        },
        onError: error,
        onDone: () {
          sourceDone = true;
          if (active && innerDone) output.close();
        });
  }, onCancel: () async {
    active = false;
    generation++;
    await outer?.cancel();
    await inner?.cancel();
  });
  return output.stream;
}
