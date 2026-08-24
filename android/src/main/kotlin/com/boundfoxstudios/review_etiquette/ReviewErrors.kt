package com.boundfoxstudios.review_etiquette

import com.google.android.play.core.review.ReviewException
import com.google.android.play.core.review.model.ReviewErrorCode

internal fun toFlutterError(cause: Throwable): FlutterError {
    // ReviewException inherits getStatusCode() from ApiException but explicitly
    // does not support it. The cast is guarded because the failing task is not
    // documented to carry a ReviewException in every case.
    if (cause is ReviewException) {
        return FlutterError(
            nameOf(cause.errorCode),
            cause.message ?: "The Play in-app review flow failed.",
            cause.errorCode,
        )
    }

    return FlutterError(
        "review_failed",
        cause.message ?: cause.toString(),
        null,
    )
}

private fun nameOf(errorCode: Int): String =
    when (errorCode) {
        ReviewErrorCode.PLAY_STORE_NOT_FOUND -> "play_store_not_found"
        ReviewErrorCode.INVALID_REQUEST -> "invalid_request"
        ReviewErrorCode.INTERNAL_ERROR -> "internal_error"
        else -> "review_failed"
    }
