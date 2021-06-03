package com.quedrop.customer.ui.explore.view

import android.content.Intent
import android.os.Bundle
import android.text.Editable
import android.text.TextWatcher
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.lifecycle.Observer
import com.quedrop.customer.R
import com.quedrop.customer.base.BaseFragment
import com.quedrop.customer.base.extentions.startActivityWithDefaultAnimations
import com.quedrop.customer.base.rxjava.autoDispose
import com.quedrop.customer.base.rxjava.throttleClicks
import com.quedrop.customer.model.ExploreSearchRequest
import com.quedrop.customer.model.StoreSingleDetails
import com.quedrop.customer.model.SupplierProduct
import com.quedrop.customer.socket.SocketConstants
import com.quedrop.customer.ui.cart.view.CartActivity
import com.quedrop.customer.ui.explore.viewmodel.ExploreViewModel
import com.quedrop.customer.ui.foodcategory.view.FoodCategoryActivity
import com.quedrop.customer.ui.home.view.CustomerMainActivity
import com.quedrop.customer.ui.storewithproduct.view.StoreDetailsActivity
import com.quedrop.customer.utils.KeysUtils
import com.quedrop.customer.utils.SharedPrefsUtils
import com.quedrop.customer.utils.Utils
import io.socket.client.Ack
import kotlinx.android.synthetic.main.fragment_explore.*
import kotlinx.android.synthetic.main.fragment_home_customer.*
import org.json.JSONException
import org.json.JSONObject
import timber.log.Timber

class ExploreFragment : BaseFragment() {

    var exploreViewModel: ExploreViewModel? = null

    var exploreMainAdapter: ExploreMainAdapter? = null

    companion object {
        fun newInstance(): ExploreFragment {
            return ExploreFragment()
        }
    }

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        return inflater.inflate(R.layout.fragment_explore, container, false)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        exploreViewModel = ExploreViewModel(apiService = appService)

        Utils.userId = SharedPrefsUtils.getIntegerPreference(activity, KeysUtils.keyUserId, 0)
        Utils.guestId = SharedPrefsUtils.getIntegerPreference(activity, KeysUtils.keyGuestId, 0)
        Utils.seceretKey = SharedPrefsUtils.getStringPreference(activity, KeysUtils.keySecretKey)!!
        Utils.accessKey = SharedPrefsUtils.getStringPreference(activity, KeysUtils.keyAccessKey)!!

