package com.quedrop.customer.ui.chat.view

import android.content.Context
import android.view.View
import com.quedrop.customer.socket.model.Message
import com.quedrop.customer.R
import com.quedrop.customer.base.view.ConstraintLayoutWithLifecycle
import com.quedrop.customer.utils.DateUtil
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