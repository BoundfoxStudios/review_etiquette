package com.boundfoxstudios.review_etiquette

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import com.google.android.play.core.review.ReviewManagerFactory
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding

class ReviewEtiquettePlugin :
    FlutterPlugin,
    ActivityAware,
    ReviewEtiquetteHostApi {
    private var reviewFlow: ReviewFlow? = null

    // Holding the binding rather than the activity: a rotation replaces the
    // activity, and a stale one would act on a destroyed instance.
    private var activityBinding: ActivityPluginBinding? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        reviewFlow = ReviewFlow(ReviewManagerFactory.create(binding.applicationContext))
        ReviewEtiquetteHostApi.setUp(binding.binaryMessenger, this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        ReviewEtiquetteHostApi.setUp(binding.binaryMessenger, null)
        reviewFlow = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activityBinding = binding
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activityBinding = binding
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activityBinding = null
    }

    override fun onDetachedFromActivity() {
        activityBinding = null
    }

    override suspend fun requestReview() {
        val activity = requireActivity()
        val flow =
            reviewFlow
                ?: throw FlutterError(
                    "not_attached",
                    "The plugin is not attached to a Flutter engine.",
                    null,
                )

        try {
            flow.launch(activity)
        } catch (failure: Throwable) {
            throw toFlutterError(failure)
        }
    }

    override suspend fun openStoreListing(
        appStoreId: String?,
        androidPackageName: String?,
        action: StoreListingAction,
    ) {
        val activity = requireActivity()
        val packageName = androidPackageName ?: activity.packageName
        val listing = Uri.parse("https://play.google.com/store/apps/details?id=$packageName")
        val intent = Intent(Intent.ACTION_VIEW, listing).setPackage("com.android.vending")

        try {
            activity.startActivity(intent)
        } catch (notFound: ActivityNotFoundException) {
            throw FlutterError(
                "play_store_not_found",
                "The Play Store is not installed on this device.",
                null,
            )
        }
    }

    private fun requireActivity(): Activity =
        activityBinding?.activity
            ?: throw FlutterError(
                "no_activity",
                "The plugin is not attached to an activity. The Play in-app " +
                    "review flow needs one to launch.",
                null,
            )
}
