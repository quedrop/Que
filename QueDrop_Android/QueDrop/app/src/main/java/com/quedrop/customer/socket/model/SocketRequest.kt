package com.quedrop.driver.socket.model

import com.google.gson.annotations.SerializedName

data class SocketRequest(
	@field:SerializedName("user_id")
	val senderId: Int = 0
)

data class Conversation(
    @field:SerializedName("id")
    val id: String? = null
)

data class ConversationResponse(
    @field:SerializedName("conversations")
    val listOfConversations: List<Conversation>
)