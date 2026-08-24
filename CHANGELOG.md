# Changelog

## 0.1.0

* Initial release.
* `requestReview()` triggers the native in-app review prompt, but only when the
  platform etiquette allows it: a configurable cooldown (120 days by default)
  must have elapsed and the current app version must not have asked before.
* `openStoreListing()` opens the store page for a user-initiated "rate this
  app" button, which is the only sanctioned way to react to a tap.
* iOS 16.0 and above via StoreKit `AppStore.requestReview(in:)`, Android via
  the Play In-App Review API.
