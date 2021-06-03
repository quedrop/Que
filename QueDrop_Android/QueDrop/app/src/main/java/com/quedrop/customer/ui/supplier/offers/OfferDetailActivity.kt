package com.quedrop.customer.ui.supplier.offers

import android.os.Bundle
import com.bumptech.glide.Glide
import com.quedrop.customer.R
import com.quedrop.customer.base.BaseActivity
import com.quedrop.customer.base.extentions.getProductImage
import com.quedrop.customer.model.SupplierProductOffer
import kotlinx.android.synthetic.main.activity_offer_detail.*

class OfferDetailActivity : BaseActivity() {
    lateinit var offerDetail: SupplierProductOffer
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_offer_detail)
        offerDetail = intent.getSerializableExtra("offer") as SupplierProductOffer
        init()
        setData()
    }

    private fun init() {
        ivBack.setOnClickListener {
            onBackPressed()
        }
    }

    private fun setData() {
        Glide.with(this).load(getProductImage(offerDetail.product_image))
            .centerCrop().into(imgProduct)

        etCategory.setText(offerDetail.store_category_title)
        etProductName.setText(offerDetail.product_name)
        etPercentage.setText(offerDetail.offer_percentage + "%")
        etOfferCode.setText(offerDetail.offer_code)
        etStartDate.setText(offerDetail.start_date + " " + offerDetail.start_time)
        etEndDate.setText(offerDetail.expiration_date + " " + offerDetail.expiration_time)
        etAdditionalInfo.setText(offerDetail.additional_info)
        switchActive.isChecked = offerDetail.is_active==1
    }

    override fun onDestroy() {
        super.onDestroy()
    }
}
