package com.quedrop.customer.utils

import android.content.Context
import android.graphics.*
import android.widget.Toast
import com.google.firebase.messaging.RemoteMessage
import com.google.gson.JsonObject
import com.google.gson.JsonParser
import okhttp3.MediaType.Companion.toMediaTypeOrNull
import okhttp3.MultipartBody
import okhttp3.RequestBody
import java.io.File
import java.text.SimpleDateFormat
import java.util.*


object Utility {
    fun getFileBody(key: String?, filePath: String?): MultipartBody.Part {
        val file = File(filePath)
        val fileReqBody =
            RequestBody.create("image/*".toMediaTypeOrNull(), file)
        return MultipartBody.Part.createFormData(key!!, file.name, fileReqBody)
    }

    fun createDrawableNode(strText: String?): Bitmap {
        val mTextPaint = Paint()
        mTextPaint.color = Color.WHITE
        mTextPaint.textAlign = Paint.Align.CENTER
        mTextPaint.isDither = true
        mTextPaint.isAntiAlias = true
        mTextPaint.isFilterBitmap = true
        mTextPaint.textSize = 38f
        //round? kmnu that
        val vSize = 56f
        val bitmap =
            Bitmap.createBitmap(vSize.toInt(), vSize.toInt(), Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        val paint = Paint()
        paint.style = Paint.Style.FILL
        paint.color = Color.BLACK
        paint.isAntiAlias = true
        val rectF = RectF(0F, 0F, canvas.width.toFloat(), canvas.height.toFloat())
        val cornersRadius = 40
        canvas.drawRoundRect(rectF, cornersRadius.toFloat(), cornersRadius.toFloat(), paint)
        val xPos = canvas.width / 2
        val yPos =
            (canvas.height / 2 - (mTextPaint.descent() + mTextPaint.ascent()) / 2).toInt()
        canvas.drawText(strText!!, xPos.toFloat(), yPos.toFloat(), mTextPaint)
        return bitmap
    }

    fun toastLong(mContext: Context?, message: String) {
        Toast.makeText(mContext, "" + message, Toast.LENGTH_SHORT).show()
    }

    fun convertRemoteMessage(remoteMessage: RemoteMessage): JsonObject {
        val jsonObject = JsonObject() // com.google.gson.JsonObject
        val jsonParser = JsonParser() // com.google.gson.JsonParser
        val map = remoteMessage.data
        var valData: String

        for (mykey in map.keys) {
            valData = map[mykey]!!
            try {
                jsonObject.add(mykey, jsonParser.parse(valData))
            } catch (e: Exception) {
                jsonObject.addProperty(mykey, valData)
            }

        }
        return jsonObject
    }
    fun convertUTCDateToLocalDate(date: String,format:String): String {
        val dateStr = date
        val df = SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault())
        df.timeZone = TimeZone.getTimeZone("UTC")
        val date = df.parse(dateStr)
        df.timeZone = TimeZone.getDefault()

        val localDate = df.format(date)

        val formatter = SimpleDateFormat(format, Locale.getDefault())
        return formatter.format(df.parse(localDate))
    }

}
