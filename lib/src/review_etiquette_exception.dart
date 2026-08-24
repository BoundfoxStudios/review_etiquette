/// Thrown when the store listing could not be opened.
///
/// Only user initiated calls throw. Asking for a review never does, because a
/// failed review request must not disturb the flow it is attached to.
class ReviewEtiquetteException implements Exception {
  /// Creates an exception describing why the store listing stayed closed.
  const ReviewEtiquetteException(this.message);

  /// What went wrong, in a form that is useful in a bug report.
  final String message;

  @override
  String toString() => 'ReviewEtiquetteException: $message';
}
