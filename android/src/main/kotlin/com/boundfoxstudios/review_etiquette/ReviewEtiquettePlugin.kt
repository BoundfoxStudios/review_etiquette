package com.boundfoxstudios.review_etiquette

import io.flutter.embedding.engine.plugins.FlutterPlugin

class ReviewEtiquettePlugin :
    FlutterPlugin,
    ReviewEtiquetteHostApi {
    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        ReviewEtiquetteHostApi.setUp(binding.binaryMessenger, this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        ReviewEtiquetteHostApi.setUp(binding.binaryMessenger, null)
    }

    override suspend fun requestReview() {
        throw FlutterError("unimplemented", "requestReview is not implemented yet.", null)
    }

    override suspend fun openStoreListing(appStoreId: String?) {
        throw FlutterError("unimplemented", "openStoreListing is not implemented yet.", null)
    }
}
