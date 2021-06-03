package com.quedrop.driver.ui.settings.view


import android.app.Dialog
import android.content.Context
import android.content.Intent
import android.content.res.Configuration
import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.appcompat.app.AlertDialog
import androidx.core.content.ContextCompat
import androidx.fragment.app.Fragment
import androidx.lifecycle.Observer
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.quedrop.driver.R
import com.quedrop.driver.base.BaseFragment
import com.quedrop.driver.base.extentions.startActivityWithDefaultAnimations
import com.quedrop.driver.base.rxjava.autoDispose
import com.quedrop.driver.base.rxjava.throttleClicks
import com.quedrop.driver.service.model.BankDetails
import com.quedrop.driver.service.request.DeleteBankDetailRequest
import com.quedrop.driver.service.request.RateReviewDriverRequest
import com.quedrop.driver.ui.profile.viewmodel.ProfileViewModel
import com.quedrop.driver.ui.settings.adapter.ItemControlHelper
import com.quedrop.driver.ui.settings.adapter.MangePaymentAdapter
import com.quedrop.driver.utils.*
import kotlinx.android.synthetic.main.fragment_manage_payment.*
import kotlinx.android.synthetic.main.toolbar_normal.*

/**
 * A simple [Fragment] subclass.
 */
class ManagePaymentFragment : BaseFragment(), ItemControlHelper.ItemControlInterface {

    override fun getItemMovementFlags(position: Int): Int {
        val item = bankDataArrayList?.get(position)
        var flags = 0
        if (item?.isSwipeFromEnd()!!) flags = flags or ItemControlHelper.SWIPE_FROM_END
        return flags
    }

    override fun getSwipeAndControlViews(
        swipeAndControlViews: Array<View?>,
        viewHolder: RecyclerView.ViewHolder,
        fromStart: Boolean
    ): Boolean {
        val item = bankDataArrayList?.get(viewHolder.adapterPosition)
        swipeAndControlViews[0] = viewHolder.itemView.findViewById(R.id.card_item)
        swipeAndControlViews[1] = viewHolder.itemView.findViewById(R.id.end_control)
        return item?.isPull()!!
    }

    override fun onItemDragged(position: Int, toPosition: Int): Boolean {
        val saved = bankDataArrayList?.get(toPosition)
        bankDataArrayList?.set(toPosition, bankDataArrayList!![position])
        bankDataArrayList?.set(position, saved!!)
        mangePaymentAdapter?.notifyItemMoved(position, toPosition)
        return true
    }

    private lateinit var mContext: Context

    private var bankDataArrayList: MutableList<BankDetails>? = null
    private var mangePaymentAdapter: MangePaymentAdapter? = null

    private lateinit var profileViewModel: ProfileViewModel

    private var itemControlHelper: ItemControlHelper? = null

    private var positionBank: Int? = null


    companion object {
        fun newInstance(): ManagePaymentFragment {
            return ManagePaymentFragment()
        }
    }

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {

        val view = inflater.inflate(R.layout.fragment_manage_payment, container, false)

        mContext = activity

        return view
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        profileViewModel = ProfileViewModel(appService)

        initViews()
    }

    private fun initViews() {
        setUpToolBar()
        if (Utility.isNetworkAvailable(context)) {
            constAddAccount.isEnabled = true
            getBankDetails()
        } else {
            hideProgress()
            constAddAccount.isEnabled = false
            showAlertMessage(activity, getString(R.string.no_internet_connection))
        }


        rvBankDetails.layoutManager = LinearLayoutManager(
            context,
            LinearLayoutManager.VERTICAL,
            false
        )

        bankDataArrayList = mutableListOf()

        mangePaymentAdapter =
            MangePaymentAdapter(
                this.context!!,
                bankDataArrayList!!

            )
        rvBankDetails.adapter = mangePaymentAdapter

        itemControlHelper = ItemControlHelper(
            rvBankDetails!!,
            this,
            resources.configuration.orientation == Configuration.ORIENTATION_PORTRAIT
        )

        observeViewModel()
        onClickView()

    }

