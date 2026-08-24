package com.boundfoxstudios.review_etiquette

import android.app.Activity
import com.google.android.gms.tasks.Task
import com.google.android.play.core.review.ReviewManager
import java.util.concurrent.Executor
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException
import kotlinx.coroutines.suspendCancellableCoroutine

internal class ReviewFlow(private val reviewManager: ReviewManager) {
    suspend fun launch(activity: Activity) {
        // ReviewInfo is short lived and matched by reference identity, so the
        // request and the launch have to stay inside one call.
        val reviewInfo = reviewManager.requestReviewFlow().await()

        // Deliberately not awaited: this task only completes once the user closes
        // the card, and Google documents that it carries no information at all.
        reviewManager.launchReviewFlow(activity, reviewInfo)
    }
}

// Without an explicit executor the Play tasks post to the main looper, which a
// plain JVM test does not have.
private val directExecutor = Executor { command -> command.run() }

private suspend fun <T> Task<T>.await(): T =
    suspendCancellableCoroutine { continuation ->
        addOnCompleteListener(directExecutor) { task ->
            val failure = task.exception

            if (failure != null) {
                continuation.resumeWithException(failure)
            } else {
                continuation.resume(task.result)
            }
        }
    }
