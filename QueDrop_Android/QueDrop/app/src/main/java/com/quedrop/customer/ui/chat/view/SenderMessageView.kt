package com.quedrop.customer.ui.chat.view

import android.content.Context
import android.view.View
import androidx.constraintlayout.widget.ConstraintLayout
import com.quedrop.customer.socket.model.Message
import com.quedrop.customer.R
import com.quedrop.customer.base.view.ConstraintLayoutWithLifecycle
import com.quedrop.customer.utils.DateUtil
import kotlinx.android.synthetic.main.item_chat_send_message.view.*

class SenderMessageView(context: Context) : ConstraintLayoutWithLifecycle(context) {

    init {
        inflateUi()
    }

    private fun inflateUi() {
        layoutParams = ConstraintLayout.LayoutParams(
            ConstraintLayout.LayoutParams.MATCH_PARENT,
            ConstraintLayout.LayoutParams.WRAP_CONTENT
        )
        View.inflate(context, R.layout.item_chat_send_message, this)
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