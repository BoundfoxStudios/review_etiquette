import 'dart:async';

Future<void>? _pending;

/// Runs [action] after every earlier call has finished.
///
/// The guard is process wide rather than per instance on purpose: it protects
/// the device wide review quota, and consumers are free to construct a new
/// facade for every call. Without it, two success events arriving together
/// would both read "never asked" and both trigger a prompt.
///
/// The slot is always released, including when [action] throws an [Error]
/// rather than an [Exception]. A wedged mutex would hang every later call in
/// the process for good.
Future<T> runExclusively<T>(Future<T> Function() action) async {
  final previous = _pending;
  final released = Completer<void>();
  _pending = released.future;

  try {
    await previous;

    return await action();
  } finally {
    released.complete();
  }
}
