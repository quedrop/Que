package com.quedrop.customer.ui.supplier.product.viewmodel

import com.quedrop.customer.base.BaseViewModel
import com.quedrop.customer.network.ApiInterface
import com.quedrop.customer.network.GenieResponse
import io.reactivex.Single
import okhttp3.MultipartBody
import okhttp3.RequestBody

class AddProductViewModel(private val apiService: ApiInterface) : BaseViewModel() {

    fun addProductApi(
        store_category_id: RequestBody,
        user_id: RequestBody,
        product_name: RequestBody,
        product_price: RequestBody,
        product_description: RequestBody,
        product_image: MultipartBody.Part?,
        addons: RequestBody,
        extra_fees_tag: RequestBody,
        price_options: RequestBody,
        extra_fee: RequestBody,
        is_available: RequestBody,
        secret_key: RequestBody,
        access_key: RequestBody
    ): Single<GenieResponse<Nothing>> {
        return apiService.addProductApi(
            store_category_id,
            user_id,
            product_name,
            product_price,
            product_description,
            product_image,
            addons,
            price_options,
            extra_fees_tag,
            extra_fee,
            is_available,
            secret_key,
            access_key
        )
    }

    fun editProductApi(
        product_id: RequestBody,
        store_category_id: RequestBody,
        user_id: RequestBody,
        product_name: RequestBody,
        product_price: RequestBody,
        product_description: RequestBody,
        product_image: MultipartBody.Part?,
        addons: RequestBody,
        extra_fees_tag: RequestBody,
        price_options: RequestBody,
        extra_fee: RequestBody,
        is_available: RequestBody,
        delete_addon_ids: RequestBody,
        delete_option_ids: RequestBody,
        secret_key: RequestBody,
        access_key: RequestBody
    ): Single<GenieResponse<Nothing>> {
        return apiService.editProductApi(
            product_id,
            store_category_id,
            user_id,
            product_name,
            product_price,
            product_description,
            product_image,
            addons,
            price_options,
            extra_fees_tag,
            extra_fee,
            is_available,
            delete_addon_ids,
            delete_option_ids,
            secret_key,
            access_key
        )
    }
}