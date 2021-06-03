package com.quedrop.customer.ui.selectaddress.view


import android.annotation.SuppressLint
import android.content.Context
import android.util.Log
import androidx.recyclerview.widget.RecyclerView
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.*
import com.google.android.gms.maps.model.LatLng
import com.quedrop.customer.R
import com.quedrop.customer.model.Address
import com.quedrop.customer.utils.ConstantUtils
import com.quedrop.customer.utils.KeysUtils
import com.quedrop.customer.utils.SharedPrefsUtils


class AddressDisplayAdapter(
    internal var context: Context,
    internal var addressList: MutableList<Address>?
) :
    RecyclerView.Adapter<RecyclerView.ViewHolder>() {

    var currentAddress: String = ""

    var finishAct: ((View) -> Unit)? = null
    var addressInvoke: ((View) -> Unit)? = null
    var onDeleteAddress: ((Int, View) -> Unit)? = null

    var currentAddressTitle:String = ""
    var currentLatitude:Double = 0.0
    var currentLongitude:Double = 0.0


    fun setCurentAddress(currentAddress1: String) {
        currentAddress = currentAddress1
        notifyDataSetChanged()
    }

    fun setCurrentAddressIntoPreference(currentAddress1: String,title:String,latitude:Double,longitude:Double) {
        currentAddress = currentAddress1
        currentAddressTitle = title
        currentLatitude = latitude
        currentLongitude = longitude
    }

    override fun onCreateViewHolder(
        parent: ViewGroup,
        viewType: Int
    ): RecyclerView.ViewHolder {

        when (viewType) {
            ConstantUtils.ONE -> return MyviewHolder(
                LayoutInflater.from(parent.context).inflate(
                    R.layout.layout_display_address,
                    parent,
                    false
                )
            )
            ConstantUtils.ZERO -> return MyviewHolderCurrent(
                LayoutInflater.from(parent.context).inflate(
                    R.layout.layout_list_recyclecurrent,
                    parent,
                    false
                )
            )
            else ->
                return MyviewHolderCurrent(
                    LayoutInflater.from(parent.context).inflate(
                        R.layout.layout_display_address,
                        parent,
                        false
                    )
                )
        }
    }

    override fun getItemViewType(position: Int): Int {
        var viewtype = ConstantUtils.ZERO

        if (position == ConstantUtils.ZERO) {
            viewtype = ConstantUtils.ZERO
        } else {
            viewtype = ConstantUtils.ONE
        }
        return viewtype
    }


    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        if (position == ConstantUtils.ZERO) {
            if (holder is MyviewHolderCurrent) {
                holder.bindCurrentAddress(position)
            }
        } else {
            if (holder is MyviewHolder) {
                holder.bindAddAddress(position)
            }
        }
    }

    override fun getItemCount(): Int {
        return if (addressList != null) {
            addressList!!.size
        } else 0

    }

    inner class MyviewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        internal var name: TextView = itemView.findViewById(R.id.name)
        internal var address: TextView = itemView.findViewById(R.id.address)
        internal var imageIcon: ImageView = itemView.findViewById(R.id.imageIcon)
        internal var imageMenu: ImageView = itemView.findViewById(R.id.imageMenu)

        init {

            itemView.setOnClickListener {
                val posRecycle = layoutPosition

                SharedPrefsUtils.setStringPreference(context, KeysUtils.KeySelectAddress, addressList?.get(posRecycle)?.address!!)
                SharedPrefsUtils.setStringPreference(context, KeysUtils.KeySelectAddressName, addressList?.get(posRecycle)?.address_title!!)
                SharedPrefsUtils.setStringPreference(context, KeysUtils.KeySelectAddressType, addressList?.get(posRecycle)?.address_type!!)
                SharedPrefsUtils.setStringPreference(context, KeysUtils.KeyLatitude, addressList?.get(posRecycle)?.latitude!!)
                SharedPrefsUtils.setStringPreference(context, KeysUtils.KeyLongitude, addressList?.get(posRecycle)?.longitude!!)

                finishAct?.invoke(it)
            }
        }


        @SuppressLint("SetTextI18n")
        fun bindAddAddress(position: Int) {

            when {
                addressList?.get(position)?.address_type.equals(context.getString(R.string.work)) -> {
                    imageIcon.setImageResource(R.drawable.ic_office)
                }
                addressList?.get(position)?.address_type.equals(context.getString(R.string.hotel)) -> {
                    imageIcon.setImageResource(R.drawable.ic_sunumbrella)
                }
                addressList?.get(position)?.address_type.equals(context.getString(R.string.other)) -> {
                    imageIcon.setImageResource(R.drawable.ic_placeholder)
                }
                else -> imageIcon.setImageResource(R.drawable.ic_home)
            }

            name.text = addressList?.get(position)?.address_title

            if (addressList?.get(position)?.unit_number.isNullOrBlank()) {
                address.text = addressList?.get(position)?.address
            } else {
                address.text = addressList?.get(position)?.unit_number + "," + addressList?.get(position)?.address
            }

            imageMenu.setOnClickListener {
                onDeleteAddress?.invoke(position, it)
            }
        }
    }

    inner class MyviewHolderCurrent(itemView: View) : RecyclerView.ViewHolder(itemView) {
        fun bindCurrentAddress(position: Int) {
            textCurrentAddress.text = currentAddress

            ivRefresh.setOnClickListener {
                addressInvoke?.invoke(it)
                notifyDataSetChanged()
            }
        }
        internal var textCurrentAddress: TextView = itemView.findViewById(R.id.textCurrentAddress)
        internal var textCurrentTitle: TextView = itemView.findViewById(R.id.textCurrentTitle)
        internal var ivRefresh: ImageView = itemView.findViewById(R.id.ivRefresh)


        init {

            Log.e("AddressList","==>"+addressList.toString())
            itemView.setOnClickListener {
                val posRecycle = layoutPosition
                SharedPrefsUtils.setStringPreference(context, KeysUtils.KeySelectAddress, currentAddress)
                SharedPrefsUtils.setStringPreference(context, KeysUtils.KeySelectAddressName, currentAddressTitle)
                SharedPrefsUtils.setStringPreference(context, KeysUtils.KeySelectAddressType,  ConstantUtils.ONE.toString())
                SharedPrefsUtils.setStringPreference(context, KeysUtils.KeyLatitude, currentLatitude.toString())
                SharedPrefsUtils.setStringPreference(context, KeysUtils.KeyLongitude, currentLongitude.toString())
                finishAct?.invoke(it)
            }

        }
    }
}