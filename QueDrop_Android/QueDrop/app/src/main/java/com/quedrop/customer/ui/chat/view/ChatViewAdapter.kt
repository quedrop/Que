package com.quedrop.customer.ui.chat.view

import android.content.Context
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.quedrop.customer.socket.model.Message

class ChatViewAdapter(private val context: Context, private val loggedInUserId: Int) :
    RecyclerView.Adapter<RecyclerView.ViewHolder>() {

    private var adapterItems = listOf<AdapterItem>()

    var listOfMessages: List<Message> = listOf()
        set(listOfMessages) {
            field = listOfMessages
            updateAdapterItems()
        }


    @Synchronized
    fun updateAdapterItems() {
        val adapterItems = mutableListOf<AdapterItem>()
        listOfMessages.forEach {
            if (it.senderId == loggedInUserId) {
                adapterItems.add(AdapterItem.SenderMessageChatViewHeader(it))
            } else {
                adapterItems.add(AdapterItem.ReceiverMessageChatViewHeader(it))
            }
        }
        this.adapterItems = adapterItems
        notifyDataSetChanged()
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        return when (viewType) {
            ViewType.SenderMessageItemType.ordinal -> {
                val senderMessageView = SenderMessageView(context)
                ChatViewHeader(senderMessageView)
            }
            ViewType.ReceiverMessageItemType.ordinal -> {
                val receiverMessageView = ReceiverMessageView(context)
                ChatViewHeader(receiverMessageView)
            }
            else -> throw IllegalArgumentException("Unsupported ViewType")
        }
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        val adapterItem = adapterItems.getOrNull(position) ?: return
        when (adapterItem) {
            is AdapterItem.SenderMessageChatViewHeader -> {
                (holder.itemView as SenderMessageView).bind(adapterItem.message)
            }
            is AdapterItem.ReceiverMessageChatViewHeader -> {
                (holder.itemView as ReceiverMessageView).bind(adapterItem.message)
            }
        }
    }

    override fun getItemViewType(position: Int): Int {
        return adapterItems[position].type
    }

    override fun getItemCount(): Int {
        return adapterItems.size
    }

    private class ChatViewHeader(view: View) : RecyclerView.ViewHolder(view)

    sealed class AdapterItem(val type: Int) {
        data class SenderMessageChatViewHeader(val message: Message) :
            AdapterItem(ViewType.SenderMessageItemType.ordinal)

        data class ReceiverMessageChatViewHeader(val message: Message) :
            AdapterItem(ViewType.ReceiverMessageItemType.ordinal)
    }

    private enum class ViewType {
        SenderMessageItemType,
        ReceiverMessageItemType
    }
}