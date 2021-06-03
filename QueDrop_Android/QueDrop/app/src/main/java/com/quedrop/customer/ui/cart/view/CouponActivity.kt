package com.quedrop.customer.ui.cart.view

import android.app.Activity
import android.app.AlertDialog
import android.content.DialogInterface
import android.content.Intent
import android.os.Bundle
import android.widget.Toast
import androidx.lifecycle.Observer
import androidx.recyclerview.widget.LinearLayoutManager
import com.quedrop.customer.R
import com.quedrop.customer.base.BaseActivity
import com.quedrop.customer.base.rxjava.autoDispose
import com.quedrop.customer.base.rxjava.throttleClicks
import com.quedrop.customer.model.*
import com.quedrop.customer.ui.cart.view.adapter.AddCouponAdapter
import com.quedrop.customer.ui.cart.viewmodel.CartViewModel
import com.quedrop.customer.utils.KeysUtils
import com.quedrop.customer.utils.SharedPrefsUtils
import com.quedrop.customer.utils.Utils
import kotlinx.android.synthetic.main.activity_coupon.*

class CouponActivity : BaseActivity() {

    lateinit var cartViewModel: CartViewModel
    var addCouponAdapter: AddCouponAdapter? = null
    var arrayAddCouponList: MutableList<GetCouponCodeResponse>? = null
    var arrayApplyCouponList: MutableList<UserCart>? = null

