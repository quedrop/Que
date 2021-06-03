package com.quedrop.driver.socket

import android.content.Context
import android.util.Log
import com.quedrop.driver.base.BaseActivity
import com.quedrop.driver.service.model.User
import com.quedrop.driver.utils.KEY_USER
import com.quedrop.driver.utils.SharedPreferenceUtils
import io.socket.client.IO
import io.socket.client.Socket
import io.socket.emitter.Emitter
import org.json.JSONException
import org.json.JSONObject

class SocketHandler(private val mContext: Context) : BaseActivity() {

    var socketListener: SocketListener? = null
    internal var TAG = SocketHandler::class.java.toString()


    fun connectToSocket() {
        SocketConstants.isSocketConnecting = true
        try {
            val options = IO.Options()
            options.reconnection = true
            SocketConstants.socketIOClient = IO.socket(SocketConstants.SOCKET_URL, options)

            SocketConstants.socketIOClient?.on(Socket.EVENT_CONNECT, Emitter.Listener {
                if (SharedPreferenceUtils.getModelPreferences(KEY_USER, User::class.java) != null) {
                    SocketConstants.isSocketConnecting = false
                    val jsonObject = JSONObject()
                    try {
                        jsonObject.put(
                            SocketConstants.KeyUserId,
                            (SharedPreferenceUtils.getModelPreferences(
                                KEY_USER,
                                User::class.java
                            ) as User).userId
                        )
                        SocketConstants.socketIOClient?.emit(
                            SocketConstants.SocketJoinSocket,
                            jsonObject
                        )

                        Log.v("SocketHandler", "SocketJoinSocket:" + jsonObject.toString())

                    } catch (e: JSONException) {
                        e.printStackTrace()
                        Log.v("SocketHandler", "SocketJoinSocket:" + e.printStackTrace())

                    }
                }

            })?.on(Socket.EVENT_CONNECT_ERROR,
                Emitter.Listener { arg0 ->
                    Log.v("SocketHandler", "EVENT_CONNECT_ERROR:" + arg0[0].toString())
                })?.on(Socket.EVENT_DISCONNECT, Emitter.Listener {
            })?.on(SocketConstants.SocketGetOrderRequest, Emitter.Listener { args ->
                val data = args[0] as JSONObject
                Log.v("SocketHandler", "SocketTripStatusUpdate:" + args[0].toString())
                socketListener?.onEvent(
                    SocketConstants.SocketGetOrderRequest,
                    args[0] as JSONObject
                )
            })?.on(SocketConstants.SocketGetDriverWorkingStatus, Emitter.Listener { args ->
                val data = args[0] as JSONObject
                Log.v("SocketHandler", "SocketTripStatusUpdate:" + args[0].toString())
                socketListener?.onEvent(
                    SocketConstants.SocketGetDriverWorkingStatus,
                    args[0] as JSONObject
                )

            })?.on(SocketConstants.SocketOrderDeliveryAcknowledge, Emitter.Listener { args ->
                val data = args[0] as JSONObject
                Log.v("SocketHandler", "SocketOrderDeliveryAcknowledge:" + args[0].toString())
                socketListener?.onEvent(
                    SocketConstants.SocketOrderDeliveryAcknowledge,
                    args[0] as JSONObject
                )
            })?.on(SocketConstants.SocketDriverVerificationChange, Emitter.Listener { args ->
                val data = args[0] as JSONObject
                Log.v("SocketHandler", "SocketDriverVerificationChange:" + args[0].toString())
                socketListener?.onEvent(
                    SocketConstants.SocketDriverVerificationChange,
                    args[0] as JSONObject
                )
            })?.on(SocketConstants.SocketDriverWeeklyPaymentAcknowledge, Emitter.Listener { args ->
                val data = args[0] as JSONObject
                Log.v("SocketHandler", "SocketDriverWeeklyPaymentAcknowledge:" + args[0].toString())
                socketListener?.onEvent(
                    SocketConstants.SocketDriverWeeklyPaymentAcknowledge,
                    args[0] as JSONObject
                )
            })?.on(SocketConstants.SocketManualStorePaymentAcknowledge, Emitter.Listener { args ->
                val data = args[0] as JSONObject
                Log.v("SocketHandler", "SocketManualStorePaymentAcknowledge:" + args[0].toString())
                socketListener?.onEvent(
                    SocketConstants.SocketManualStorePaymentAcknowledge,
                    args[0] as JSONObject
                )
            })?.on(SocketConstants.SocketOrderAccepted, Emitter.Listener { args ->
                val data = args[0] as JSONObject
                Log.v("SocketHandler", "SocketOrderAccepted:" + args[0].toString())
                socketListener?.onEvent(
                    SocketConstants.SocketOrderAccepted,
                    args[0] as JSONObject
                )
            })?.on(Socket.EVENT_RECONNECT, Emitter.Listener {
            })

            SocketConstants.socketIOClient?.connect()
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
}