    private fun onClickView() {
        constAddAccount.throttleClicks().subscribe {

            startActivityWithDefaultAnimations(
                Intent(
                    mContext,
                    AddEditPaymentActivity::class.java
                )
            )
        }.autoDispose(compositeDisposable)

        mangePaymentAdapter?.apply {
            onItemClick = { view, adapterPosition, name ->
                startActivityWithDefaultAnimations(
                    Intent(
                        mContext,
                        AddEditPaymentActivity::class.java
                    ).putExtra("isEditMode", true)
                        .putExtra("payment", bankDataArrayList?.get(adapterPosition))
                )
            }
            onClickDeleteBtn = { view, adapterPosition, s ->
                itemControlHelper?.finishSwiping()
                onCtrlDeleteClick(adapterPosition)

            }
        }
    }

    private fun onCtrlDeleteClick(position: Int) {
        alertDialog(position)
    }

    private fun alertDialog(position: Int) {

        val dialog = Dialog(activity)
        dialog.setContentView(R.layout.layout_deletedialog)

        val textOk = dialog.findViewById<TextView>(R.id.dialog_ok)
        val textCancel = dialog.findViewById<TextView>(R.id.dialog_cancel)
        val textTitleDelete = dialog.findViewById<TextView>(R.id.textTitleDelete)

        textTitleDelete.text = getString(R.string.msg_sure_to_delete)

        textOk.setOnClickListener {

            textOk.setTextColor(ContextCompat.getColor(activity, R.color.colorBlueText))
            textCancel.setTextColor(ContextCompat.getColor(activity, R.color.colorGray100))
            deleteBankAccount(position)
        }

        textCancel.setOnClickListener {
            textOk.setTextColor(ContextCompat.getColor(activity, R.color.colorGray100))
            textCancel.setTextColor(ContextCompat.getColor(activity, R.color.colorBlueText))
            dialog.dismiss()
        }
        dialog.show()
    }


    private fun setUpToolBar() {
        tvTitle.text = resources.getString(R.string.setup_payment_method)
        ivBack.throttleClicks().subscribe {

            goBackToPreviousFragment()

        }.autoDispose(compositeDisposable)


    }

    private fun goBackToPreviousFragment() {
        val fm = getActivity()!!.supportFragmentManager
        if (fm.backStackEntryCount > 0) {
            fm.popBackStack()
        }
    }

    fun observeViewModel() {
        profileViewModel.bankDetails.observe(viewLifecycleOwner, Observer {
            hideProgress()
            bankDataArrayList?.clear()
            bankDataArrayList?.addAll(it.toMutableList())
            mangePaymentAdapter?.notifyDataSetChanged()

        })

        profileViewModel.errorMessage.observe(viewLifecycleOwner, Observer { error ->
            hideProgress()

        })

        profileViewModel.message.observe(viewLifecycleOwner, Observer {
            hideProgress()
            bankDataArrayList?.removeAt(positionBank!!)
            mangePaymentAdapter?.notifyItemRemoved(positionBank!!)
            //Toast.makeText(context, it, Toast.LENGTH_LONG).show()
        })

    }

    private fun getBankDetailsRequest(): RateReviewDriverRequest {
        return RateReviewDriverRequest(
            SharedPreferenceUtils.getString(KEY_TOKEN),
            ACCESS_KEY,
            SharedPreferenceUtils.getInt(KEY_USERID)
        )
    }

    private fun getBankDetails() {
        showProgress()
        profileViewModel.getBankDetails(getBankDetailsRequest())

    }

    private fun deleteBankAccountRequest(postion: Int): DeleteBankDetailRequest {
        return DeleteBankDetailRequest(
            SharedPreferenceUtils.getString(KEY_TOKEN),
            ACCESS_KEY,
            bankDataArrayList?.get(postion)?.bankDetailId!!,
            SharedPreferenceUtils.getInt(KEY_USERID)
        )
    }

    private fun deleteBankAccount(postion: Int) {
        showProgress()
        profileViewModel.deleteBankDetail(deleteBankAccountRequest(postion))
    }

    override fun onResume() {
        super.onResume()
        if (Utility.isNetworkAvailable(context)) {
            getBankDetails()
        } else {
            hideProgress()
        }
    }
}
