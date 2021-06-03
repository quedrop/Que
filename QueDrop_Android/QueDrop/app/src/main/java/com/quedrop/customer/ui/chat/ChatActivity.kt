package com.quedrop.customer.ui.chat

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.util.Log
import android.view.View
import androidx.recyclerview.widget.LinearLayoutManager
import com.bumptech.glide.Glide
import com.quedrop.customer.R
import com.quedrop.customer.api.authentication.LoggedInUserCache
import com.quedrop.customer.base.BaseActivity
import com.quedrop.customer.base.QueDropApplication
import com.quedrop.customer.base.extentions.getViewModel
import com.quedrop.customer.base.extentions.hideKeyboard
import com.quedrop.customer.base.rxjava.subscribeAndObserveOnMainThread
import com.quedrop.customer.base.rxjava.subscribeOnIoAndObserveOnMainThread
import com.quedrop.customer.base.rxjava.throttleClicks
import com.quedrop.customer.model.ReceiverUser
import com.quedrop.customer.socket.SocketConstants
import com.quedrop.customer.socket.chat.ChatRepository
import com.quedrop.customer.socket.model.FetchMessageRequest
import com.quedrop.customer.socket.model.Message
import com.quedrop.customer.socket.model.SendMessageRequest
import com.quedrop.customer.ui.chat.view.ChatViewAdapter
import com.quedrop.customer.ui.chat.viewmodel.ChatViewModel
import com.quedrop.customer.utils.EnumUtils
import com.quedrop.customer.utils.ValidationUtils
import com.jakewharton.rxbinding2.support.v4.widget.refreshes
import com.quedrop.customer.utils.URLConstant
import io.socket.client.Ack
import kotlinx.android.synthetic.main.activity_chat.*
import kotlinx.android.synthetic.main.chat_toolbar_view.*
import kotlinx.android.synthetic.main.profile_supplier_fragment.*
import org.json.JSONException
import org.json.JSONObject
import timber.log.Timber
import javax.inject.Inject


class ChatActivity : BaseActivity() {

    @Inject
    lateinit var chatRepository: ChatRepository

    @Inject
    lateinit var loggedInUserCache: LoggedInUserCache

    private lateinit var chatViewModel: ChatViewModel
    private lateinit var chatViewAdapter: ChatViewAdapter


    var messageData: Message? = null
    var remoteMessage: JSONObject? = null


    companion object {
        private const val RECEIVER_USER = "ReceiverUser"
        const val NOTIFICATION_DATA = "Notification_data"
        const val REMOTE_MESSAGE = "remote_message"

        fun getIntent(context: Context, receiverUser: ReceiverUser): Intent {
            val intent = Intent(context, ChatActivity::class.java)
            intent.putExtra(RECEIVER_USER, receiverUser)

            return intent
        }
    }


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        QueDropApplication.component.inject(this)
        setContentView(R.layout.activity_chat)
        chatViewModel = getViewModel { ChatViewModel(chatRepository) }

        val receiverUser = intent?.getParcelableExtra<ReceiverUser>(RECEIVER_USER)

        messageData = intent?.getParcelableExtra(NOTIFICATION_DATA)


        if (intent.hasExtra(REMOTE_MESSAGE)) {
            val jsonRemoteMessage = intent.getStringExtra(REMOTE_MESSAGE)

            remoteMessage = JSONObject(jsonRemoteMessage!!)
        }

        if (receiverUser != null) {
            val senderId = loggedInUserCache.getLoggedInUser()?.user_id ?: return
            listenToViewEvents(
                userName = receiverUser.userName!!,
                userImage = receiverUser.userImagePath!!,
                orderStatus = receiverUser.orderStatus!!,
                senderId = senderId,
                receiverId = receiverUser.userId,
                orderId = receiverUser.orderId!!
            )
        } else {
            getSocketUserDetails()
        }

