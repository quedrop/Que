package com.quedrop.driver.base

import android.app.ActivityManager
import android.app.Dialog
import android.content.Context
import android.content.Intent
import android.os.*
import android.util.Log
import android.view.Gravity
import android.view.Window
import android.view.WindowManager
import androidx.appcompat.app.AppCompatActivity
import androidx.localbroadcastmanager.content.LocalBroadcastManager
import com.quedrop.driver.R
import com.quedrop.driver.base.network.NetworkObserver
import com.quedrop.driver.service.ApiService
import com.quedrop.driver.service.AppService
import com.quedrop.driver.service.model.User
import com.quedrop.driver.socket.EventListener
import com.quedrop.driver.socket.SocketConstants
import com.quedrop.driver.socket.SocketHandler
import com.quedrop.driver.socket.SocketListener
import com.quedrop.driver.utils.*
import com.quedrop.driver.utils.localnotification.MyNotificationPublisher
import com.quedrop.driver.viewModel.MainViewModel
import io.github.douglasjunior.androidSimpleTooltip.OverlayView
import io.github.douglasjunior.androidSimpleTooltip.SimpleTooltip
import io.reactivex.disposables.CompositeDisposable
import io.reactivex.disposables.Disposable
import io.socket.client.Socket
import kotlinx.android.synthetic.main.toolbar_normal.*
import org.json.JSONObject


