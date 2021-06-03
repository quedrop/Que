package com.quedrop.customer.socket.model

import android.os.Parcelable
import com.google.gson.annotations.SerializedName
import kotlinx.android.parcel.Parcelize

data class ChatMessageResponse(
    @field:SerializedName("status")
    val status: Int? = null,

    @field:SerializedName("message")
    val message: String? = null,

    @field:SerializedName("chat_message")
    val chatMessages: List<Message>
) {
    fun isSuccess(): Boolean {
        return status == 1
    }
}


@Parcelize
data class Message(
    @field:SerializedName("id")
    val messageId: Int? = null,

    @field:SerializedName("sender_id")
    val senderId: Int? = null,

    @field:SerializedName("receiver_id")
    val receiverId: Int? = null,

    @field:SerializedName("message")
    val message: String? = null,

    @field:SerializedName("created_date")
    val createdDate: String? = null,

    @field:SerializedName("modified_date")
    val modifiedDate: String? = null,

    @field:SerializedName("order_id")
    val orderId: Int? = null
): Parcelable


data class FetchMessageRequest(
    @field:SerializedName("sender_id")
    val senderId: Int? = null,

    @field:SerializedName("receiver_id")
    val receiverId: Int? = null,

    @field:SerializedName("last_message_id")
    val lastMessageId: Int = 0,

    @field:SerializedName("limit")
    val limit: Int = 20,

    @field:SerializedName("order_id")
    val orderId: Int? = null
)

data class SendMessageRequest(
    @field:SerializedName("sender_id")
    val senderId: Int? = null,

    @field:SerializedName("receiver_id")
    val receiverId: Int? = null,

    @field:SerializedName("message")
    val message: String? = null,

    @field:SerializedName("order_id")
    val orderId: Int? = null

)