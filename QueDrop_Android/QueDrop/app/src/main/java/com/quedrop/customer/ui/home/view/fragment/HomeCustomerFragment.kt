package com.quedrop.customer.ui.home.view.fragment

import android.content.Intent
import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.lifecycle.Observer
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout
import com.quedrop.customer.R
import com.quedrop.customer.base.BaseFragment
import com.quedrop.customer.base.extentions.startActivityForResultWithDefaultAnimations
import com.quedrop.customer.base.extentions.startActivityWithDefaultAnimations
import com.quedrop.customer.base.rxjava.autoDispose
import com.quedrop.customer.base.rxjava.throttleClicks
import com.quedrop.customer.db.AppDatabase
import com.quedrop.customer.model.*
import com.quedrop.customer.socket.SocketConstants
import com.quedrop.customer.ui.addaddress.view.AddAddressActivity
import com.quedrop.customer.ui.cart.view.CartActivity
import com.quedrop.customer.ui.home.view.CustomerMainActivity
import com.quedrop.customer.ui.home.view.adapter.MainRecyclerCustomerAdapter
import com.quedrop.customer.ui.home.viewmodel.HomeCustomerViewModel
import com.quedrop.customer.ui.nearby.view.NearByRestaurantActivity
import com.quedrop.customer.ui.notification.view.NotificationCustomFragment
import com.quedrop.customer.ui.profile.view.SettingsFragment
import com.quedrop.customer.ui.selectaddress.view.SelectAddressActivity
import com.quedrop.customer.ui.storeadd.view.AddStoreActivity
import com.quedrop.customer.utils.ConstantUtils
import com.quedrop.customer.utils.KeysUtils
import com.quedrop.customer.utils.SharedPrefsUtils
import com.quedrop.customer.utils.Utils
import io.socket.client.Ack
import kotlinx.android.synthetic.main.fragment_home_customer.*
import org.json.JSONException
import org.json.JSONObject
import timber.log.Timber


class HomeCustomerFragment : BaseFragment(), SwipeRefreshLayout.OnRefreshListener {

    var mainRecyclerAdapter: MainRecyclerCustomerAdapter? = null

    private lateinit var homeCustomerViewModel: HomeCustomerViewModel

    var arrayCategoriesList: MutableList<Categories>? = mutableListOf()
    var arrayRestaurantOfferList: MutableList<StoreOfferList>? = mutableListOf()
    var arrayProductOfferList: MutableList<ProfuctOfferList>? = mutableListOf()
    var arrayPaymentOfferList: MutableList<OrderOffer>? = mutableListOf()
    var arrayFreshProduceList: MutableList<FreshProduceCategories>? = mutableListOf()
    var cartTermsNotesList: MutableList<NotesResponse>? = mutableListOf()

    var isCallOnceNote: Boolean = false
    var isFromFreshProduce: Boolean = false


    companion object {
        fun newInstance(): HomeCustomerFragment {
            return HomeCustomerFragment()
        }
    }

    fun onPageSelected(position: Int) {
        sendSocketCheckCartItemEvent()
    }

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        return inflater.inflate(R.layout.fragment_home_customer, container, false)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        Utils.userId = SharedPrefsUtils.getIntegerPreference(activity, KeysUtils.keyUserId, 0)
        Utils.guestId = SharedPrefsUtils.getIntegerPreference(activity, KeysUtils.keyGuestId, 0)
        Utils.seceretKey = SharedPrefsUtils.getStringPreference(activity, KeysUtils.keySecretKey)!!
        Utils.accessKey = SharedPrefsUtils.getStringPreference(activity, KeysUtils.keyAccessKey)!!

        homeCustomerViewModel = HomeCustomerViewModel(appService)

        if (Utils.userId == 0) {
            ivNotification.visibility = View.GONE
        } else {
            ivNotification.visibility = View.VISIBLE
        }

        //unreadCardCountTV.visibility = View.GONE
        sendSocketCheckCartItemEvent()

