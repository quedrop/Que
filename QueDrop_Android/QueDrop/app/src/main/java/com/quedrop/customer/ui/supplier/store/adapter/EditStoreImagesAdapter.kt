package com.quedrop.customer.ui.supplier.store.adapter

import android.annotation.SuppressLint
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import com.bumptech.glide.load.resource.bitmap.RoundedCorners
import com.quedrop.customer.R
import com.quedrop.customer.base.rxjava.throttleClicks
import io.reactivex.Observable
import io.reactivex.subjects.PublishSubject


class EditStoreImagesAdapter : RecyclerView.Adapter<EditStoreImagesAdapter.ProfileImagesHolder>() {

    companion object {
        var TYPE_CANCEL = 1
        var TYPE_SELECT = 2
    }

    var dataList: ArrayList<String> = arrayListOf()

    private val setCategoryClickSubject =
        PublishSubject.create<Triple<Int, Int, ArrayList<String>>>()

    fun getCategoryClickObservable(): Observable<Triple<Int, Int, ArrayList<String>>> {
        return setCategoryClickSubject.hide()
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ProfileImagesHolder {
        val view = LayoutInflater.from(parent.context)
            .inflate(R.layout.item_profile_images, parent, false)
        return ProfileImagesHolder(
            view
        )
    }

    override fun getItemCount(): Int {
        return if (100 > dataList.size)
            dataList.size
        else
            100
    }

    @SuppressLint("CheckResult")
    override fun onBindViewHolder(holder: ProfileImagesHolder, position: Int) {
        holder.bind(dataList[holder.adapterPosition])

        holder.ibEditUserImage.throttleClicks()
            .subscribe {
                setCategoryClickSubject.onNext(
                    Triple(TYPE_CANCEL, holder.adapterPosition, dataList)
                )
            }

        if (position == dataList.lastIndex && dataList[position] == R.drawable.addstore.toString()) {
            holder.constraintMain.throttleClicks()
                .subscribe {
                    setCategoryClickSubject.onNext(
                        Triple(
                            TYPE_SELECT,
                            holder.adapterPosition, dataList
                        )
                    )
                }
        }
    }

    class ProfileImagesHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        val constraintMain = itemView.findViewById<ConstraintLayout>(R.id.constraintMain)
        val ivProfileImage = itemView.findViewById<ImageView>(R.id.ivProfileImage)
        val ibEditUserImage = itemView.findViewById<ImageView>(R.id.ibEditUserImage)

        @SuppressLint("SetTextI18n")
        fun bind(faqs: String) {
            Glide.with(itemView.context).load(faqs).transform(RoundedCorners(2))
                .placeholder(R.drawable.addstore)
                .centerCrop()
                .into(ivProfileImage)

            if (faqs == R.drawable.addstore.toString()) {
                ibEditUserImage.visibility = View.GONE
            } else {
                ibEditUserImage.visibility = View.VISIBLE
            }
        }
    }

    fun updateImages(images: ArrayList<String>) {
        dataList.clear()
        dataList.addAll(images)
        notifyDataSetChanged()
    }
}