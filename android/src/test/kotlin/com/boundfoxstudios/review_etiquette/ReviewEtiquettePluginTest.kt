package com.boundfoxstudios.review_etiquette

import android.app.Activity
import com.google.android.gms.tasks.Task
import com.google.android.gms.tasks.Tasks
import com.google.android.play.core.review.ReviewException
import com.google.android.play.core.review.ReviewInfo
import com.google.android.play.core.review.ReviewManager
import com.google.android.play.core.review.model.ReviewErrorCode
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFailsWith
import kotlin.test.assertNull
import kotlin.test.assertSame
import kotlinx.coroutines.runBlocking
import org.mockito.Mockito

/**
 * The Play SDK's own FakeReviewManager is not usable here: it calls new Intent(),
 * Build.VERSION.SDK_INT and PendingIntent.getBroadcast(), all of which hit the
 * android.jar stubs. Faking the interface keeps these tests on the plain JVM.
 */
private class FakeReviewManager(private val requested: Task<ReviewInfo>) : ReviewManager {
    var launchedActivity: Activity? = null
    var launchedInfo: ReviewInfo? = null

    override fun requestReviewFlow(): Task<ReviewInfo> = requested

    override fun launchReviewFlow(
        activity: Activity,
        reviewInfo: ReviewInfo,
    ): Task<Void> {
        launchedActivity = activity
        launchedInfo = reviewInfo

        return Tasks.forResult(null)
    }
}

class ReviewErrorsTest {
    @Test
    fun toFlutterError_playStoreNotFound_mapsToItsOwnCode() {
        val error = toFlutterError(ReviewException(ReviewErrorCode.PLAY_STORE_NOT_FOUND))

        assertEquals("play_store_not_found", error.code)
        assertEquals(ReviewErrorCode.PLAY_STORE_NOT_FOUND, error.details)
    }

    @Test
    fun toFlutterError_invalidRequest_mapsToItsOwnCode() {
        val error = toFlutterError(ReviewException(ReviewErrorCode.INVALID_REQUEST))

        assertEquals("invalid_request", error.code)
    }

    @Test
    fun toFlutterError_internalError_mapsToItsOwnCode() {
        val error = toFlutterError(ReviewException(ReviewErrorCode.INTERNAL_ERROR))

        assertEquals("internal_error", error.code)
    }

    @Test
    fun toFlutterError_unknownErrorCode_fallsBackToReviewFailed() {
        val error = toFlutterError(ReviewException(-9999))

        assertEquals("review_failed", error.code)
    }

    @Test
    fun toFlutterError_plainThrowable_fallsBackToReviewFailed() {
        val error = toFlutterError(IllegalStateException("no network"))

        assertEquals("review_failed", error.code)
        assertEquals("no network", error.message)
    }
}

class ReviewFlowTest {
    @Test
    fun launch_requestSucceeded_launchesWithTheSameReviewInfo() =
        runBlocking {
            val reviewInfo = Mockito.mock(ReviewInfo::class.java)
            val activity = Mockito.mock(Activity::class.java)
            val manager = FakeReviewManager(Tasks.forResult(reviewInfo))

            ReviewFlow(manager).launch(activity)

            assertSame(activity, manager.launchedActivity)
            assertSame(reviewInfo, manager.launchedInfo)
        }

    @Test
    fun launch_requestFailed_propagatesTheReviewException() =
        runBlocking {
            val failure = ReviewException(ReviewErrorCode.PLAY_STORE_NOT_FOUND)
            val manager = FakeReviewManager(Tasks.forException(failure))

            val thrown =
                assertFailsWith<ReviewException> {
                    ReviewFlow(manager).launch(Mockito.mock(Activity::class.java))
                }

            assertEquals(ReviewErrorCode.PLAY_STORE_NOT_FOUND, thrown.errorCode)
            assertNull(manager.launchedActivity)
        }
}

class ReviewEtiquettePluginActivityTest {
    private fun bindingFor(activity: Activity): ActivityPluginBinding {
        val binding = Mockito.mock(ActivityPluginBinding::class.java)
        Mockito.`when`(binding.activity).thenReturn(activity)

        return binding
    }

    @Test
    fun requestReview_noActivityAttached_failsWithNoActivity() =
        runBlocking {
            val thrown =
                assertFailsWith<FlutterError> { ReviewEtiquettePlugin().requestReview() }

            assertEquals("no_activity", thrown.code)
        }

    @Test
    fun openStoreListing_noActivityAttached_failsWithNoActivity() =
        runBlocking {
            val thrown =
                assertFailsWith<FlutterError> {
                    ReviewEtiquettePlugin().openStoreListing(null)
                }

            assertEquals("no_activity", thrown.code)
        }

    @Test
    fun showStoreListing_noActivityAttached_failsWithNoActivity() =
        runBlocking {
            val thrown =
                assertFailsWith<FlutterError> {
                    ReviewEtiquettePlugin().showStoreListing(null, "com.example.other")
                }

            assertEquals("no_activity", thrown.code)
        }

    @Test
    fun showStoreListing_noPackageName_failsWithMissingPackageName() =
        runBlocking {
            val plugin = ReviewEtiquettePlugin()
            plugin.onAttachedToActivity(bindingFor(Mockito.mock(Activity::class.java)))

            val thrown =
                assertFailsWith<FlutterError> { plugin.showStoreListing("987654321", null) }

            assertEquals("missing_package_name", thrown.code)
        }

    @Test
    fun onDetachedFromActivity_afterAttach_forgetsTheActivity() =
        runBlocking {
            val plugin = ReviewEtiquettePlugin()
            plugin.onAttachedToActivity(bindingFor(Mockito.mock(Activity::class.java)))
            plugin.onDetachedFromActivity()

            val thrown = assertFailsWith<FlutterError> { plugin.requestReview() }

            assertEquals("no_activity", thrown.code)
        }

    @Test
    fun onDetachedFromActivityForConfigChanges_afterAttach_forgetsTheActivity() =
        runBlocking {
            // Forgetting this half of the pair is the classic activity leak: a
            // rotation would keep the destroyed activity around.
            val plugin = ReviewEtiquettePlugin()
            plugin.onAttachedToActivity(bindingFor(Mockito.mock(Activity::class.java)))
            plugin.onDetachedFromActivityForConfigChanges()

            val thrown = assertFailsWith<FlutterError> { plugin.requestReview() }

            assertEquals("no_activity", thrown.code)
        }

    @Test
    fun onReattachedToActivityForConfigChanges_afterRotation_usesTheNewActivity() =
        runBlocking {
            val plugin = ReviewEtiquettePlugin()
            plugin.onAttachedToActivity(bindingFor(Mockito.mock(Activity::class.java)))
            plugin.onDetachedFromActivityForConfigChanges()
            plugin.onReattachedToActivityForConfigChanges(
                bindingFor(Mockito.mock(Activity::class.java)),
            )

            // Past the activity check, so it fails on the missing engine instead.
            val thrown = assertFailsWith<FlutterError> { plugin.requestReview() }

            assertEquals("not_attached", thrown.code)
        }
}