        val arrayMainScreenOfferList =
            activity.resources?.getStringArray(R.array.mainScreenApiItem)?.toMutableList()
        val textAddressName = SharedPrefsUtils.getStringPreference(
            this.requireContext(),
            KeysUtils.KeySelectAddressName
        )
        textLocationAddress.text = textAddressName
        mainRecycler!!.setHasFixedSize(true)

        mainRecycler.layoutManager = LinearLayoutManager(
            activity.applicationContext!!,
            LinearLayoutManager.VERTICAL,
            false
        )
        mainRecyclerAdapter = MainRecyclerCustomerAdapter(
            activity.applicationContext,
            arrayMainScreenOfferList

        ).apply {
            getAllOfferListInvoke = {
                getAllOffersApi()
            }
            allCategoriesInvoke = {
                getAllCategoriesApi()
            }
            addStoreActivityInvoke = {
                addStoreActivity()
            }
            nearByStoreActivityInvoke = { it: Int, fromFreshProduce: Boolean ->
                isFromFreshProduce = fromFreshProduce
                nearByStoreActivity(it, fromFreshProduce)
            }
        }

        cartTermsNotesList = mutableListOf()

        mainRecycler!!.adapter = mainRecyclerAdapter
        swipeLayout.setOnRefreshListener(this)
        onClickMethod()
        observeViewModel()

