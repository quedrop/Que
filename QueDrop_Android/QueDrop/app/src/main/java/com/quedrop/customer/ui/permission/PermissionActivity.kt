package com.quedrop.customer.ui.permission

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.IntentSender.SendIntentException
import android.content.pm.PackageManager
import android.location.LocationManager
import android.os.Bundle
import android.util.Log
import android.widget.Toast
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.lifecycle.Observer
import com.quedrop.customer.R
import com.quedrop.customer.base.BaseActivity
import com.quedrop.customer.base.extentions.startActivityWithDefaultAnimations
import com.quedrop.customer.base.rxjava.autoDispose
import com.quedrop.customer.base.rxjava.throttleClicks
import com.quedrop.customer.model.TokenRequest
import com.quedrop.customer.ui.register.viewModel.RegisterViewModel
import com.quedrop.customer.ui.selectaddress.view.SelectAddressActivity
import com.quedrop.customer.utils.ConstantUtils
import com.quedrop.customer.utils.KeysUtils
import com.quedrop.customer.utils.SharedPrefsUtils
import com.quedrop.customer.utils.Utils
import com.google.android.gms.common.api.GoogleApiClient
import com.google.android.gms.common.api.GoogleApiClient.ConnectionCallbacks
import com.google.android.gms.common.api.PendingResult
import com.google.android.gms.common.api.Status
import com.google.android.gms.location.LocationRequest
import com.google.android.gms.location.LocationServices
import com.google.android.gms.location.LocationSettingsRequest
import com.google.android.gms.location.LocationSettingsResult
import com.google.android.gms.location.LocationSettingsStatusCodes
import kotlinx.android.synthetic.main.activity_main.*


class PermissionActivity : BaseActivity() {
    private var googleApiClient: GoogleApiClient? = null
    final val REQUEST_LOCATION: Int = 199

    private val TAG = PermissionActivity::class.java.simpleName
    private var tempString: String? = null
    private var orderId: Int? = null

    private var remoteMessage: String? = null

    private var permissions = arrayOf<String>(

        Manifest.permission.ACCESS_FINE_LOCATION
    )
    lateinit var registerViewModel: RegisterViewModel

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        intent?.let { intent ->
            intent.getStringExtra(KeysUtils.keyCustomer)?.let {
                Log.e(TAG, it)
                tempString = it
            }
            intent.getIntExtra(KeysUtils.keyOrderId, 0).let {
                Log.e(TAG, it.toString())
                orderId = it
            }
            intent.getStringExtra(KeysUtils.KeyRemoteMessage).let {
                remoteMessage = it
            }
        }

        setFinishOnTouchOutside(true)
        Utils.accessKey = "nousername"
        Utils.seceretKey = "Is1YE9nQYMbOFzjtV77K/3MdKMqwt8NQVGc+aRyoeRU="
        Utils.Supplier.supplierAccessKey = "nousername"

        SharedPrefsUtils.setStringPreference(
            applicationContext,
            KeysUtils.KeySupplierAccessKey,
            Utils.Supplier.supplierAccessKey
        )


        SharedPrefsUtils.setStringPreference(
            applicationContext,
            KeysUtils.keyAccessKey,
            Utils.accessKey
        )

        SharedPrefsUtils.setStringPreference(
            applicationContext,
            KeysUtils.keySecretKey,
            Utils.seceretKey
        )

        registerViewModel = RegisterViewModel(appService)
        initMethod()
        checkPermissionMethod()


        ivGPSOn.throttleClicks().subscribe {

            val manager =
                this.getSystemService(Context.LOCATION_SERVICE) as LocationManager

            if (!hasGPSDevice(this)) {
                Toast.makeText(
                    this,
                    "Gps not Supported",
                    Toast.LENGTH_SHORT
                ).show()
            }

            if (!manager.isProviderEnabled(LocationManager.GPS_PROVIDER) &&
                hasGPSDevice(this)
            ) {
                enableLoc()
            } else {
                val intent = Intent(this, SelectAddressActivity::class.java).apply {
                    if (!tempString.isNullOrEmpty()) {
                        putExtra(KeysUtils.keyCustomer, tempString)
                        putExtra(KeysUtils.keyOrderId, orderId)
                        putExtra(KeysUtils.KeyRemoteMessage, remoteMessage)
                    }
                }
                startActivityWithDefaultAnimations(intent)
                finish()
            }

//            var intent1 = Intent(Settings.ACTION_LOCATION_SOURCE_SETTINGS)
//            startActivityForResult(intent1, ConstantUtils.REQUEST_CODE_GPS)
        }.autoDispose(compositeDisposable)
    }

    private fun checkPermissionMethod() {

        if (checkPermissions()) {
            gpsAlreadyEnable()
        }
    }

    private fun initMethod() {
//        observeViewModel()
//        getTokenIfBlankRequest()
    }

    private fun getTokenRequest(): TokenRequest {
        return TokenRequest(Utils.accessKey)
    }

