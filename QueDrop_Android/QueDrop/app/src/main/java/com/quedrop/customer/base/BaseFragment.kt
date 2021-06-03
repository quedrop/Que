package com.quedrop.customer.base

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.fragment.app.Fragment
import androidx.localbroadcastmanager.content.LocalBroadcastManager
import com.quedrop.customer.base.network.NetworkObserver
import com.quedrop.customer.network.ApiInterface
import com.quedrop.customer.network.AppService
import com.quedrop.customer.socket.EventListener
import com.quedrop.customer.socket.SocketConstants
import com.quedrop.customer.socket.SocketHandler
import com.quedrop.customer.socket.SocketListener
import com.quedrop.customer.utils.BroadCastConstant
import io.reactivex.disposables.CompositeDisposable
import io.reactivex.disposables.Disposable
import io.socket.client.Socket
import org.json.JSONObject

open class BaseFragment(private val socketConnect: Boolean = true) : Fragment(), SocketListener,
    EventListener {

    protected val compositeDisposable = CompositeDisposable()
    lateinit var appService: ApiInterface
    lateinit var baseUserId: String
    lateinit var activity: Activity
    lateinit var networkObserver: NetworkObserver
    private var isAppWentToBg =/*Socket*/ false
    var socketHandler: SocketHandler? = null
    open var jsonObject: JSONObject? = null
    private var events: String? = null


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        networkObserver = NetworkObserver(activity.application)
        appService = AppService.createService(requireContext())

        if (socketConnect) {
            // initializeSocket()
        }
    }

    override fun onAttach(context: Context) {
        super.onAttach(context)
        context.let {
            activity = (context as Activity)
        }
    }

    fun checkConnection(): Boolean {
        var isCheck = false
        isCheck = networkObserver.isConnected()
        return isCheck
    }


    override fun onDestroy() {
        compositeDisposable.clear()
        super.onDestroy()
    }


    private fun getSocketIoClient(): Socket {

        if (SocketConstants.socketIOClient == null && !SocketConstants.isSocketConnecting) {
            connectSocket()
        } else if (SocketConstants.socketIOClient != null) {
            if (!SocketConstants.socketIOClient!!.connected()) {
                connectSocket()
            }
        } else {
            socketHandler = SocketHandler(requireContext())
            socketHandler!!.socketListener = (this@BaseFragment)
        }

        return SocketConstants.socketIOClient!!
    }

    private fun connectSocket() {
        try {
            val socketHandler = SocketHandler(requireContext())
            socketHandler.socketListener = (this@BaseFragment)
            if (networkObserver.isConnected()) {
                socketHandler.connectToSocket()
            }
        } catch (e: Exception) {
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


    }

    override fun isSocketConnected(connected: Boolean) {

    }

    override fun onEvent(event: String, arg0: JSONObject) {
        jsonObject = arg0
        events = event


        Log.e("onEvent", "BaseFagment")

        val intent = Intent(BroadCastConstant.BROADCAST_EVENT_CHANGE)
        intent.putExtra(BroadCastConstant.BROADCAST_KEY_EVENT, event)
        intent.putExtra(BroadCastConstant.BROADCAST_KEY_OBJ, jsonObject!!.toString())
        LocalBroadcastManager.getInstance(requireContext()).sendBroadcast(intent)
        uiHandler.post(runnable)

    }


    protected fun Disposable.autoDispose() {
        compositeDisposable.add(this)
    }

    //------------------------------------Permission---------------------------------//
    val ARRAY_PERMISSION_CODE = 309
    var ARRAY_PERMISSIONS = arrayOf(
        Manifest.permission.CAMERA,
        Manifest.permission.READ_EXTERNAL_STORAGE,
        Manifest.permission.WRITE_EXTERNAL_STORAGE
    )


    open fun requestAppPermissions(
        requestedPermissions: Array<String>,
        stringId: Int,
        requestCode: Int)
    {
        var permissionCheck = PackageManager.PERMISSION_GRANTED
        var shouldShowRequestPermissionRationale = false
        for (permission in requestedPermissions) {
            permissionCheck += ContextCompat.checkSelfPermission(
                activity,
                permission
            )
            shouldShowRequestPermissionRationale =
                shouldShowRequestPermissionRationale || ActivityCompat.shouldShowRequestPermissionRationale(
                    activity,
                    permission
                )
        }

        if (permissionCheck != PackageManager.PERMISSION_GRANTED) {
            if (shouldShowRequestPermissionRationale) {
                ActivityCompat.requestPermissions(
                    activity,
                    requestedPermissions,
                    requestCode
                )
            } else {
                ActivityCompat.requestPermissions(
                    activity,
                    requestedPermissions,
                    requestCode
                )
            }
        }
    }

    open fun hasPermissions(context: Context?): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && context != null) {
            for (permission in ARRAY_PERMISSIONS) {
                if (ActivityCompat.checkSelfPermission(context, permission) != PackageManager.PERMISSION_GRANTED) {
                    return false
                }
            }
        }
        return true
    }



    //Permission interface...
   /* private var mPermissionListener: PermissionListener? = null
    fun setOnPermissionListener(permissionListener: PermissionListener) {
        this.mPermissionListener = permissionListener
    }

    interface PermissionListener {
        fun onPermissionGranted(isGranted: Boolean)
    }*/
}