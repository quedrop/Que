package com.quedrop.driver.service.model

import com.google.gson.annotations.Expose
import com.google.gson.annotations.SerializedName

class SettingResponse {

    @SerializedName("status")
    @Expose
    var status: Boolean? = null

    @SerializedName("message")
    @Expose
    var message: String? = null

    @SerializedName("data")
    @Expose
    var data: ReviewData? = null
}

class ReviewData {
    @SerializedName("reviews")
    val reviews: List<RateAndReviews>? = null
}

class RateAndReviewsss {
    @SerializedName("user_id")
    var user_id: Int? = null

    @SerializedName("review_id")
    var review_id: Int? = null

    @SerializedName("review")
    var review: String? = null

    @SerializedName("rating")
    var rating: Float? = null

    @SerializedName("first_name")
    var first_name: String? = null

    @SerializedName("last_name")
    var last_name: String? = null

    @SerializedName("user_image")
    var user_image: String? = null

    @SerializedName("user_name")
    var user_name: String? = null

    @SerializedName("order_id")
    var order_id: Int? = null

    @SerializedName("created_at")
    var created_at: String? = null
}