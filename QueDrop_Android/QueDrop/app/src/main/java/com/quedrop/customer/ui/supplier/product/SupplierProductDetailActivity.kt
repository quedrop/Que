package com.quedrop.customer.ui.supplier.product

import android.os.Bundle
import androidx.recyclerview.widget.LinearLayoutManager
import com.bumptech.glide.Glide
import com.quedrop.customer.R
import com.quedrop.customer.base.BaseActivity
import com.quedrop.customer.base.extentions.getProductImage
import com.quedrop.customer.base.extentions.startActivityWithAnimation
import com.quedrop.customer.base.rxjava.autoDispose
import com.quedrop.customer.model.SupplierProduct
import com.quedrop.customer.ui.supplier.product.adapters.CustomAddOnAdapter
import com.quedrop.customer.ui.supplier.product.adapters.CustomPriceAdapter
import com.quedrop.customer.utils.RxBus
import kotlinx.android.synthetic.main.activity_supplier_product_detail.*

class SupplierProductDetailActivity : BaseActivity() {

    private lateinit var product: SupplierProduct
    private var priceOptionsAdapter: CustomPriceAdapter? = null
    private var addOnAdapter: CustomAddOnAdapter? = null


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_supplier_product_detail)
        product = intent.getSerializableExtra("product") as SupplierProduct

        editProduct.setOnClickListener {

            RxBus.instance!!.listen().subscribe {
                if (it == "refreshProduct") { //autorefresh page after add
                    finish()
                }
            }.autoDispose(compositeDisposable)

            startActivityWithAnimation<AddProductActivity> {
                putExtra("isEditMode", true)
                putExtra("product", product)
            }
        }
        setProductDetails()

    }

    private fun setProductDetails() {
        Glide.with(this)
            .load(getProductImage(product.product_image))
            .placeholder(R.drawable.add_picture)
            .into(imgProduct)

        etProductName.setText(product.product_name)
        etAdditionalInfo.setText(product.product_description)
        etExtraFee.setText(product.extra_fees)
        switchActive.isChecked = product.is_active == 1

        if (product.product_option.size > 0) {
            if (priceOptionsAdapter == null) {
                priceOptionsAdapter = CustomPriceAdapter(this, true)
                rvPriceOption.layoutManager = LinearLayoutManager(this)
                rvPriceOption.adapter = priceOptionsAdapter
            }

            priceOptionsAdapter?._productOptionList = product.product_option
            priceOptionsAdapter?.notifyDataSetChanged()
        }

        if (product.addons.size > 0) {
            if (addOnAdapter == null) {
                addOnAdapter = CustomAddOnAdapter(this, true)
                rvAddOns.layoutManager = LinearLayoutManager(this)
                rvAddOns.adapter = addOnAdapter
            }

            addOnAdapter?._addOnList = product.addons
            addOnAdapter?.notifyDataSetChanged()
        }
    }
}
