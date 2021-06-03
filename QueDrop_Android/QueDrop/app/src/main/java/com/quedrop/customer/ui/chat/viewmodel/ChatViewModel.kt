package com.quedrop.customer.ui.chat.viewmodel


import android.util.Log
import com.quedrop.customer.base.BaseViewModel
import com.quedrop.customer.base.rxjava.subscribeOnIoAndObserveOnMainThread
import com.quedrop.customer.socket.chat.ChatRepository
import com.quedrop.customer.socket.model.FetchMessageRequest
import com.quedrop.customer.socket.model.Message
import com.quedrop.customer.socket.model.SendMessageRequest
import io.reactivex.Observable
import io.reactivex.subjects.PublishSubject
import timber.log.Timber

class ChatViewModel(private val chatRepository: ChatRepository) : BaseViewModel() {

    private val chatMessagesShowsSubject = PublishSubject.create<Pair<List<Message>, Boolean>>()
    val chatMessagesShows: Observable<Pair<List<Message>, Boolean>> =
        chatMessagesShowsSubject.hide()

    private val progressBarViewShowsSubject: PublishSubject<Boolean> = PublishSubject.create()
    val progressBarViewShows: Observable<Boolean> = progressBarViewShowsSubject.hide()


    private var listOfChatMessage = mutableListOf<Message>()

    init {
        chatRepository.observeNewMessage().subscribeOnIoAndObserveOnMainThread({
            if (it.isSuccess()) {
                Log.e("onGetNewMessage","1==>")
                val message = it.chatMessages.getOrNull(0)
                message?.let { chatMessage ->
                    Log.e("onGetNewMessage","==>")

                    if (listOfChatMessage.size > 0) {
                        val messageList = listOfChatMessage[0]

                        if (messageList.orderId == chatMessage.orderId && messageList.senderId == chatMessage.senderId && messageList.receiverId == chatMessage.receiverId) {
                            listOfChatMessage.add(chatMessage)
                            Log.e("Adding","==>Add"+message)
                        }else{
                            Log.e("Not adding","==>")
                        }
                    }

                }
                chatMessagesShowsSubject.onNext(
                    Pair(
                        listOfChatMessage.sortedBy { it.messageId },
                        false
                    )
                )
            }
        }, {
            Timber.e(it)
        }).autoDispose()
    }

    fun sendNewMessage(sendMessageRequest: SendMessageRequest) {
        chatRepository.sendNewMessage(sendMessageRequest)
            .subscribeOnIoAndObserveOnMainThread({ chatMessageResponse ->
                if (chatMessageResponse.isSuccess()) {
                    val message = chatMessageResponse.chatMessages.getOrNull(0)
                    message?.let { chatMessage -> listOfChatMessage.add(chatMessage) }
                    chatMessagesShowsSubject.onNext(
                        Pair(
                            listOfChatMessage.sortedBy { it.messageId },
                            false
                        )
                    )
                }
            }, {
                Timber.e(it)
            }).autoDispose()
    }

    fun fetchMessages(fetchMessageRequest: FetchMessageRequest, isLoadMore: Boolean = false) {
        chatRepository.fetchMessages(fetchMessageRequest)
            .doOnSubscribe {
                if (!isLoadMore) {
                    progressBarViewShowsSubject.onNext(true)
                }
            }
            .subscribeOnIoAndObserveOnMainThread({ chatMessageResponse ->
                if (!isLoadMore) {
                    progressBarViewShowsSubject.onNext(false)
                }
                if (chatMessageResponse.isSuccess()) {
                    if (!chatMessageResponse.chatMessages.isNullOrEmpty()) {
                        listOfChatMessage.addAll(chatMessageResponse.chatMessages)
                        chatMessagesShowsSubject.onNext(
                            Pair(
                                listOfChatMessage.sortedBy { it.messageId },
                                isLoadMore
                            )
                        )
                    }
                }
            }, {
                Timber.i(it)
                if (!isLoadMore) {
                    progressBarViewShowsSubject.onNext(false)
                }
            }).autoDispose()
    }

    fun loadMore(senderId: Int, receiverId: Int, orderId: Int) {
        if (listOfChatMessage.isNotEmpty()) {
            Timber.i("${listOfChatMessage.lastOrNull()?.messageId}")
//            val lastMessageId = listOfChatMessage.lastOrNull()?.messageId

            val lastMessageId = listOfChatMessage.sortedBy { it.messageId }.firstOrNull()?.messageId
            if (lastMessageId != null) {
                fetchMessages(
                    FetchMessageRequest(
                        senderId,
                        receiverId,
                        lastMessageId,
                        orderId
                    ),
                    isLoadMore = true
                )
            }
        }
    }
}