        isCallOnceNote = SharedPrefsUtils.getBooleanPreference(
            this.requireContext(),
            KeysUtils.keyNotesCart,
            false
        )
        if (isCallOnceNote) {

        } else {
            isCallOnceNote = true
            getNoteApi()
            SharedPrefsUtils.setBooleanPreference(
                this.requireContext(),
                KeysUtils.keyNotesCart,
                isCallOnceNote
            )
        }
    }


    private fun getNoteApi() {
        val notesRequest = GetNotes(Utils.seceretKey, Utils.accessKey)
        (activity as CustomerMainActivity).showProgress()
        homeCustomerViewModel.getNotesApi(notesRequest)
    }

    override fun onRefresh() {

        loadRecyclerViewData()
    }

    private fun loadRecyclerViewData() {
        swipeLayout.isRefreshing = true
        getAllOffersApi()
        getAllCategoriesApi()
        mainRecyclerAdapter?.notifyDataSetChanged()
        swipeLayout.isRefreshing = false
    }

    private fun onClickMethod() {

        ivNotification.throttleClicks().subscribe {
            (getActivity() as CustomerMainActivity).navigateToFragment(
                NotificationCustomFragment.newInstance()
            )
        }.autoDispose(compositeDisposable)


        textLocationAddress.throttleClicks().subscribe {
            Utils.isCallOnceMap = false

            SharedPrefsUtils.setBooleanPreference(
                this.requireContext(),
                KeysUtils.keyMap,
                Utils.isCallOnceMap
            )
            val intent = Intent(activity, SelectAddressActivity::class.java)
            intent.putExtra(KeysUtils.keyHomeAddress, getString(R.string.fromHomeAddress))
            startActivityWithDefaultAnimations(intent)

        }.autoDispose(compositeDisposable)


        ivShoppingCart.throttleClicks().subscribe {
            val intent = Intent(this.context, CartActivity::class.java)
            intent.putExtra(KeysUtils.keyUserProductId, "")
            startActivityWithDefaultAnimations(intent)
        }.autoDispose(compositeDisposable)
    }


    private fun observeViewModel() {

        homeCustomerViewModel.errorMessage.observe(viewLifecycleOwner,
            Observer {
                (context as CustomerMainActivity).hideProgress()
            })

        homeCustomerViewModel.categoriesList.observe(viewLifecycleOwner,
            Observer {
                (context as CustomerMainActivity).hideProgress()
                arrayCategoriesList?.clear()
                arrayCategoriesList?.addAll(it.toMutableList())

                //zp changes
                //val category = Categories(0, "", "", "")
                // arrayCategoriesList?.add(arrayCategoriesList!!.size, category)
                mainRecyclerAdapter?.allCategoriesNotified(arrayCategoriesList!!)
            })

        homeCustomerViewModel.restaurantOfferList.observe(viewLifecycleOwner,
            Observer {
                (context as CustomerMainActivity).hideProgress()
                arrayRestaurantOfferList?.clear()
                arrayRestaurantOfferList?.addAll(it.toMutableList())
                mainRecyclerAdapter?.restaurantOffersNotified(arrayRestaurantOfferList!!)
            })

        homeCustomerViewModel.productOfferList.observe(viewLifecycleOwner,
            Observer {
                (context as CustomerMainActivity).hideProgress()
                arrayProductOfferList?.clear()
                arrayProductOfferList?.addAll(it.toMutableList())
                mainRecyclerAdapter?.productOffersNotified(arrayProductOfferList!!)
            })

        homeCustomerViewModel.paymentOrderOfferList.observe(viewLifecycleOwner,
            Observer {
                (context as CustomerMainActivity).hideProgress()
                arrayPaymentOfferList?.clear()
                arrayPaymentOfferList?.addAll(it.toMutableList())
                mainRecyclerAdapter?.paymentOfferNotified(arrayPaymentOfferList!!)
            })

        homeCustomerViewModel.freshProduceCategories.observe(viewLifecycleOwner,
            Observer {
                (context as CustomerMainActivity).hideProgress()
                arrayFreshProduceList?.clear()
                arrayFreshProduceList?.addAll(it.toMutableList())
                mainRecyclerAdapter?.freshProduceNotified(arrayFreshProduceList!!)
            })

        homeCustomerViewModel.cartTermsNoteList.observe(viewLifecycleOwner,
            Observer {
                (context as CustomerMainActivity).hideProgress()
                //cartTermsNotesList?.clear()
                cartTermsNotesList?.addAll(it.toMutableList())

                val db = AppDatabase.getAppDatabase(this.context)
                db.notesDao().insertNotes(cartTermsNotesList!!)

            })
    }

    private fun getAllCategoriesApi() {
        (context as CustomerMainActivity).showProgress()
        val allCategories = AllCategories(Utils.seceretKey, Utils.accessKey)
        homeCustomerViewModel.getAllCategoriesApi(allCategories)

    }

    private fun getAllOffersApi() {
        (context as CustomerMainActivity).showProgress()
        val offerList = OfferList(Utils.seceretKey, Utils.accessKey)
        homeCustomerViewModel.getOffersApi(offerList)

    }

    private fun addStoreActivity() {
        val intent = Intent(context, AddStoreActivity::class.java)
        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
        startActivityWithDefaultAnimations(intent)
    }


    private fun nearByStoreActivity(layoutPosition: Int, fromFreshProduce: Boolean) {
        val intent = Intent(context, NearByRestaurantActivity::class.java)
        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK

        if (fromFreshProduce) {
            intent.putExtra(
                KeysUtils.KeyServiceCategoryName,
                arrayFreshProduceList?.get(layoutPosition)?.fresh_produce_title
            )
            intent.putExtra(KeysUtils.KeyServiceCategoryId, 0)
            intent.putExtra(
                KeysUtils.KeyFreshProduceCategoryId,
                arrayFreshProduceList?.get(layoutPosition)?.fresh_category_id
            )
        } else {
            intent.putExtra(
                KeysUtils.KeyServiceCategoryName,
                arrayCategoriesList?.get(layoutPosition)?.service_category_name
            )
            intent.putExtra(
                KeysUtils.KeyServiceCategoryId,
                arrayCategoriesList?.get(layoutPosition)?.service_category_id
            )
            intent.putExtra(KeysUtils.KeyFreshProduceCategoryId, 0)
        }

        startActivityWithDefaultAnimations(intent)
    }

    private fun sendSocketCheckCartItemEvent() {
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
                                // performing some dummy time taking operation
                                changingVisibility(totalItems)
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

    private fun changingVisibility(totalItems: Int) {
        try {
            if (totalItems != 0) {
                unreadCardCountTV.text = totalItems.toString()
                unreadCardCountTV.visibility = View.VISIBLE
            } else {
                unreadCardCountTV.visibility = View.GONE
            }
        } catch (e: Exception) {
            println(e.toString())
        }
    }

    override fun onResume() {
        super.onResume()
        sendSocketCheckCartItemEvent()
    }
}