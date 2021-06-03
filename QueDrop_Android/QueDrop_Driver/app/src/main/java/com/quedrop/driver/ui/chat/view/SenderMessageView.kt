package com.quedrop.driver.ui.chat.view

import android.content.Context
import android.view.View
import androidx.constraintlayout.widget.ConstraintLayout
import com.quedrop.driver.R
import com.quedrop.driver.base.DateUtil
import com.quedrop.driver.base.view.ConstraintLayoutWithLifecycle
import com.quedrop.driver.socket.model.Message
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