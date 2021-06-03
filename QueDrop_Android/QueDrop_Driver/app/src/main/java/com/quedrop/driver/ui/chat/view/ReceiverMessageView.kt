package com.quedrop.driver.ui.chat.view

import android.content.Context
import android.view.View
import com.quedrop.driver.R
import com.quedrop.driver.base.DateUtil
import com.quedrop.driver.base.view.ConstraintLayoutWithLifecycle
import com.quedrop.driver.socket.model.Message
import kotlinx.android.synthetic.main.item_chat_receive_message.view.*

class ReceiverMessageView(context: Context) : ConstraintLayoutWithLifecycle(context) {

    init {
        inflateUi()
    }

    private fun inflateUi() {
        layoutParams = LayoutParams(
            LayoutParams.MATCH_PARENT,
            LayoutParams.WRAP_CONTENT
        )
        View.inflate(context, R.layout.item_chat_receive_message, this)
    }

    fun bind(message: Message) {
        message.message?.let {
            chatMessageTextView.text = it
        }
        message.createdDate?.let {
            chatMessageTimeTextView.text = DateUtil.getChatTime(it)
        }
    }
}