        initViews()

    }

    private fun initViews() {
        searchMethod()
        setUpAdapter()
        onClickViews()
        observableViewModel()
    }

    private fun onClickViews() {
        ivCart.throttleClicks().subscribe {
           startCartActivity()
        }.autoDispose(compositeDisposable)
    }

    private fun setUpAdapter() {
        val arrayExploreList = activity.resources?.getStringArray(R.array.exploreScreenApiItem)?.toMutableList()
        exploreMainAdapter = ExploreMainAdapter(activity, arrayExploreList)
        exploreMainAdapter?.apply {
            storeExploreMainInvoke = { pos, stores ->
                startActivityWithProduct(stores[pos])
            }

            productExploreMainInvoke = { pos, products ->
                startFoodCategoryActivity(products[pos])
            }
        }

        rvExplore.adapter = exploreMainAdapter
    }

    private fun startActivityWithProduct(store: StoreSingleDetails) {
        val intentStore = Intent(context, StoreDetailsActivity::class.java)
        intentStore.putExtra(KeysUtils.keyStoreId, store.store_id)
        intentStore.putExtra(KeysUtils.KeyFreshProduceCategoryId, store.fresh_produce_category_id)
        (context as CustomerMainActivity).startActivityWithDefaultAnimations(intentStore)
    }

    private fun startFoodCategoryActivity(product: SupplierProduct) {
        val intent = Intent(context, FoodCategoryActivity::class.java)
        intent.putExtra(KeysUtils.keyStoreId, product.store_id)
        intent.putExtra(KeysUtils.keyStoreCategoryId, product.store_category_id)
        intent.putExtra(KeysUtils.keySearch, false)
        intent.putExtra(KeysUtils.keyArrayFoodPosition, 0)
        intent.putExtra(KeysUtils.keyPositionFoodCatrgories, product.product_name)
        intent.putExtra(KeysUtils.KeyFreshProduceCategoryId, product.fresh_produce_category_id)

        if (product.fresh_produce_category_id == 0) {
            intent.putExtra(KeysUtils.KeyIsFromFreshProduceCat, false)
        } else {
            intent.putExtra(KeysUtils.KeyIsFromFreshProduceCat, true)
        }
        (context as CustomerMainActivity).startActivityWithDefaultAnimations(intent)
    }

    private fun startCartActivity(){
        val intent = Intent(this.context, CartActivity::class.java)
        startActivityWithDefaultAnimations(intent)
    }

    private fun observableViewModel() {

        exploreViewModel?.isLoading?.observe(viewLifecycleOwner, Observer {
            if (it) {
                (activity as CustomerMainActivity).hideProgress()
            } else {
                (activity as CustomerMainActivity).hideProgress()
            }
        })


        exploreViewModel?.errorMessage?.observe(viewLifecycleOwner, Observer {
            (activity as CustomerMainActivity).hideProgress()
            exploreMainAdapter?.exploreStoreNotified(mutableListOf())
            exploreMainAdapter?.exploreProductNotified(mutableListOf())

            if(it == "Please provide search text.") {
                textEmptyExplore.visibility = View.GONE
                ivExplorePlaceHolder.visibility = View.VISIBLE
            }else {
                ivExplorePlaceHolder.visibility = View.GONE
                textEmptyExplore.visibility = View.VISIBLE
                textEmptyExplore.text = it
            }
        })


        exploreViewModel?.arrayExploreStoreList?.observe(viewLifecycleOwner, Observer {
            (activity as CustomerMainActivity).hideProgress()
            textEmptyExplore.visibility = View.GONE
            ivExplorePlaceHolder.visibility = View.GONE
            exploreMainAdapter?.exploreStoreNotified(it.toMutableList())
        })


        exploreViewModel?.arrayExploreProductList?.observe(viewLifecycleOwner, Observer {
            (activity as CustomerMainActivity).hideProgress()
            textEmptyExplore.visibility = View.GONE
            ivExplorePlaceHolder.visibility = View.GONE
            exploreMainAdapter?.exploreProductNotified(it.toMutableList())
        })

    }


    private fun searchMethod() {

        etExploreSearch.addTextChangedListener(object : TextWatcher {
            override fun afterTextChanged(s: Editable?) {
                callApiExploreSearch(s.toString().trim())
            }

            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {

            }

            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {

            }
        })

        ivClearExploreSearchText.throttleClicks().subscribe {
            etExploreSearch.text.clear()
        }.autoDispose(compositeDisposable)

    }


    private fun callApiExploreSearch(searchText: String) {
        exploreViewModel?.exploreSearchApi(
            ExploreSearchRequest(
                Utils.seceretKey,
                Utils.accessKey,
                searchText
            )
        )
    }

    private fun socketGetCartCount() {
        if (SocketConstants.socketIOClient != null && SocketConstants.socketIOClient!!.connected()) {
            val jsonObject = JSONObject()
            try {
                jsonObject.put(SocketConstants.KeyUserId, Utils.userId)
                jsonObject.put(SocketConstants.keyGuestId, Utils.guestId)

                SocketConstants.socketIOClient!!.emit(
                    SocketConstants.SocketGetCartCount,
                    jsonObject, Ack {
                        try {
                            val messageJson = JSONObject(it[0].toString())
                            val responseStatus = messageJson.getString("status").toInt()
                            val totalItems = messageJson.getString("total_items").toInt()

                            Thread(Runnable {
                                count(totalItems)
                            }).start()

                        } catch (e: JSONException) {
                            e.printStackTrace()
                        }

                    })
            } catch (e: JSONException) {
                e.printStackTrace()
            }

        } else {
            Timber.e("Socket not connected")
        }

    }

    private fun count(totalItems: Int) {
        try {
            if (totalItems != 0) {
                tvUnreadCount.text = totalItems.toString()
                tvUnreadCount.visibility = View.VISIBLE
            } else {
                tvUnreadCount.visibility = View.GONE
            }
        } catch (e: Exception) {
            println(e.toString())
        }
    }
    override fun onResume() {
        super.onResume()
        socketGetCartCount()
    }
}