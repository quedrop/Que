package com.quedrop.driver.utils

import android.content.Context
import android.content.SharedPreferences
import android.text.TextUtils.isEmpty
import com.quedrop.driver.base.QueDropDriverApplication
import com.quedrop.driver.service.model.Orders
import com.google.gson.Gson
import com.google.gson.JsonParser
import com.google.gson.reflect.TypeToken
import org.json.JSONObject


class SharedPreferenceUtils private constructor() {

    private val sharedPref: SharedPreferences = QueDropDriverApplication.context.applicationContext
        .getSharedPreferences("shared_preference.xml", Context.MODE_PRIVATE)


    companion object {

        private val instance = SharedPreferenceUtils()

        fun setString(key: String, value: String) {
            val editor = instance.sharedPref.edit()
            editor.putString(key, value)
            editor.apply()
        }

        fun getString(key: String): String {
            if (key == KEY_LATITUDE || key == KEY_LONGITUDE) {
                return instance.sharedPref.getString(key, "0.0")!!
            } else {
                return instance.sharedPref.getString(key, "")!!
            }
        }

/*
        fun putLatLng(key: String, value: String) {
            val editor = instance.sharedPref.ic_edit_pen()
            editor.putString(key, value)
            editor.apply()
        }

        fun getLatLng(key: String): String {
            return instance.sharedPref.getString(key, "0.0")!!
        }*/

        fun getStringOrNull(key: String): String? {
            return instance.sharedPref.getString(key, null)
        }

        fun setBoolean(key: String, value: Boolean) {
            val editor = instance.sharedPref.edit()
            editor.putBoolean(key, value)
            editor.apply()
        }

        fun getBoolean(key: String): Boolean {
            return instance.sharedPref.getBoolean(key, false)
        }

        fun setInt(key: String, value: Int) {
            val editor = instance.sharedPref.edit()
            editor.putInt(key, value)
            editor.apply()
        }

        fun getInt(key: String): Int {
            return instance.sharedPref.getInt(key, 0)
        }

        fun setLong(key: String, value: Long) {
            val editor = instance.sharedPref.edit()
            editor.putLong(key, value)
            editor.apply()
        }

        fun getLong(key: String): Long {
            return instance.sharedPref.getLong(key, 0)
        }

        fun setFloat(key: String, value: Float) {
            val editor = instance.sharedPref.edit()
            editor.putFloat(key, value)
            editor.apply()
        }

        fun getFloat(key: String): Float {
            return instance.sharedPref.getFloat(key, 0F)
        }


        fun clear() {
            val editor = instance.sharedPref.edit()
            editor.clear()
            editor.apply()
        }

        fun setModelPreferences(key: String, value: Any) {
            val editor = instance.sharedPref.edit()
            val gson = Gson()
            val json = gson.toJson(value)
            editor.putString(key, json)
            editor.apply()
        }

        fun <T> getModelPreferences(key: String, objectClass: Class<T>): Any? {
            val editor = instance.sharedPref
            val gson = Gson()
            val json = editor.getString(key, "")
            return if (!isEmpty(json)) {
                gson.fromJson(json, objectClass)
            } else null
        }

        fun deletePreference(key: String) {
            val settings = instance.sharedPref
            val editor = settings.edit()
            editor.remove(key)
            editor.apply()
        }

        fun setArrayList(key: String, list: ArrayList<Any>) {
            val editor = instance.sharedPref.edit()
            val set = HashSet<Any>()
            set.addAll(list)

        }

        fun setCurrentOrderRequest(value: Int) {
            val editor = instance.sharedPref.edit()
            editor.putInt(KEY_CURRENT_REQUEST_ID, value)
            editor.apply()
        }

        fun getCurrentOrderRequest(): Int {
            val pref = instance.sharedPref
            return pref.getInt(KEY_CURRENT_REQUEST_ID, 0)
        }

        fun removeCurrentOrderRequest(orderId: Int) {
            val editor = instance.sharedPref.edit()
            editor.remove(KEY_CURRENT_REQUEST_ID)
            editor.apply()
        }

        fun addOrderRequestToQueue(dic: HashMap<String, Any?>) {
            var arr = getOrderRequestQueue()
            if (arr.size == 0) {
                arr.add(dic)
            } else {
                var flag = false
                for (i in 0 until arr.size) {
                    if ((arr[i]["order_id"] as Double).toInt() == (dic["order_id"] as Double).toInt()) {
                        flag = true
                    } else {

                    }
                }
                if (!flag) {
                    arr.add(dic)
                }
            }
            val editor = instance.sharedPref.edit()
            val gson = Gson()
            val hashMapString = gson.toJson(arr)
            editor.putString(KEY_RQUEST_QUEUE, hashMapString).apply()
        }

        fun getOrderRequestQueue(): ArrayList<HashMap<String, Any?>> {
            val pref = instance.sharedPref
            if (pref.contains(KEY_RQUEST_QUEUE)) {
                val gson = Gson()
                val json = pref.getString(KEY_RQUEST_QUEUE, "")
                val type = object : TypeToken<ArrayList<HashMap<String, Any?>>>() {

                }.type
                return gson.fromJson<ArrayList<HashMap<String, Any?>>>(json, type)

            }
            return ArrayList<HashMap<String, Any?>>()
        }


        fun removeOrderFromRequestQueue(orderId: Int) {
            var arr = getOrderRequestQueue()
            if (arr.size > 0) {
                for (i in 0 until arr.size) {
                    if ((arr[i]["order_id"] as Double).toInt() == orderId) {
                        arr.removeAt(i)
                        break
                    }
                }
                val editor = instance.sharedPref.edit()

                val gson = Gson()
                val hashMapString = gson.toJson(arr)
                editor.putString(KEY_RQUEST_QUEUE, hashMapString).apply()
            }
        }

        fun removeAllOrderFromRequestQueue() {
            val editor = instance.sharedPref.edit()
            editor.remove(KEY_RQUEST_QUEUE)
            editor.apply()
        }

        fun getSingleOrderRequestQueue(orderId: Int): HashMap<String, Any?> {
            val arr = getOrderRequestQueue()
            if (arr.size > 0) {
                for (i in 0 until arr.size) {
                    if ((arr[i]["order_id"] as Double).toInt() == orderId) {
                        return arr[i]
                    }
                }
            }
            return HashMap<String, Any?>()
        }

        fun getSingleRequestFromQueue(): HashMap<String, Any?> {
            if (getOrderRequestQueue().size > 0) {
                return getOrderRequestQueue()[0]
            } else {
                return HashMap<String, Any?>()
            }
        }

        fun getSingleOrderDetailsRequestFromQueue(): Orders? {
            val orderDetails = JSONObject(getSingleRequestFromQueue())
            //TODO crash Caused by: org.json.JSONException: No value for order_details
            if(orderDetails["order_details"] !=null) {
                val dicDetail = orderDetails["order_details"].toString()
                val parser = JsonParser()
                val mJson = parser.parse(dicDetail)
                val gson = Gson()

                return gson.fromJson(mJson, Orders::class.java)
            }
            return null
        }

        fun getDriverIdsOfCurrentOrder(): String {
            val orderDetails = getSingleRequestFromQueue()
            return orderDetails["order_drivers"].toString()
        }

    }

}