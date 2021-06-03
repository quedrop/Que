package com.quedrop.driver.utils

import android.util.Log
import java.text.SimpleDateFormat
import java.util.*

object UtilityMethod {



    fun convertDateLocalFormat(dateValue:String):Date{
        val getEndDate = dateValue
        val readDate = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSZ", Locale.getDefault())
        val originalDate = readDate.parse(getEndDate.replace("Z$".toRegex(), "+0000"))
        Log.e("originalDate", "===> $originalDate")

        val sdf = SimpleDateFormat("dd-MM-yyyy hh:mm:ss a", Locale.getDefault())
        sdf.timeZone = TimeZone.getTimeZone("UTC")
        val utcStringDate = sdf.format(originalDate!!)
        val dateUTC: Date = sdf.parse(utcStringDate)!!
        Log.e("dateUTC", "===> $utcStringDate")

        val outputFormat = SimpleDateFormat("dd-MM-yyyy hh:mm:ss a", Locale.getDefault())
        val timeZone = Calendar.getInstance().timeZone.id
        val localDate = Date(dateUTC.time + TimeZone.getTimeZone(timeZone).getOffset(dateUTC.time))
        val outputDate = outputFormat.format(localDate)
        Log.e("outputDate: ", "==> $outputDate")
        return localDate
    }

     fun getFormattedDate(selectedDate: Calendar?, format:String): String {
//        val date = selectedDate?.time
//        val format1 = SimpleDateFormat("dd-MMMM-yyyy", Locale.getDefault())
//        val formatedDate = format1.format(date!!)
//        tvDate.text = formatedDate

        val format2 = SimpleDateFormat(format, Locale.getDefault())
        val orderDate = format2.format(selectedDate?.time!!)
        return orderDate
    }

    fun getDateFormatFroDots(date:String): String {
        val format1 =  SimpleDateFormat("yyyy-MM-dd", Locale.getDefault());
        val format2 =  SimpleDateFormat("yyyy/MM/dd", Locale.getDefault());
        val dateResult:Date  = format1.parse(date)!!
        return format2.format(dateResult)
    }
}