//    private fun getTokenIfBlankRequest() {
//        if (SharedPrefsUtils.getStringPreference(
//                applicationContext,
//                KeysUtils.keySecretKey
//            )?.isEmpty()!!
//        ) {
//            showProgress()
//            registerViewModel.getNewTokenRequestApi(getTokenRequest())
//
//        }
//    }


    private fun gpsAlreadyEnable() {
        val manager =
            this.getSystemService(Context.LOCATION_SERVICE) as LocationManager
        if (manager.isProviderEnabled(LocationManager.GPS_PROVIDER) &&
            hasGPSDevice(this)
        ) {
            val intent = Intent(this, SelectAddressActivity::class.java).apply {
                if (!tempString.isNullOrEmpty()) {
                    putExtra(KeysUtils.keyCustomer, tempString)
                    putExtra(KeysUtils.keyOrderId, orderId)
                    putExtra(KeysUtils.KeyRemoteMessage, remoteMessage)
                }
            }
            startActivityWithDefaultAnimations(intent)
            finish()
        } else {
            Toast.makeText(applicationContext, "Please turn on GPS", Toast.LENGTH_SHORT).show()
        }
    }

    private fun observeViewModel() {
        registerViewModel.tokenData.observe(this, Observer { newToken ->

            hideProgress()
            Utils.seceretKey = newToken
            SharedPrefsUtils.setStringPreference(
                applicationContext,
                KeysUtils.keySecretKey,
                Utils.seceretKey
            )

        })

        registerViewModel.errorMessage.observe(this, Observer { error ->
            hideProgress()
            Toast.makeText(this, error, Toast.LENGTH_SHORT).show()
        })
    }

    private fun checkPermissions(): Boolean {
        var result: Int
        val listPermissionsNeeded = ArrayList<String>()
        for (p in permissions) {
            result = ContextCompat.checkSelfPermission(applicationContext, p)
            if (result != PackageManager.PERMISSION_GRANTED) {
                listPermissionsNeeded.add(p)
            }
        }
        if (listPermissionsNeeded.isNotEmpty()) {
            ActivityCompat.requestPermissions(
                this,
                listPermissionsNeeded.toTypedArray(),
                ConstantUtils.MULTIPLE_PERMISSIONS
            )
            return false
        }
        return true
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<String>,
        grantResults: IntArray
    ) {
        when (requestCode) {
            ConstantUtils.MULTIPLE_PERMISSIONS -> {
                if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    gpsAlreadyEnable()
//                    Toast.makeText(applicationContext, "Permission is Granted ", Toast.LENGTH_SHORT)
//                        .show()
                    // permissions granted.
                } else {
                    // no permissions granted.
                }
                return
            }
        }
    }


    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == REQUEST_LOCATION && resultCode == Activity.RESULT_OK) {
            gpsAlreadyEnable()
        }

    }

    /*private fun checkGpsStatus() {

        val locationManager: LocationManager =
            applicationContext.getSystemService(Context.LOCATION_SERVICE) as LocationManager

        val gpsStatus = locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER)

        if (gpsStatus) {
            val intent = Intent(this, SelectAddressActivity::class.java).apply {
                if (!tempString.isNullOrEmpty()) {
                    putExtra(KeysUtils.keyCustomer, tempString)
                    putExtra(KeysUtils.keyOrderId, orderId)
                }
            }
            startActivityWithDefaultAnimations(intent)
            finish()
        } else {
            Toast.makeText(applicationContext, "Please turn on GPS", Toast.LENGTH_SHORT).show()

        }


    }*/

    private fun hasGPSDevice(context: Context): Boolean {
        val mgr = context
            .getSystemService(Context.LOCATION_SERVICE) as LocationManager
        val providers = mgr.allProviders ?: return false
        return providers.contains(LocationManager.GPS_PROVIDER)
    }

    private fun enableLoc() {
        if (googleApiClient == null) {
            googleApiClient = GoogleApiClient.Builder(this)
                .addApi(LocationServices.API)
                .addConnectionCallbacks(object : ConnectionCallbacks {
                    override fun onConnected(bundle: Bundle?) {}
                    override fun onConnectionSuspended(i: Int) {
                        googleApiClient?.connect()
                    }
                })
                .addOnConnectionFailedListener { connectionResult ->
                    Log.d(
                        "Location error",
                        "Location error " + connectionResult.errorCode
                    )
                }.build()
            googleApiClient?.connect()
            val locationRequest = LocationRequest.create()
            locationRequest.priority = LocationRequest.PRIORITY_HIGH_ACCURACY
            locationRequest.interval = 30 * 1000.toLong()
            locationRequest.fastestInterval = 5 * 1000.toLong()
            val builder = LocationSettingsRequest.Builder()
                .addLocationRequest(locationRequest)
            builder.setAlwaysShow(true)
            val result: PendingResult<LocationSettingsResult> =
                LocationServices.SettingsApi.checkLocationSettings(googleApiClient, builder.build())

            result.setResultCallback {
                val status: Status = it.status
                when (status.statusCode) {
                    LocationSettingsStatusCodes.RESOLUTION_REQUIRED -> try { // Show the dialog by calling startResolutionForResult(),
// and check the result in onActivityResult().
                        status.startResolutionForResult(
                            this,
                            REQUEST_LOCATION
                        )

                    } catch (e: SendIntentException) { // Ignore the error.
                    }
                }
            }


        }
    }

}

