package com.quedrop.driver.base

import android.text.format.DateUtils
import java.text.SimpleDateFormat
import java.util.*

object DateUtil {

    private val chatDateFormat by lazy { SimpleDateFormat("yyyy-MM-dd", Locale.US) }
    private val chatTimeFormat by lazy { SimpleDateFormat("HH:mm a", Locale.US) }
    private val defaultTimeZone: TimeZone by lazy { TimeZone.getDefault() }

    fun getChatTime(dateTime: String): String {
        val localDateTime = dateTime.toDate() ?: return ""
        return if (DateUtils.isToday(localDateTime.time)) {
            localDateTime.formatTo(timeZone = defaultTimeZone, formatter = chatTimeFormat)
        } else {
            localDateTime.formatTo(timeZone = defaultTimeZone, formatter = chatDateFormat)
        }
    }
}

fun Date.formatTo(
    dateFormat: String = "yyyy-MM-dd HH:mm:ss",
    timeZone: TimeZone,
    formatter: SimpleDateFormat
): String {
    formatter.timeZone = timeZone
    return formatter.format(this)
}

fun String.toDate(
    dateFormat: String = "yyyy-MM-dd HH:mm:ss",
    timeZone: TimeZone = TimeZone.getTimeZone("UTC")
): Date? {
    val parser = SimpleDateFormat(dateFormat, Locale.getDefault())
    parser.timeZone = timeZone
    return parser.parse(this)
}