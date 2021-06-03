package com.quedrop.customer.utils

import android.app.Activity
import android.app.Dialog
import android.content.ContentValues
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Environment
import android.provider.MediaStore
import android.widget.ImageView
import android.widget.Toast
import com.quedrop.customer.R


class PspDialogUtils(var mContext: Activity) {

    var getCurrentImageUri: Uri? = null

    companion object {
        var INTENT_PICK_CAMERA: Int = 100
        var INTENT_PICK_GALLERY: Int = 101
    }

    fun openCameraGalleryDialog() {

        val dialog = Dialog(mContext)
        dialog.setContentView(R.layout.layout_dialog_choosepic)

        val ivCamera = dialog.findViewById<ImageView>(R.id.ivCamera)
        val ivGallery = dialog.findViewById<ImageView>(R.id.ivGallery)

        ivCamera.setOnClickListener {
            dialog.dismiss()
            startCamera()
        }

        ivGallery.setOnClickListener {
            dialog.dismiss()
            startGallery()
        }

        dialog.show()
    }

    private fun startCamera() {
        try {
            if (isDeviceSupportCamera()) {
                getCurrentImageUri = outputMediaFile()
                val intent = Intent(MediaStore.ACTION_IMAGE_CAPTURE)
                intent.putExtra(MediaStore.EXTRA_OUTPUT, getCurrentImageUri)
                mContext.startActivityForResult(intent, INTENT_PICK_CAMERA)
            } else {
                Toast.makeText(
                    mContext,
                    "Sorry! Your device doesn't support Camera,\n Choose image from Gallery.",
                    Toast.LENGTH_SHORT
                ).show()
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun startGallery() {
        try {
            val intent = Intent(Intent.ACTION_PICK, MediaStore.Images.Media.EXTERNAL_CONTENT_URI)
            val uri: Uri = Uri.parse(mContext.getExternalFilesDir(null)?.absolutePath)
            intent.setDataAndType(uri, "image/*")
            mContext.startActivityForResult(intent, INTENT_PICK_GALLERY)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun isDeviceSupportCamera(): Boolean {
        return mContext.packageManager.hasSystemFeature(PackageManager.FEATURE_CAMERA_ANY)
    }

    private fun outputMediaFile(): Uri {
        val values = ContentValues()
        values.put(MediaStore.Images.Media.TITLE, "Image")
        values.put(MediaStore.Images.Media.DESCRIPTION, "Camera Image")
        return mContext.contentResolver.insert(
            MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
            values
        )!!
    }

}