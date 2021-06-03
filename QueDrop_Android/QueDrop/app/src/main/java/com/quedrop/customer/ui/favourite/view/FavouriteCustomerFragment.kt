package com.quedrop.customer.ui.favourite.view

import android.content.Intent
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.lifecycle.Observer
import com.omadahealth.github.swipyrefreshlayout.library.SwipyRefreshLayout
import com.omadahealth.github.swipyrefreshlayout.library.SwipyRefreshLayoutDirection
import com.quedrop.customer.R
import com.quedrop.customer.base.BaseFragment
import com.quedrop.customer.base.extentions.startActivityWithDefaultAnimations
import com.quedrop.customer.base.rxjava.autoDispose
import com.quedrop.customer.base.rxjava.throttleClicks
import com.quedrop.customer.model.FavoriteStoresRequest
import com.quedrop.customer.model.NearByStores
import com.quedrop.customer.model.SetFavourite
import com.quedrop.customer.ui.explore.viewmodel.ExploreViewModel
import com.quedrop.customer.ui.favourite.viewmodel.FavoriteViewModel
import com.quedrop.customer.ui.storewithoutproduct.view.StoreWithoutProductActivity
import com.quedrop.customer.ui.storewithproduct.view.StoreDetailsActivity
import com.quedrop.customer.ui.storewithproduct.viewmodel.StoreWithProductViewModel
import com.quedrop.customer.utils.KeysUtils
import com.quedrop.customer.utils.RxBus
import com.quedrop.customer.utils.SharedPrefsUtils
import com.quedrop.customer.utils.Utils
import kotlinx.android.synthetic.main.fragment_favorite_customer.*
import kotlinx.android.synthetic.main.fragmnet_toolbar.*

class FavouriteCustomerFragment : BaseFragment(), SwipyRefreshLayout.OnRefreshListener {

    lateinit var favouriteViewModel: FavoriteViewModel
    lateinit var storeWithProductViewModel: StoreWithProductViewModel
    var favouriteAdapter: FavoriteCustomerAdapter? = null
    var arrayFavouriteList: MutableList<NearByStores>? = null
    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {

        return inflater.inflate(
            R.layout.fragment_favorite_customer,
            container, false
        )
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        favouriteViewModel = FavoriteViewModel(appService)
        storeWithProductViewModel = StoreWithProductViewModel(appService)

        swipeRefresh.setOnRefreshListener(this)

        Utils.userId =
            SharedPrefsUtils.getIntegerPreference(activity, KeysUtils.keyUserId, 0)
        Utils.guestId =
            SharedPrefsUtils.getIntegerPreference(activity, KeysUtils.keyGuestId, 0)
        Utils.seceretKey =
            SharedPrefsUtils.getStringPreference(activity, KeysUtils.keySecretKey)!!
        Utils.accessKey =
            SharedPrefsUtils.getStringPreference(activity, KeysUtils.keyAccessKey)!!
        initMethod()
        setUpToolbar()
        observableViewModel()
        getFavouriteStoreApi()

        RxBus.instance?.listen()?.subscribe {
            if (it == "refreshFavourite") {
                getFavouriteStoreApi()
            }
        }?.autoDispose(compositeDisposable)
    }

    private fun setUpToolbar() {
//        tvTitle.text = getString(R.string.favoriteTab)

        ivFavouritesBack.throttleClicks().subscribe {
            activity.onBackPressed()
        }.autoDispose(compositeDisposable)
    }


    companion object {
        fun newInstance(): FavouriteCustomerFragment {
            return FavouriteCustomerFragment()
        }
    }

    fun onPageSelected(position: Int) {

        if (Utils.userId == 0) {

        } else {
            getFavouriteStoreApi()
        }
    }


    fun initMethod() {

        arrayFavouriteList = mutableListOf()
        favouriteAdapter = FavoriteCustomerAdapter(activity, arrayFavouriteList!!)
            .apply {
                unFavoriteInvoke = {
                    unFavouriteStore(it)
                }
                storeDetailsNavigate = {
                    storeDetailsNavigate(it)
                }
            }
        favoriteRv.adapter = favouriteAdapter

    }

    private fun observableViewModel() {
        favouriteViewModel.favoriteStoresList.observe(viewLifecycleOwner, Observer {
            swipeRefresh.isRefreshing = false
            arrayFavouriteList?.clear()
            arrayFavouriteList?.addAll(it)
            textEmptyFav.visibility = View.GONE
            favouriteAdapter?.notifyDataSetChanged()
        })

        favouriteViewModel.errorMessage.observe(viewLifecycleOwner, Observer { error ->
            swipeRefresh.isRefreshing = false
            arrayFavouriteList?.clear()
            favouriteAdapter?.notifyDataSetChanged()
            textEmptyFav.visibility = View.VISIBLE
        })

        storeWithProductViewModel.message.observe(viewLifecycleOwner, Observer { it ->
            swipeRefresh.isRefreshing = false
            getFavouriteStoreApi()
        })

    }

    private fun unFavouriteStore(position: Int) {
        getStoreFavouriteApi(position)
    }

    private fun storeDetailsNavigate(position: Int) {
        if (arrayFavouriteList?.get(position)?.can_provide_service == "1") {
            startActivityWithProduct(position)
        } else {
            startActivityWithOutProduct(position)
        }
    }

    private fun startActivityWithProduct(positionMain: Int) {

        var intentStore = Intent(context, StoreDetailsActivity::class.java)
        intentStore.putExtra(KeysUtils.keyStoreId, arrayFavouriteList?.get(positionMain)?.store_id)
        intentStore.putExtra(KeysUtils.KeyFreshProduceCategoryId, arrayFavouriteList?.get(positionMain)?.fresh_produce_category_id)
        activity.startActivityWithDefaultAnimations(intentStore)
    }

    private fun startActivityWithOutProduct(positionMain: Int) {
        var intentStore = Intent(context, StoreWithoutProductActivity::class.java)
        intentStore.putExtra(KeysUtils.keyStoreId, arrayFavouriteList?.get(positionMain)?.store_id)
        activity.startActivityWithDefaultAnimations(intentStore)
    }


    private fun getFavourite(position: Int): SetFavourite {
        return SetFavourite(
            Utils.seceretKey,
            Utils.accessKey,
            arrayFavouriteList?.get(position)?.store_id!!,
            Utils.userId,
            "0"
        )
    }

    private fun getStoreFavouriteApi(position: Int) {
        storeWithProductViewModel.getStoreFavouriteApi(getFavourite(position))
    }

    private fun getFavouriteStoreApi() {
        favouriteViewModel.favouriteApiCall(
            FavoriteStoresRequest(
                Utils.seceretKey,
                Utils.accessKey, Utils.userId
            )
        )
    }

    override fun onRefresh(direction: SwipyRefreshLayoutDirection?) {
        swipeRefresh.isRefreshing = true
        getFavouriteStoreApi()
    }
}