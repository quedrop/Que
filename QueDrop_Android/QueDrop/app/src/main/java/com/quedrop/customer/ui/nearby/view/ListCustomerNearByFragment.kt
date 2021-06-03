package com.quedrop.customer.ui.nearby.view

import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.lifecycle.Observer
import androidx.recyclerview.widget.LinearLayoutManager
import com.quedrop.customer.R
import com.quedrop.customer.base.BaseFragment
import com.quedrop.customer.model.AddNearByStores
import com.quedrop.customer.model.NearByStores
import com.quedrop.customer.model.SearchStoreByName
import com.quedrop.customer.utils.KeysUtils
import com.quedrop.customer.utils.Utils
import kotlinx.android.synthetic.main.fragment_listview_nearby.*


class ListCustomerNearByFragment : BaseFragment() {

    var arrayListNearBy: MutableList<NearByStores>? = null
    var listCustomerNearByAdapter: ListNearByCustomerAdapter? = null

    var id: Int? = null
    var name: String? = null
    var searchString: String? = null
    var freshProduceCatId: Int? = 0

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {

        id = arguments?.getInt(KeysUtils.KeyServiceCategoryId)
        name = arguments?.getString(KeysUtils.KeyServiceCategoryName)
        searchString = arguments?.getString(KeysUtils.KeyStringSearch)
        searchString = arguments?.getString(KeysUtils.KeyStringSearch)
        freshProduceCatId = arguments?.getInt(KeysUtils.KeyFreshProduceCategoryId, 0)

        return inflater.inflate(
            R.layout.fragment_listview_nearby,
            container, false
        )
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)

        observeViewModel()
        mRecyclerViewNearBy!!.setHasFixedSize(true)

        mRecyclerViewNearBy.layoutManager = LinearLayoutManager(
            activity.applicationContext!!,
            LinearLayoutManager.VERTICAL,
            false
        )

        arrayListNearBy = mutableListOf()


        listCustomerNearByAdapter = ListNearByCustomerAdapter(
            activity,
            arrayListNearBy
        )
        if ((activity as NearByRestaurantActivity).flagSearchClick) {
            if (searchString!!.isEmpty()) {
                getNearByStoresApi()

            } else {
                searchStoreApi()
            }
        } else {
            getNearByStoresApi()
        }

        mRecyclerViewNearBy!!.adapter = listCustomerNearByAdapter
    }

    private fun observeViewModel() {
        (activity as NearByRestaurantActivity).listNearByViewModel.errorMessage.observe(
            viewLifecycleOwner,
            Observer {
                (activity as NearByRestaurantActivity).hideProgress()
                arrayListNearBy?.clear()
                listCustomerNearByAdapter?.notifyDataSetChanged()
//                Toast.makeText(
//                    activity,
//                    it,
//                    Toast.LENGTH_SHORT
//                ).show()
            })
        (activity as NearByRestaurantActivity).listNearByViewModel.arrayListNearBy.observe(
            viewLifecycleOwner,
            Observer {
                (activity as NearByRestaurantActivity).hideProgress()
                arrayListNearBy?.clear()
                arrayListNearBy?.addAll(it.toMutableList())
                listCustomerNearByAdapter?.notifyDataSetChanged()
            })
    }

    private fun getAddNearByStore(latitude: String, longitude: String): AddNearByStores {
        return AddNearByStores(
            Utils.seceretKey,
            Utils.accessKey,
            this.id!!,
            latitude,
            longitude
        )
    }

    private fun getSearchStoreByName(): SearchStoreByName {
        return SearchStoreByName(
            Utils.seceretKey,
            Utils.accessKey,
            this.searchString!!,
            this.id!!,
            this.freshProduceCatId!!
        )

    }

    private fun getNearByStoresApi() {

        (activity as NearByRestaurantActivity).showProgress()

        (activity as NearByRestaurantActivity).listNearByViewModel.getNearByStoreApi(
            getAddNearByStore(Utils.keyLatitude, Utils.keyLongitude)
        )
    }

    private fun searchStoreApi() {
        (activity as NearByRestaurantActivity).showProgress()

        (activity as NearByRestaurantActivity).listNearByViewModel.getSearchStoreApi(
            getSearchStoreByName()
        )
    }
}