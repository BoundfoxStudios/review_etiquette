# Changelog

## [1.0.0](https://github.com/BoundfoxStudios/review_etiquette/compare/v0.1.0...v1.0.0) (2026-08-25)


### Features

* add a static store listing entry point ([4e4cd88](https://github.com/BoundfoxStudios/review_etiquette/commit/4e4cd88578674ff999d8c6061834e91266f8d403))

## 0.1.0

* Initial release.
* `requestReview()` triggers the native in-app review prompt, but only when the
  platform etiquette allows it: a configurable cooldown (120 days by default)
  must have elapsed and the current app version must not have asked before.
* `openStoreListing()` opens the store page for a user-initiated "rate this
  app" button, which is the only sanctioned way to react to a tap.
* iOS 16.0 and above via StoreKit `AppStore.requestReview(in:)`, Android via
  the Play In-App Review API.
