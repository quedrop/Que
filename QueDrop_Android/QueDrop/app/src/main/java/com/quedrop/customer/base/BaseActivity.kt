package com.quedrop.customer.base

import android.app.*
import android.content.Context
import android.content.Intent
import android.content.res.Configuration
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.Gravity
import android.view.Window
import android.view.WindowManager
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.Observer
import androidx.localbroadcastmanager.content.LocalBroadcastManager
import com.quedrop.customer.R
import com.quedrop.customer.base.extentions.startActivityWithDefaultAnimations
import com.quedrop.customer.base.network.NetworkObserver
import com.quedrop.customer.model.LogOutRequest
import com.quedrop.customer.model.User
import com.quedrop.customer.network.ApiInterface
import com.quedrop.customer.network.AppService
import com.quedrop.customer.socket.EventListener
import com.quedrop.customer.socket.SocketConstants
import com.quedrop.customer.socket.SocketHandler
import com.quedrop.customer.socket.SocketListener
import com.quedrop.customer.ui.profile.viewmodel.ProfileViewModel
import com.quedrop.customer.ui.selectaddress.view.SelectAddressActivity
import com.quedrop.customer.ui.splash.SplashActivity
import com.quedrop.customer.utils.*
import io.reactivex.disposables.CompositeDisposable
import io.reactivex.disposables.Disposable
import io.socket.client.Ack
import io.socket.client.Socket
import org.json.JSONException
import org.json.JSONObject

