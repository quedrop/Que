package com.quedrop.customer.socket

import android.content.Context
import android.util.Log
import com.quedrop.customer.base.BaseActivity
import com.quedrop.customer.model.User
import com.quedrop.customer.utils.KeysUtils
import com.quedrop.customer.utils.SharedPrefsUtils
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
                if (SharedPrefsUtils.getModelPreferences(
                        mContext,
                        KeysUtils.keyUser,
                        User::class.java
                    ) != null
                ) {
                    SocketConstants.isSocketConnecting = false
                    val jsonObject = JSONObject()
                    try {
                        jsonObject.put(
                            SocketConstants.KeyUserId,
                            (SharedPrefsUtils.getModelPreferences(
                                mContext,
                                KeysUtils.keyUser,
                                User::class.java
                            ) as User).user_id
                        )
                        SocketConstants.socketIOClient?.emit(
                                SocketConstants.SocketJoinSocket,
                        jsonObject
                        )
                        Log.d("SocketZP", "Customer Join==>" +(SharedPrefsUtils.getModelPreferences(
                            mContext,
                            KeysUtils.keyUser,
                            User::class.java
                        ) as User).user_id)


                        Log.v("SocketHandler", "SocketJoinSocket:" + jsonObject.toString())

                    } catch (e: JSONException) {
                        e.printStackTrace()
                        Log.v("SocketHandler", "SocketJoinSocket:" + e.printStackTrace())

                    }
                }

            })?.on(Socket.EVENT_CONNECT_ERROR,
                Emitter.Listener { arg0 ->
                    Log.v("SocketHandler", "EVENT_CONNECT_ERROR:" + arg0[0].toString())
                })?.on(SocketConstants.SocketOrderAccepted, Emitter.Listener { args ->
                Log.v("SocketHandler", "SocketOrderAccepted:" + args[0].toString())
                socketListener?.onEvent(SocketConstants.SocketOrderAccepted, args[0] as JSONObject)
            })?.on(Socket.EVENT_CONNECT_ERROR,
                Emitter.Listener { arg0 ->
                    Log.v("SocketHandler", "EVENT_CONNECT_ERROR:" + arg0[0].toString())
                })?.on(SocketConstants.SocketStatusChanged, Emitter.Listener { args ->
                Log.v("SocketHandler", "SocketStatusChanged:" + args[0].toString())
                socketListener?.onEvent(SocketConstants.SocketStatusChanged, args[0] as JSONObject)
            })?.on(Socket.EVENT_CONNECT_ERROR,
                Emitter.Listener { arg0 ->
                    Log.v("SocketHandler", "EVENT_CONNECT_ERROR:" + arg0[0].toString())
                })?.on(SocketConstants.SocketDriverLocationChanged, Emitter.Listener { args ->
                Log.v("SocketHandler", "SocketDriverLocationChanged:" + args[0].toString())
                socketListener?.onEvent(
                    SocketConstants.SocketDriverLocationChanged,
                    args[0] as JSONObject
                )
            })?.on(SocketConstants.SocketDisconnectManually, Emitter.Listener { args ->
                Log.v("SocketHandler", "SocketDisconnectManually:" + args[0].toString())
                socketListener?.onEvent(
                    SocketConstants.SocketDisconnectManually,
                    args[0] as JSONObject
                )
            })?.on(SocketConstants.SocketSupplierJoinSocket, Emitter.Listener { args ->
                Log.v("SocketHandler", "SocketSupplierJoinSocket:" + args[0].toString())
                socketListener?.onEvent(
                    SocketConstants.SocketSupplierJoinSocket,
                    args[0] as JSONObject
                )
            })?.on(SocketConstants.SocketSupplierChangeAcknowledge, Emitter.Listener { args ->
                Log.v("SocketHandler", "SocketSupplierChangeAcknowledge:" + args[0].toString())
                socketListener?.onEvent(
                    SocketConstants.SocketSupplierChangeAcknowledge,
                    args[0] as JSONObject
                )
            })?.on(SocketConstants.SocektSupplierWeeklyPaymentAcknowledge, Emitter.Listener { args ->
                Log.v("SocketHandler", "SocektSupplierWeeklyPaymentAcknowledge:" + args[0].toString())
                socketListener?.onEvent(
                    SocketConstants.SocektSupplierWeeklyPaymentAcknowledge,
                    args[0] as JSONObject
                )
            })?.on(SocketConstants.SocketSupplierStoreVerification, Emitter.Listener { args ->
                Log.v("SocketHandler", "SocketSupplierStoreVerification:" + args[0].toString())
                socketListener?.onEvent(
                    SocketConstants.SocketSupplierStoreVerification,
                    args[0] as JSONObject
                )
            })?.on(Socket.EVENT_DISCONNECT, Emitter.Listener {
            })

            SocketConstants.socketIOClient?.connect()

        } catch (e: Exception) {
            e.printStackTrace()
        }

    }


    //...............................Supplier..........................//


    fun connectSupplier(){

    }

    fun listenSocket() {

    }
}


