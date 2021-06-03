package com.quedrop.driver.base

import android.app.Activity
import android.app.Dialog
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.*
import androidx.fragment.app.Fragment
import androidx.localbroadcastmanager.content.LocalBroadcastManager
import com.quedrop.driver.R
import com.quedrop.driver.base.network.NetworkObserver
import com.quedrop.driver.service.ApiService
import com.quedrop.driver.service.AppService
import com.quedrop.driver.socket.EventListener
import com.quedrop.driver.socket.SocketConstants
import com.quedrop.driver.socket.SocketListener
import com.quedrop.driver.utils.*
import com.quedrop.driver.utils.localnotification.MyNotificationPublisher
import com.quedrop.driver.viewModel.MainViewModel
import io.reactivex.disposables.CompositeDisposable
import io.reactivex.disposables.Disposable
import org.json.JSONObject

open class BaseFragment(private val socketConnect: Boolean = true) : Fragment(), SocketListener,
    EventListener {

    protected val compositeDisposable = CompositeDisposable()
    lateinit var appService: ApiService
    lateinit var mainViewModel: MainViewModel
    private var progressBar: Dialog? = null

    lateinit var activity: Activity
    lateinit var networkObserver: NetworkObserver


    open var jsonObject: JSONObject? = null
    private var events: String? = null
    var globalUserId = 0

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        networkObserver = NetworkObserver(activity.application)
        appService = AppService.createService(activity)
        mainViewModel = MainViewModel(appService)
        initializeLoader()

    }

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        return super.onCreateView(inflater, container, savedInstanceState)
    }

    protected fun Disposable.autoDispose() {
        compositeDisposable.add(this)
    }

    override fun onAttach(context: Context) {
        super.onAttach(context)
        context.let {
            activity = (context as Activity)
        }
    }


    override fun onDestroy() {
        compositeDisposable.clear()
        super.onDestroy()
    }

    internal var uiHandler = Handler(Looper.getMainLooper())

    var runnable: Runnable = Runnable {
        if (events != null && jsonObject != null) {
            parseResponseInMain(events!!, jsonObject!!)
        }
    }


    private fun initializeLoader() {
        progressBar = Dialog(activity)
        val lWindowParams = WindowManager.LayoutParams()
        progressBar?.requestWindowFeature(Window.FEATURE_NO_TITLE)
        progressBar?.setCancelable(false)
        progressBar?.window!!.setBackgroundDrawableResource(R.color.text_black_transparent)
        lWindowParams.width = WindowManager.LayoutParams.MATCH_PARENT
        progressBar?.setContentView(R.layout.loader_view)
        progressBar?.window!!.attributes = lWindowParams
        progressBar?.window!!.setGravity(Gravity.CENTER)
    }


    fun showProgress() {
        if (progressBar != null && !progressBar?.isShowing!!) {
            progressBar?.show()
        }
    }

    fun hideProgress() {
        if (progressBar != null && progressBar?.isShowing!!) {
            progressBar?.dismiss()
        }
    }


    private fun parseResponseInMain(event: String, argument: JSONObject) {
        Log.e("Event", "==>" + event)
        when (event) {
            SocketConstants.SocketDriverWeeklyPaymentAcknowledge -> {
                val driverId = argument.getString("driver_id")
                val message = argument.getString("message")
                val title = argument.getString("title")

                if (driverId == SharedPreferenceUtils.getInt(KEY_USERID).toString())
                    MyNotificationPublisher.scheduleNotification(
                        context!!,
                        MyNotificationPublisher.getNotification(
                            context!!,
                            title,
                            message
                            , Key_Earning_payment
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
                        context!!,
                        MyNotificationPublisher.getNotification(
                            context!!,
                            title,
                            message
                            , Key__Manual_payment
                        ),
                        100
                    )
            }

        }

    }

    override fun isSocketConnected(connected: Boolean) {

        Log.e("isSocketConnected", "==>" + connected)
    }

    override fun onEvent(event: String, arg0: JSONObject) {
        jsonObject = arg0
        events = event
        Log.e("Event@", "==>" + event)
        val intent = Intent(BroadCastConstant.BROADCAST_EVENT_CHANGE)
        intent.putExtra(BroadCastConstant.BROADCAST_KEY_EVENT, event)
        intent.putExtra(BroadCastConstant.BROADCAST_KEY_OBJ, jsonObject!!.toString())
        LocalBroadcastManager.getInstance(requireContext()).sendBroadcast(intent)
        uiHandler.post(runnable)

    }

}