abstract class BaseActivity(private val socketConnect: Boolean = true) : AppCompatActivity(),
    SocketListener,
    EventListener {

    private var isAppWentToBg =/*Socket*/ false
    var socketHandler: SocketHandler? = null
    open var jsonObject: JSONObject? = null
    private var events: String? = null
    lateinit var networkObserver: NetworkObserver
    lateinit var appService: ApiInterface
    lateinit var baseUserId: String
    lateinit var progressBar: Dialog
    lateinit var mcontext: Activity

    private lateinit var profileViewModel: ProfileViewModel

    var pspDialogUtils: PspDialogUtils? = null

    val compositeDisposable = CompositeDisposable()

    override fun onCreate(savedInstanceState: Bundle?) {
        if (isAndroidTV()) {
            requestWindowFeature(Window.FEATURE_OPTIONS_PANEL)
        }
        super.onCreate(savedInstanceState)
        mcontext = this

        networkObserver = NetworkObserver(application)
        appService = AppService.createService(this)

        profileViewModel = ProfileViewModel(appService)
        pspDialogUtils = PspDialogUtils(mcontext)

        initializeLoader()
        if (socketConnect) {
            initializeSocket()
        }

        val role = SharedPrefsUtils.getIntegerPreference(
            applicationContext,
            KeysUtils.keyUserType,
            ConstantUtils.USER_TYPE_CUSTOMER
        )
        when (role) {
            ConstantUtils.USER_TYPE_SUPPLIER -> {
                val isRevoke =
                    SharedPrefsUtils.getIntegerPreference(this, KeysUtils.PREF_KEY_IS_REVOKE, 0)
                val message =
                    SharedPrefsUtils.getStringPreference(this, KeysUtils.PREF_KEY_REVOKE_MESSAGE)
                if (isRevoke == 1) {
                    // showAlert(message!!)
                }
            }
        }

    }

    private fun initializeLoader() {

        try {
            progressBar = Dialog(this)
            val lWindowParams = WindowManager.LayoutParams()
            progressBar.requestWindowFeature(Window.FEATURE_NO_TITLE)
            progressBar.setCancelable(false)
            progressBar.window!!.setBackgroundDrawableResource(R.color.text_black_transparent)
            lWindowParams.width = WindowManager.LayoutParams.MATCH_PARENT
            progressBar.setContentView(R.layout.loader_view)
            progressBar.window!!.attributes = lWindowParams
            progressBar.window!!.setGravity(Gravity.CENTER)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun initializeSocket() {
        Log.i("SSS", "initializeSocket: ")
        if (networkObserver.isConnected()) {
            if (SocketConstants.socketIOClient != null) {
                Log.i("SSS", "initializeSocket: SOCKET IO CLIENT NULL")


                if (SocketConstants.socketIOClient!!.connected()) {
                    Log.i("SSS", "initializeSocket: SOCKET IO CONNECT")
                    socketHandler = SocketHandler(this)
                    socketHandler?.socketListener = (this)
                } else {
                    Log.i("SSS", "initializeSocket: GET IO SOCKET ELSE")
                    getSocketIoClient()
                }
            } else {
                Log.i("SSS", "initializeSocket: GET IO SOCKET DOUBLE ELSE")
                getSocketIoClient()
            }
        }
    }

    private fun getSocketIoClient(): Socket {

        if (SocketConstants.socketIOClient == null && !SocketConstants.isSocketConnecting) {
            connectSocket()
        } else if (SocketConstants.socketIOClient != null) {
            if (!SocketConstants.socketIOClient!!.connected()) {
                connectSocket()
            }
        } else {
            socketHandler = SocketHandler(this@BaseActivity)
            socketHandler!!.socketListener = (this)
        }

        return SocketConstants.socketIOClient!!
    }

    private fun connectSocket() {
        try {
//            if (SharedPrefsUtils.getModelPreferences(
//                    applicationContext,
//                    KeysUtils.keyUser,
//                    User::class.java
//                ) != null
//            ) {
//                val userID = (SharedPrefsUtils.getModelPreferences(
//                    applicationContext,
//                    KeysUtils.keyUser,
//                    User::class.java
//                ) as User).user_id.toString()
//                if (!userID.isNullOrEmpty()) {
            val socketHandler = SocketHandler(this)
            socketHandler.socketListener = (this)

            if (networkObserver.isConnected()) {
                socketHandler.connectToSocket()
            }


        } catch (e: Exception) {
            e.printStackTrace()
        }

    }

    override fun onDestroy() {
        compositeDisposable.clear()
        hideProgress()
        super.onDestroy()
    }

    fun showProgress() {
        try {
            if (!progressBar.isShowing) {
                println(" @@ showProgress SHOW")
                progressBar.show()
            }
        } catch (e: java.lang.Exception) {
            e.printStackTrace()
        }
    }

    fun hideProgress() {
        try {

            if (progressBar.isShowing) {
                /*Handler().postDelayed({
                    runOnUiThread {*/
                progressBar.dismiss()
                // }
                //},800L)
            }
        } catch (e: java.lang.Exception) {
            e.printStackTrace()
        }

    }

    internal var uiHandler = Handler(Looper.getMainLooper())

    var runnable: Runnable = Runnable {
        if (events != null && jsonObject != null) {
            parseResponseInMain(events!!, jsonObject!!)
        }
    }

    private fun parseResponseInMain(event: String, argument: JSONObject) {
        when (event) {
            SocketConstants.SocketSupplierChangeAcknowledge -> {

                val userId =
                    SharedPrefsUtils.getIntegerPreference(this, KeysUtils.KeyUserSupplierId, 0)
                val storeId =
                    SharedPrefsUtils.getIntegerPreference(this, KeysUtils.keySupplierStoreId, 0)

                val messageJson = JSONObject(argument.toString())
                val store_id = messageJson.getString("store_id")
                val message = messageJson.getString("message")
                val user_id = messageJson.getString("user_id").toInt()
                val is_revoke = messageJson.getString("is_revoke")

                if (userId == user_id && storeId == store_id.toInt() && is_revoke.toInt() == 1) {

                    /* SharedPrefsUtils.setIntegerPreference(
                         mcontext,
                         KeysUtils.PREF_KEY_IS_REVOKE,
                         is_revoke.toInt()
                     )

                     SharedPrefsUtils.setStringPreference(
                         this,
                         KeysUtils.PREF_KEY_REVOKE_MESSAGE,
                         message
                     )*/
                    // Toast.makeText(this, "Alert Dialog", Toast.LENGTH_LONG).show()

                    // showAlert(message)

                } else {
                    SharedPrefsUtils.setIntegerPreference(
                        mcontext,
                        KeysUtils.PREF_KEY_IS_REVOKE,
                        is_revoke.toInt()
                    )
                }
            }

            SocketConstants.SocketOrderAccepted -> {
                val orderId = argument.getString("order_id")
                val driverId = argument.getString("driver_id")
                val status = argument.getString("status")
//                val orderStatus = argument.getString("order_status")

                Log.e("main", "===order")

                val mNotificationManager =
                    getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

                var profilename = "User"
                val userData = (SharedPrefsUtils.getModelPreferences(
                    applicationContext,
                    KeysUtils.keyUser,
                    User::class.java
                )) as User?
                if (userData != null) {
                    profilename = userData.first_name + " " + userData.last_name
                }

                val title = "Order Accept"
                val body = "Hey " + profilename + " ,your current order request is accepted."

                val notification = NotificationCreator.getNotification(
                    this,
                    notificationIntent("2", orderId.toInt()),
                    title,
                    body
                )
                notification?.flags = Notification.FLAG_AUTO_CANCEL
                mNotificationManager.notify(
                    NotificationCreator.getNotificationId(),
                    notification
                )


            }
            SocketConstants.SocketStatusChanged -> {

                val orderId = argument.getString("order_id")
                val orderStatus = argument.getString("order_status")
                val mNotificationManager =
                    getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

                when (orderStatus) {
                    EnumUtils.DISPATCH.stringVal -> {

                        var profilename = "User"
                        val userData = (SharedPrefsUtils.getModelPreferences(
                            applicationContext,
                            KeysUtils.keyUser,
                            User::class.java
                        )) as User?
                        if (userData != null) {
                            profilename = userData.first_name + " " + userData.last_name
                        }


                        Log.e("dispatch", "==" + EnumUtils.DISPATCH.stringVal)
                        val title = "Order Dispatch"
                        val body =
                            "Hey " + profilename + " ,your current order request is Dispatched."

                        val notification = NotificationCreator.getNotification(
                            this,
                            notificationIntent(
                                ENUMNotificationType.ORDER_DISPATCH.posVal.toString(),
                                orderId.toInt()
                            ),
                            title,
                            body
                        )
                        notification?.flags = Notification.FLAG_AUTO_CANCEL
                        mNotificationManager.notify(
                            NotificationCreator.getNotificationId(),
                            notification
                        )
                    }
                    EnumUtils.DELIVERED.stringVal -> {

                        var profilename = "User"
                        val userData = (SharedPrefsUtils.getModelPreferences(
                            applicationContext,
                            KeysUtils.keyUser,
                            User::class.java
                        )) as User?
                        if (userData != null) {
                            profilename = userData.first_name + " " + userData.last_name
                        }

                        val title = "Order Delivered"
                        val body =
                            "Hey " + profilename + " ,your current order request is Delivered."

                        val notification = NotificationCreator.getNotification(
                            this,
                            notificationIntent(
                                ENUMNotificationType.ORDER_DELIVERED.posVal.toString(),
                                orderId.toInt()
                            ),
                            title,
                            body
                        )
                        notification?.flags = Notification.FLAG_AUTO_CANCEL
                        mNotificationManager.notify(
                            NotificationCreator.getNotificationId(),
                            notification
                        )
                    }
                }
            }
        }

    }


    fun showAlert(message: String) {
        val builder = AlertDialog.Builder(this@BaseActivity)

        builder.setMessage(message)
            .setCancelable(false)
            .setPositiveButton("OK") { dialog, id ->
                logOutModule()

                profileViewModel.logOutData.observe(this, Observer {

                    SharedPrefsUtils.setIntegerPreference(
                        applicationContext,
                        KeysUtils.keyUserType,
                        ConstantUtils.USER_TYPE_CUSTOMER
                    )

                    val intent = Intent(this@BaseActivity, SelectAddressActivity::class.java)
                    intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
                    startActivityWithDefaultAnimations(intent)
                    finish()
                })

                dialog.dismiss()
            }
        builder.create()
        builder.show()
    }


    override fun isSocketConnected(connected: Boolean) {

    }

    override fun onEvent(event: String, arg0: JSONObject) {
        jsonObject = arg0
        events = event

        val intent = Intent(BroadCastConstant.BROADCAST_EVENT_CHANGE)
        intent.putExtra(BroadCastConstant.BROADCAST_KEY_EVENT, event)
        intent.putExtra(BroadCastConstant.BROADCAST_KEY_OBJ, jsonObject!!.toString())
        LocalBroadcastManager.getInstance(this).sendBroadcast(intent)
        uiHandler.post(runnable)
    }


    private fun isAndroidTV(): Boolean {
        val uiModeManager = getSystemService(Activity.UI_MODE_SERVICE) as UiModeManager
        return uiModeManager.currentModeType == Configuration.UI_MODE_TYPE_TELEVISION
    }

    protected fun Disposable.autoDispose() {
        compositeDisposable.add(this)
    }

    fun joinSupplierSocket() {

        if (SocketConstants.socketIOClient != null && SocketConstants.socketIOClient!!.connected()) {
            val jsonObject = JSONObject()
            try {

                val userId =
                    SharedPrefsUtils.getIntegerPreference(this, KeysUtils.KeyUserSupplierId, 0)
                val storeId =
                    SharedPrefsUtils.getIntegerPreference(this, KeysUtils.keySupplierStoreId, 0)

                jsonObject.put(SocketConstants.KeyUserId, userId)
                jsonObject.put(SocketConstants.KeyStoreId, storeId)


                SocketConstants.socketIOClient!!.emit(SocketConstants.SocketSupplierJoinSocket,
                    jsonObject, Ack {
                        try {
                            val messageJson = JSONObject(it[0].toString())
                            val store_id = messageJson.getString("store_id")
                            val message = messageJson.getString("message")
                            val user_id = messageJson.getString("user_id").toInt()
                            val is_revoke = messageJson.getString("is_revoke")

                            if (userId == user_id && storeId == store_id.toInt() && is_revoke.toInt() == 1) {

                                SharedPrefsUtils.setIntegerPreference(
                                    mcontext,
                                    KeysUtils.PREF_KEY_IS_REVOKE,
                                    is_revoke.toInt()
                                )

                                SharedPrefsUtils.setStringPreference(
                                    this,
                                    KeysUtils.PREF_KEY_REVOKE_MESSAGE,
                                    message
                                )

                            } else {
                                SharedPrefsUtils.setIntegerPreference(
                                    mcontext,
                                    KeysUtils.PREF_KEY_IS_REVOKE,
                                    is_revoke.toInt()
                                )
                            }

                        } catch (e: JSONException) {
                            e.printStackTrace()
                        }

                    })
            } catch (e: JSONException) {
                e.printStackTrace()
            }

        } else {
            Log.e("Socket", "disconnected")
        }

    }

    fun disconnectSocketManually(userId: Int) {

        if (SocketConstants.socketIOClient != null && SocketConstants.socketIOClient!!.connected()) {
            val jsonObject = JSONObject()
            try {

                jsonObject.put(SocketConstants.KeyUserId, userId)

                SocketConstants.socketIOClient!!.emit(SocketConstants.SocketDisconnectManually,
                    jsonObject, Ack {
                        try {
                            val messageJson = JSONObject(it[0].toString())
                            val responseStatus = messageJson.getString("status").toInt()

                            Log.e("Status", responseStatus.toString())
                            if (responseStatus == 1) {

                            }

                        } catch (e: JSONException) {
                            e.printStackTrace()
                        }

                    })
            } catch (e: JSONException) {
                e.printStackTrace()
            }

        } else {
            Log.e("Socket", "disconnected")
        }

    }

    private fun logOutModule() {

        SharedPrefsUtils.removeSharedPreference(this, KeysUtils.KeySupplierUser)
        SharedPrefsUtils.setBooleanPreference(
            this,
            KeysUtils.keySession,
            false
        )
        SharedPrefsUtils.setBooleanPreference(
            this,
            KeysUtils.keyMap,
            false
        )

        SharedPrefsUtils.setIntegerPreference(
            this,
            KeysUtils.KeyUserSupplierId,
            0
        )


        logOutApiCall()
    }

    private fun logOutApiCall() {
        profileViewModel.logOutApiCall(getLogOutRequest())

    }

    private fun getLogOutRequest(): LogOutRequest {
        return LogOutRequest(
            Utils.seceretKey,
            Utils.Supplier.supplierAccessKey,
            Utils.Supplier.supplierUserId,
            Utils.deviceToken,
            ConstantUtils.DEVICE_TYPE,
            ConstantUtils.USER_TYPE_S
        )
    }

    private fun notificationIntent(notification_type: String, orderIdMain: Int?): Intent {
        var intent: Intent? = null

        when (notification_type.toInt()) {

            ENUMNotificationType.ORDER_ACCEPT.posVal -> {
                Log.e("order_accept", "===order")
                intent = Intent(this, SplashActivity::class.java).apply {

                    putExtra(KeysUtils.keyCustomer, getString(R.string.orderScreen))
                    putExtra("order_id", orderIdMain)
                    putExtra("notification_type", notification_type)
                    putExtra("noti_id", NotificationCreator.getNotificationId())
                }

            }
            ENUMNotificationType.ORDER_REJECT.posVal -> {
                intent = Intent(this, SplashActivity::class.java).apply {
                    putExtra(KeysUtils.keyCustomer, getString(R.string.orderScreen))
                    putExtra("order_id", orderIdMain)
                    putExtra("notification_type", notification_type)
                    putExtra("noti_id", NotificationCreator.getNotificationId())
                }

            }
            ENUMNotificationType.ORDER_REQUEST_TIMEOUT.posVal -> {
                intent = Intent(this, SplashActivity::class.java).apply {
                    putExtra(KeysUtils.keyCustomer, getString(R.string.orderScreen))
                    putExtra("order_id", orderIdMain)
                    putExtra("notification_type", notification_type)
                    putExtra("noti_id", NotificationCreator.getNotificationId())
                }
            }

            ENUMNotificationType.ORDER_DISPATCH.posVal -> {
                intent = Intent(this, SplashActivity::class.java).apply {
                    putExtra(KeysUtils.keyCustomer, getString(R.string.orderScreen))
                    putExtra("order_id", orderIdMain)
                    putExtra("notification_type", notification_type)
                    putExtra("noti_id", NotificationCreator.getNotificationId())
                }

            }

            ENUMNotificationType.ORDER_CANCELLED.posVal -> {
                intent = Intent(this, SplashActivity::class.java).apply {
                    putExtra(KeysUtils.keyCustomer, getString(R.string.orderScreen))
                    putExtra("order_id", orderIdMain)
                    putExtra("notification_type", notification_type)
                    putExtra("noti_id", NotificationCreator.getNotificationId())
                }

            }
            ENUMNotificationType.ORDER_DELIVERED.posVal -> {
                intent = Intent(this, SplashActivity::class.java).apply {
                    putExtra(KeysUtils.keyCustomer, getString(R.string.orderScreen))
                    putExtra("order_id", orderIdMain)
                    putExtra("notification_type", notification_type)
                    putExtra("noti_id", NotificationCreator.getNotificationId())
                }
            }

        }

        return intent!!

    }
}