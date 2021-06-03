package com.quedrop.customer.utils

import android.app.AlertDialog
import android.app.Dialog
import android.content.Context
import android.content.DialogInterface
import android.graphics.Color
import android.graphics.drawable.ColorDrawable
import android.view.ViewGroup
import android.view.Window
import com.quedrop.customer.R

import kotlinx.android.synthetic.main.loader_view.*


object DialogCaller {

    fun showDialog(
        context: Context, title: String?, message: String,
        onClickListener: DialogInterface.OnClickListener
    ) {

        val dialog = AlertDialog.Builder(context)

        if (title != null && title.length > 0) {
            dialog.setTitle(title)
        }

        dialog.setMessage(message)
        dialog.setPositiveButton("Ok", onClickListener)
        //dialog.setNegativeButton("Cancel", null);
        dialog.show()
    }

    fun showAlertDialog(context: Context, title: String = "", message: String) {
        val dialog = AlertDialog.Builder(context)
        if (title.isNotEmpty()) {
            dialog.setTitle(title)
        }
        dialog.setMessage(message)
        dialog.setPositiveButton("Ok") { dialogInterface, i ->
            dialogInterface.dismiss()
        }
        dialog.show()
    }

    fun showDialogDark(
        context: Context, title: String?, message: String,
        onClickListener: DialogInterface.OnClickListener
    ) {

        val dialog = AlertDialog.Builder(context)

        if (title != null && title.length > 0) {
            dialog.setTitle(title)
        }

        dialog.setMessage(message)
        dialog.setPositiveButton("Ok", onClickListener)
        //dialog.setNegativeButton("Cancel", null);
        dialog.show()
    }


    fun showActionDialog(
        context: Context,
        title: String?,
        message: String,
        onClickListener: DialogInterface.OnClickListener,
        onClickListener2: DialogInterface.OnClickListener
    ) {

        val dialog = AlertDialog.Builder(context)

        if (title != null && title.length > 0) {
            dialog.setTitle(title)
        }

        dialog.setMessage(message)
        dialog.setPositiveButton("Ok", onClickListener)
        dialog.setNegativeButton("Cancel", onClickListener2)
        dialog.show()
    }

    fun showActionDialogDark(
        context: Context,
        title: String?,
        message: String,
        onClickListener: DialogInterface.OnClickListener,
        onClickListener2: DialogInterface.OnClickListener
    ) {

        val dialog = AlertDialog.Builder(context)

        if (title != null && title.length > 0) {
            dialog.setTitle(title)
        }

        dialog.setMessage(message)
        dialog.setPositiveButton("Ok", onClickListener)
        dialog.setNegativeButton("Cancel", onClickListener2)
        dialog.show()
    }


    fun showProgressDialog(
        context: Context,
        message: String = "Please wait...",
        isCancelable: Boolean = false
    ): Dialog {

        val dialog = Dialog(context)
        dialog.apply {
            requestWindowFeature(Window.FEATURE_NO_TITLE)
            setCancelable(isCancelable)
            setContentView(R.layout.loader_view)
            window?.apply {
                setLayout(
                    (Utils.getDeviceWidth(context) * 0.85).toInt(),
                    ViewGroup.LayoutParams.WRAP_CONTENT
                )
                setBackgroundDrawable(ColorDrawable(Color.TRANSPARENT))
            }

            tvLoaderTitle.text = message
        }
        dialog.show()
        return dialog
    }

}