    var intentTotalPrice: String = ""
    private var intentCouponCode: String = ""
    var buyPrice:String=""
    var saveAmount:String = ""
    lateinit var amoutdetails: AmountDetails
    var finalCouponCode:String=""

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_coupon)

        Utils.userId =
            SharedPrefsUtils.getIntegerPreference(applicationContext, KeysUtils.keyUserId,0)
        Utils.guestId =
            SharedPrefsUtils.getIntegerPreference(applicationContext, KeysUtils.keyGuestId,0)
        Utils.seceretKey =
            SharedPrefsUtils.getStringPreference(applicationContext, KeysUtils.keySecretKey)!!
        Utils.accessKey =
            SharedPrefsUtils.getStringPreference(applicationContext, KeysUtils.keyAccessKey)!!
        Utils.keyLatitude =
            SharedPrefsUtils.getStringPreference(applicationContext, KeysUtils.KeyLatitude)!!
        Utils.keyLongitude =
            SharedPrefsUtils.getStringPreference(applicationContext, KeysUtils.KeyLongitude)!!

        cartViewModel = CartViewModel(appService)

        initMethod()
        observeViewModel()
        onClickMethod()
        getCouponCodeApi()
    }

    private fun initMethod() {

        intentTotalPrice = intent.getStringExtra(KeysUtils.keyTotalItemPriceCart)!!
        intentCouponCode = intent.getStringExtra(KeysUtils.keyCouponCode)!!
        rvAddCoupon.layoutManager = LinearLayoutManager(
            applicationContext!!,
            LinearLayoutManager.VERTICAL,
            false
        )

        arrayApplyCouponList = mutableListOf()
        arrayAddCouponList = mutableListOf()
        addCouponAdapter = AddCouponAdapter(
            applicationContext,
            intentCouponCode,
            arrayAddCouponList
        ).apply {

            arrayAddCouponInvoke = { adapterPosition:Int ->
                addCouponInvoke(adapterPosition)
            }
        }
        rvAddCoupon.adapter = addCouponAdapter


    }

    private fun addCouponInvoke(pos: Int) {

            editCouponCode.setText(arrayAddCouponList?.get(pos)?.coupon_code)

            buyPrice = intentTotalPrice
            val discount = arrayAddCouponList?.get(pos)?.discount_percentage
            val idealPrize: Float = 100f
            val s: Float = (idealPrize - (discount?.toFloat()!!))
            val amount: Float = (s * buyPrice.toFloat()) / 100f
            saveAmount = (buyPrice.toFloat() - amount).toString()

            tvMaxSavingCoupon.text = resources.getString(R.string.maxSav) +
                    saveAmount

        finalCouponCode=arrayAddCouponList?.get(pos)?.coupon_code!!

    }

    private fun onClickMethod() {

        ivBackCoupon.throttleClicks().subscribe() {
            this.onBackPressed()
        }.autoDispose(compositeDisposable)

        tvApplyCoupon.throttleClicks().subscribe() {
            if(editCouponCode.text.toString() == "") {
            } else {
                for((i,v) in arrayAddCouponList?.withIndex()!!){
                    if(editCouponCode.text.toString() == v.coupon_code){
                        getApplyCouponApi()
                        break
                    }else{
                        if(i==(arrayAddCouponList?.size!!-1)){
                            showAlertBoxAddProduct()
                        }else{

                        }

                    }
                }
            }
        }.autoDispose(compositeDisposable)

        tvApplyEditCoupon.throttleClicks().subscribe() {
            if (editCouponCode.text.toString() == "") {
            } else {
                for((i,v) in arrayAddCouponList?.withIndex()!!){
                    if(editCouponCode.text.toString() == v.coupon_code){
                        getApplyCouponApi()
                        break
                    }else{
                        if(i==(arrayAddCouponList?.size!!-1)){
                            showAlertBoxAddProduct()
                        }else{

                        }
                    }
                }

            }
        }.autoDispose(compositeDisposable)

    }

    private fun showAlertBoxAddProduct() {
        val alertDialogBuilder = AlertDialog.Builder(this)
        alertDialogBuilder.setCancelable(false)
        alertDialogBuilder.setMessage(resources.getString(R.string.textCouponCode))

        alertDialogBuilder.setPositiveButton(
            resources.getString(R.string.okCoupon),
            DialogInterface.OnClickListener { dialog, which ->
              dialog.dismiss()
            })

        alertDialogBuilder.show()

    }


    private fun observeViewModel() {
        cartViewModel.arrayCouponCodeList.observe(this, androidx.lifecycle.Observer {

            hideProgress()
            arrayAddCouponList?.clear()
            arrayAddCouponList?.addAll(it.toMutableList())

            if(intentCouponCode.isEmpty()){

            }else{
                for((i,v) in arrayAddCouponList?.withIndex()!!){
                    if(v.coupon_code == intentCouponCode){
                        addCouponInvoke(i)
                    }
                }
            }

            addCouponAdapter?.notifyDataSetChanged()
        })

        cartViewModel.errorMessage.observe(this, androidx.lifecycle.Observer {
            hideProgress()
        })

        cartViewModel.errorVal.observe(this, androidx.lifecycle.Observer {
            saveAmount = "0"
            hideProgress()
            Toast.makeText(applicationContext, it ,Toast.LENGTH_SHORT).show()
//            finish()
        })

        cartViewModel.arrayApplyCouponCodeList.observe(this, androidx.lifecycle.Observer {

            hideProgress()

            arrayApplyCouponList?.clear()
            arrayApplyCouponList?.addAll(it.toMutableList())
            SharedPrefsUtils.setModelPreferences(applicationContext, KeysUtils.keySetAmount, amoutdetails)
            SharedPrefsUtils.setListPreference(
                applicationContext,
                KeysUtils.keyCouponCodeCartArray,
                arrayApplyCouponList?.toMutableList()!!
            )

            val intent = Intent()
            intent.putExtra(KeysUtils.keySaveMaxRs,saveAmount)
            intent.putExtra(KeysUtils.keyCouponCode,finalCouponCode)
            setResult(Activity.RESULT_OK, intent)
            finish()

        })

        cartViewModel.amountDetailsCoupons.observe(this, Observer {

            amoutdetails=it
        })
    }

    private fun getCouponCodeApi() {
        val getCouponCode = GetCouponRequest(
            Utils.seceretKey,
            Utils.accessKey,
            Utils.userId
        )
        showProgress()
        cartViewModel.getCouponCodeApi(getCouponCode)
    }

    private fun getApplyCouponCode(): ApplyCouponCodeRequest {
        return ApplyCouponCodeRequest(
            Utils.seceretKey,
            Utils.accessKey,
            Utils.userId,
            Utils.keyLatitude,
            Utils.keyLongitude,
            editCouponCode.text.toString(),
            buyPrice,
            Utils.guestId

        )
    }

    private fun getApplyCouponApi() {
        showProgress()
        cartViewModel.applyCouponCodeApi(getApplyCouponCode())
    }
}