open class BaseActivity(private val socketConnect: Boolean = true) : AppCompatActivity(),
    SocketListener,
    EventListener {

    lateinit var networkObserver: NetworkObserver
    lateinit var appService: ApiService
    lateinit var mainViewModel: MainViewModel
    lateinit var baseUserId: String
    lateinit var progressBar: Dialog
    var globalUserId = 0

    protected val compositeDisposable = CompositeDisposable()

    private var isAppWentToBg =/*Socket*/ false
    private var socketHandler: SocketHandler? = null
    open var jsonObject: JSONObject? = null
    private var events: String? = null


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        networkObserver = NetworkObserver(application)
        appService = AppService.createService(this)
        mainViewModel = MainViewModel(appService)

        initializeLoader()
        if (socketConnect) {
            if (SharedPreferenceUtils.getModelPreferences(KEY_USER, User::class.java) != null)
                initializeSocket()
        }

    }

    private fun initializeLoader() {
        progressBar = Dialog(this)
        val lWindowParams = WindowManager.LayoutParams()
        progressBar.requestWindowFeature(Window.FEATURE_NO_TITLE)
        progressBar.setCancelable(false)
        progressBar.window!!.setBackgroundDrawableResource(R.color.text_black_transparent)
        lWindowParams.width = WindowManager.LayoutParams.MATCH_PARENT
        progressBar.setContentView(R.layout.loader_view)
        progressBar.window!!.attributes = lWindowParams
        progressBar.window!!.setGravity(Gravity.CENTER)
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
            socketHandler!!.socketListener = (this@BaseActivity)
        }

        return SocketConstants.socketIOClient!!
    }

    private fun connectSocket() {
        try {
            if (SharedPreferenceUtils.getModelPreferences(KEY_USER, User::class.java) != null) {
                val userID = (SharedPreferenceUtils.getModelPreferences(
                    KEY_USER,
                    User::class.java
                ) as User).userId.toString()
                if (!userID.isNullOrEmpty()) {
                    val socketHandler = SocketHandler(this)
                    socketHandler.socketListener = (this@BaseActivity)
                    if (networkObserver.isConnected()) {
                        socketHandler.connectToSocket()
                    }
                }
            }


        } catch (e: Exception) {
            e.printStackTrace()
        }

    }

    override fun onDestroy() {
        compositeDisposable.clear()
        super.onDestroy()
    }

    fun showProgress() {
        if (!progressBar.isShowing) {
            progressBar.show()
        }
    }

    fun hideProgress() {
        if (progressBar.isShowing) {
            progressBar.dismiss()
        }
    }

    private fun applicationDidEnterBackground() {
        if (isAppIsInBackground(this)) {
            isAppWentToBg = true
        }
    }

    private fun isAppIsInBackground(context: Context): Boolean {
        try {
            var isInBackground = true
            val am = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
            if (Build.VERSION.SDK_INT > Build.VERSION_CODES.KITKAT_WATCH) {
                val runningProcesses = am.runningAppProcesses
                for (processInfo in runningProcesses) {
                    if (processInfo.importance == ActivityManager.RunningAppProcessInfo.IMPORTANCE_FOREGROUND) {
                        for (activeProcess in processInfo.pkgList) {
                            if (activeProcess == context.packageName) {
                                isInBackground = false
                            }
                        }
                    }
                }
            } else {
                val taskInfo = am.getRunningTasks(1)
                val componentInfo = taskInfo[0].topActivity
                if (componentInfo!!.packageName == context.packageName) {
                    isInBackground = false
                }
            }

            return isInBackground
        } catch (e: Exception) {
            e.printStackTrace()
        }

        return false
    }

    internal var uiHandler = Handler(Looper.getMainLooper())

    var runnable: Runnable = Runnable {
        if (events != null && jsonObject != null) {
            parseResponseInMain(events!!, jsonObject!!)
        }
    }

    private fun parseResponseInMain(event: String, argument: JSONObject) {
        when (event) {
            SocketConstants.SocketDriverWeeklyPaymentAcknowledge -> {
                val driverId = argument.getString("driver_id")
                val message = argument.getString("message")
                val title = argument.getString("title")

                if (driverId == SharedPreferenceUtils.getInt(KEY_USERID).toString())
                    MyNotificationPublisher.scheduleNotification(
                        this,
                        MyNotificationPublisher.getNotification(
                            this,
                            title,
                            message,
                            Key_Earning_payment
                        ),
                        100
                    )
            }
            SocketConstants.SocketManualStorePaymentAcknowledge -> {
                val driverId = argument.getString("driver_id")
                val message = argument.getString("message")
                val title = argument.getString("title")

                if (driverId == SharedPreferenceUtils.getInt(KEY_USERID).toString())
                    MyNotificationPublisher.scheduleNotification(
                        this,
                        MyNotificationPublisher.getNotification(
                            this,
                            title,
                            message,
                            Key__Manual_payment
                        ),
                        100
                    )
            }

        }

    }

    override fun isSocketConnected(connected: Boolean) {
    }

    override fun onEvent(event: String, arg0: JSONObject) {
        jsonObject = arg0
        events = event
        Log.e("Event@", "==>" + event)
        val intent = Intent(BroadCastConstant.BROADCAST_EVENT_CHANGE)
        intent.putExtra(BroadCastConstant.BROADCAST_KEY_EVENT, event)
        intent.putExtra(BroadCastConstant.BROADCAST_KEY_OBJ, jsonObject!!.toString())
        LocalBroadcastManager.getInstance(this).sendBroadcast(intent)
        uiHandler.post(runnable)
    }

    protected fun Disposable.autoDispose() {
        compositeDisposable.add(this)
    }

    fun addToolTipView(text:String) {
        val toolTip = SimpleTooltip.Builder(this)
            .anchorView(info)
            .text(text)
            .gravity(Gravity.BOTTOM)
            .backgroundColor(resources.getColor(R.color.colorBlack))
            .textColor(resources.getColor(R.color.colorWhite))
            .highlightShape(OverlayView.HIGHLIGHT_SHAPE_OVAL)
            .arrowColor(resources.getColor(R.color.colorBlack))
            .dismissOnInsideTouch(true)
            .dismissOnOutsideTouch(true)
            .animated(true)
            .animationDuration(2000)
            .onDismissListener { tooltip ->
                println("dismiss $tooltip")

            }
            .onShowListener { tooltip ->
                println("show $tooltip")

            }
            .build()

        Log.e("isShowing","==>"+toolTip)
        if (toolTip.isShowing == true) {
            toolTip.dismiss()
        } else {
            toolTip.show()
        }
    }

}