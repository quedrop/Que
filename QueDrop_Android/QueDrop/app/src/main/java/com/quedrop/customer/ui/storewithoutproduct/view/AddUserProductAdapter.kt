package com.quedrop.customer.ui.storewithoutproduct.view

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.EditText
import android.widget.ImageView
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import com.quedrop.customer.R
import com.quedrop.customer.model.AddOrder
import android.graphics.Bitmap
import android.text.Editable
import android.text.TextWatcher
import android.graphics.BitmapFactory
import android.net.Uri
import java.io.File
import java.io.FileInputStream


class AddUserProductAdapter(
    var context: Context,
    var arrayUserProductList: MutableList<AddOrder>?,
    var arrayDeleteProductId: ArrayList<Int>?
) :
    RecyclerView.Adapter<RecyclerView.ViewHolder>() {

    var strEditProductName: String? = null
    var strEditQuantity: String? = null
    val PICK_IMAGE = 1
    var bitmapMain: Bitmap? = null
    var pathMainImage: String? = null
    var addNewItemInvoke: ((Int) -> Unit)? = null
    var deleteListInvoke: ((ArrayList<Int>, Int) -> Unit)? = null
    var dialogChoosePicInvoke: ((Int) -> Unit)? = null

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        val v: View
        v = LayoutInflater.from(parent.context)
            .inflate(R.layout.layout_user_add_product, parent, false)
        return AddProductViewHolder(v)
    }

    override fun getItemCount(): Int {
        return if (arrayUserProductList != null)
            return arrayUserProductList!!.size
        else 0
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {

        if (holder is AddProductViewHolder) {

            holder.checkTextVisibility()
            holder.tvNameAddProduct.setText(arrayUserProductList?.get(position)!!.product_name.toString())
            holder.tvQuantityAddProduct.setText(arrayUserProductList?.get(position)!!.qty.toString())
            holder.getBitmap(arrayUserProductList?.get(position)!!.image_path)
        }
    }

    fun setImage(bitmap: Bitmap, path: String, uri: Uri, positionClickImage: Int) {

        val paths = path.split("/")

        if (paths != null) {
            for ((i, v) in paths.withIndex()) {
                if (i == (paths.size - 1)) {

                    arrayUserProductList?.get(positionClickImage)!!.image_name = paths[i]
                }
            }

        }

        bitmapMain = bitmap
        pathMainImage = path
        arrayUserProductList?.get(positionClickImage)!!.image_uri = uri
        arrayUserProductList?.get(positionClickImage)!!.image_path = path

        notifyDataSetChanged()
    }

    inner class AddProductViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        var ivImageAddProduct: ImageView
        var ivCloseAddProduct: ImageView
        var tvNameAddProduct: EditText
        var tvQuantityAddProduct: EditText
        var tvAddItemAddProduct: TextView

        init {
            this.ivImageAddProduct = itemView.findViewById(R.id.ivImageAddProduct)
            this.tvNameAddProduct = itemView.findViewById(R.id.tvNameAddProduct)
            this.tvQuantityAddProduct = itemView.findViewById(R.id.tvQuantityAddProduct)
            this.ivCloseAddProduct = itemView.findViewById(R.id.ivCloseAddProduct)
            this.tvAddItemAddProduct = itemView.findViewById(R.id.tvAddItemAddProduct)

            ivCloseAddProduct.setOnClickListener {

                arrayDeleteProductId?.add(arrayUserProductList?.get(adapterPosition)?.user_product_id!!)
                arrayUserProductList?.removeAt(adapterPosition)
                notifyDataSetChanged()
                if (arrayUserProductList?.size == 0) {
                   addNewItemInvoke?.invoke(adapterPosition)
                }else{
                    deleteListInvoke?.invoke(arrayDeleteProductId!!,adapterPosition)
                }

            }

            tvAddItemAddProduct.setOnClickListener {
                tvAddItemAddProduct.visibility = View.GONE
                checkTextVisibility()

                addNewItemInvoke?.invoke(adapterPosition)
            }


            ivImageAddProduct.setOnClickListener {

                bitmapMain = null
                pathMainImage = null

                dialogChoosePicInvoke?.invoke(adapterPosition)
            }

            tvNameAddProduct.addTextChangedListener(object : TextWatcher {
                override fun afterTextChanged(s: Editable?) {

                    arrayUserProductList?.get(adapterPosition)!!.product_name = s.toString()

//                    checkTextVisibility()
                    checkFlag()


                }

                override fun beforeTextChanged(
                    s: CharSequence?,
                    start: Int,
                    count: Int,
                    after: Int
                ) {

                }

                override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {

                }
            })

            tvQuantityAddProduct.addTextChangedListener(object : TextWatcher {
                override fun afterTextChanged(s: Editable?) {
                    arrayUserProductList?.get(adapterPosition)!!.qty = s.toString()


//                    checkTextVisibility()
                    checkFlag()

                }

                override fun beforeTextChanged(
                    s: CharSequence?,
                    start: Int,
                    count: Int,
                    after: Int
                ) {

                }

                override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {

                }
            })
        }


        private fun checkFlag() {
            if (arrayUserProductList?.get(adapterPosition)!!.product_name.isNotEmpty() && arrayUserProductList?.get(
                    adapterPosition
                )!!.qty.isNotEmpty()
            ) {
                arrayUserProductList?.get(adapterPosition)!!.product_Flag = true
                checkTextVisibility()
            } else {
                arrayUserProductList?.get(adapterPosition)!!.product_Flag = false

//                arrayDeleteProductId?.add(arrayUserProductList?.get(adapterPosition)?.user_product_id!!)
//                arrayUserProductList?.removeAt(adapterPosition)
//                notifyDataSetChanged()
//                if (arrayUserProductList?.size == 0) {
//                    addNewItemInvoke?.invoke(adapterPosition)
//                }else{
//                    deleteListInvoke?.invoke(arrayDeleteProductId!!,adapterPosition)
//                }

            }
            checkTextVisibility()
        }

        fun checkTextVisibility() {
            if (arrayUserProductList?.size!! - 1 == adapterPosition) {

                if (arrayUserProductList?.get(adapterPosition)!!.product_Flag) {
                    ivCloseAddProduct.visibility = View.VISIBLE
                    tvAddItemAddProduct.visibility = View.VISIBLE
                } else {
                    ivCloseAddProduct.visibility = View.GONE
                    tvAddItemAddProduct.visibility = View.GONE
                }
            } else {
                ivCloseAddProduct.visibility = View.VISIBLE
                tvAddItemAddProduct.visibility = View.GONE
            }

        }

        fun getBitmap(path: String) {
            try {

                if (path.isNullOrBlank()) {
                    ivImageAddProduct.setImageResource(R.drawable.ic_add_product_camera)
                } else {
                    var bitmap: Bitmap? = null
                    val f = File(path)
                    val options = BitmapFactory.Options()
                    options.inPreferredConfig = Bitmap.Config.ARGB_8888


                    bitmap = BitmapFactory.decodeStream(FileInputStream(f), null, options)
                    ivImageAddProduct.setImageBitmap(bitmap)
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }

        }


//        private fun bitmapFromPath(){
//            val sd = Environment.getExternalStorageDirectory()
//            val image = File(sd + filePath, imageName)
//            val bmOptions = BitmapFactory.Options()
//            var bitmap = BitmapFactory.decodeFile(image.getAbsolutePath(), bmOptions)
//            bitmap = Bitmap.createScaledBitmap(bitmap, parent.getWidth(), parent.getHeight(), true)
//            imageView.setImageBitmap(bitmap)
//        }
    }

}