/// Why a review request did or did not reach the platform.
enum ReviewRequestOutcome {
  /// The native review prompt was triggered.
  ///
  /// This means the request reached the platform. It does **not** mean anyone
  /// saw a prompt. Apple shows the prompt at most three times per 365 days and
  /// never in TestFlight builds, and Google states that its API "does not
  /// indicate whether the user reviewed or not, or even whether the review
  /// dialog was shown". Treat this as "we asked", never as "they saw it".
  requested,

  /// The cooldown has not elapsed since the last request.
  skippedTooSoon,

  /// This app version has already asked.
  skippedSameVersion,

  /// The platform could not be asked at all.
  ///
  /// Covers a missing Play Store, a detached Android activity, an iOS window
  /// scene that could not be resolved, unreadable local state, and any
  /// platform this package does not implement. The reason is written to the
  /// developer log; it is deliberately not part of this enum, because nothing
  /// an app could sensibly do differs between the cases.
  unavailable,
}