        listenToViewModel()

    }

    private fun getSocketUserDetails() {
        if (SocketConstants.socketIOClient != null && SocketConstants.socketIOClient!!.connected()) {
            val jsonObject = JSONObject()
            try {

                if (messageData != null) {
                    jsonObject.put(
                        SocketConstants.KeyUserId,
                        messageData?.senderId
                    )
                } else {
                    jsonObject.put(
                        SocketConstants.KeyUserId,
                        remoteMessage?.getString("sender_id")
                    )
                }

                SocketConstants.socketIOClient!!.emit(
                    SocketConstants.SocketGetUserDetails,
                    jsonObject, Ack {
                        try {
                            val messageJson = JSONObject(it[0].toString())
                            val responseStatus = messageJson.getString("status").toInt()
                            val userDetails = messageJson.getString("user")
                            runOnUiThread {
                                if (responseStatus == 1) {
//                                    val messageData =
//                                        intent?.getParcelableExtra<Message>(NOTIFICATION_DATA)

                                    val jsonObject = JSONObject(userDetails)
                                    val firstName = jsonObject.getString("first_name")
                                    val lastName = jsonObject.getString("last_name")
                                    val userName = "$firstName $lastName"

                                    val userImage = jsonObject.getString("user_image")

                                    //on noti click senderId=receiverId
                                    if (remoteMessage != null) {
                                        Log.e("Remore_messagge", "==>" + remoteMessage)
//                                        val jsonObject = JSONObject(remoteMessage!!)

                                        listenToViewEvents(
                                            userName = userName,
                                            userImage = userImage,
                                            orderStatus = remoteMessage?.getString("order_status")!!,
                                            senderId = remoteMessage?.getString("receiver_id")!!.toInt(),
                                            receiverId = remoteMessage?.getString("sender_id")!!.toInt(),
                                            orderId = remoteMessage?.getString("order_id")!!.toInt()
                                        )
                                    } else {

                                        listenToViewEvents(
                                            userName = userName,
                                            userImage = userImage,
                                            orderStatus = "",
                                            senderId = messageData?.receiverId!!,
                                            receiverId = messageData?.senderId!!,
                                            orderId = messageData?.orderId!!
                                        )
                                    }
                                }
                            }
                        } catch (e: JSONException) {
                            e.printStackTrace()
                        }
                    })
            } catch (e: JSONException) {
                e.printStackTrace()
            }
        }
    }

    private fun listenToViewModel() {
        chatViewModel.chatMessagesShows.subscribeAndObserveOnMainThread {
            chatViewAdapter.listOfMessages = it.first
            if (!it.second) {
                chatRecyclerView.smoothScrollToPosition(it.first.size - 1)
            }
        }.autoDispose()

        chatViewModel.progressBarViewShows.subscribeOnIoAndObserveOnMainThread({
            progressView.visibility = if (it) View.VISIBLE else View.GONE
        }, {
            Timber.i(it)
        }).autoDispose()
    }

    private fun listenToViewEvents(
        userName: String,
        userImage: String,
        orderStatus: String,
        senderId: Int,
        receiverId: Int,
        orderId: Int
    ) {

        val userId = loggedInUserCache.getLoggedInUser()?.user_id ?: return
        loggedInUserCache.setCurrentOrderId(orderId.toString())

        if (userImage.isNotEmpty()) {
            if (ValidationUtils.isCheckUrlOrNot(userImage)) {
                Glide.with(this).load(
                    userImage
                ).centerCrop().into(ivProfileImage)
            } else {

                Glide.with(this).load(
                    URLConstant.urlUser
                            + userImage
                ).centerCrop().into(receiverUserImageView)
            }
        }

        receiverUserNameTextView.text = userName

        if (orderStatus == EnumUtils.DELIVERED.stringVal || orderStatus == EnumUtils.CANCELLED.stringVal) {
            inputLL.visibility = View.GONE
            sendMessageButton.visibility = View.GONE
            txtOrderDelivered.visibility = View.VISIBLE
        } else {
            inputLL.visibility = View.VISIBLE
            sendMessageButton.visibility = View.VISIBLE
            txtOrderDelivered.visibility = View.GONE
        }

        chatViewAdapter = ChatViewAdapter(this, userId)
        chatRecyclerView.apply {
            adapter = chatViewAdapter
            layoutManager = LinearLayoutManager(this@ChatActivity)
        }

        swipeRefreshLayout.refreshes().subscribe {
            swipeRefreshLayout.isRefreshing = false
            chatViewModel.loadMore(
                senderId = senderId,
                receiverId = receiverId,
                orderId = orderId
            )
        }.autoDispose()

        ivBackImageView.throttleClicks().subscribe {
            onBackPressed()
        }.autoDispose()

        chatViewModel.fetchMessages(
            FetchMessageRequest(
                senderId = senderId,
                receiverId = receiverId,
                orderId = orderId
            )
        )

        sendMessageButton.throttleClicks().subscribe {
            hideKeyboard()
            val message = messageEditTextView.text.toString()
            if (message.isNotEmpty()) {
                chatViewModel.sendNewMessage(
                    SendMessageRequest(
                        senderId = senderId,
                        receiverId = receiverId,
                        message = message,
                        orderId = orderId
                    )
                )
                messageEditTextView.setText("")
            }
        }.autoDispose()
    }

    override fun onDestroy() {
        loggedInUserCache.setCurrentOrderId(null)
        super.onDestroy()
    }
}
