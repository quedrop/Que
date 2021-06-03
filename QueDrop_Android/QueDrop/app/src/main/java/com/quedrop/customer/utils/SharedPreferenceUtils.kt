package com.quedrop.customer.utils

import android.content.Context
import android.text.TextUtils
import com.google.gson.Gson
import com.google.gson.JsonParser
import com.google.gson.reflect.TypeToken

class SharedPrefsUtils {

    companion object {

        val mode=Context.MODE_PRIVATE
        val sharedprefernce_key="Mypref"


        fun getStringPreference(context: Context, key: String): String? {
            var value: String? = null
            val preferences = context.getSharedPreferences(sharedprefernce_key,mode)
            if (preferences != null) {
                value = preferences.getString(key, "")
            }
            return value
        }


        fun setStringPreference(context: Context, key: String, value: String): Boolean {
            val preferences = context.getSharedPreferences(sharedprefernce_key,mode)
            if (preferences != null && !TextUtils.isEmpty(key)) {
                val editor = preferences.edit()
                editor.putString(key, value)
                return editor.commit()
            }
            return false
        }


        fun getFloatPreference(context: Context, key: String, defaultValue: Float): Float {
            var value = defaultValue
            val preferences = context.getSharedPreferences(sharedprefernce_key,mode)
            if (preferences != null) {
                value = preferences.getFloat(key, defaultValue)
            }
            return value
        }


        fun setFloatPreference(context: Context, key: String, value: Float): Boolean {
            val preferences = context.getSharedPreferences(sharedprefernce_key,mode)
            if (preferences != null) {
                val editor = preferences.edit()
                editor.putFloat(key, value)
                return editor.commit()
            }
            return false
        }


        fun getLongPreference(context: Context, key: String, defaultValue: Long): Long {
            var value = defaultValue
            val preferences = context.getSharedPreferences(sharedprefernce_key,mode)
            if (preferences != null) {
                value = preferences.getLong(key, defaultValue)
            }
            return value
        }


        fun setLongPreference(context: Context, key: String, value: Long): Boolean {
            val preferences = context.getSharedPreferences(sharedprefernce_key,mode)
            if (preferences != null) {
                val editor = preferences.edit()
                editor.putLong(key, value)
                return editor.commit()
            }
            return false
        }


        fun getIntegerPreference(context: Context, key: String, defaultValue: Int): Int {
            var value:Int = defaultValue
            val preferences = context.getSharedPreferences(sharedprefernce_key,mode)
            if (preferences != null) {
                value = preferences.getInt(key, defaultValue.toInt()).toInt()
            }
            return value
        }


        fun setIntegerPreference(context: Context, key: String, value: Int): Boolean {
            val preferences = context.getSharedPreferences(sharedprefernce_key,mode)
            if (preferences != null) {
                val editor = preferences.edit()
                editor.putInt(key, value)
                return editor.commit()
            }
            return false
        }


        fun getBooleanPreference(context: Context, key: String, defaultValue: Boolean): Boolean {
            var value = defaultValue
            val preferences = context.getSharedPreferences(sharedprefernce_key,mode)
            if (preferences != null) {
                value = preferences.getBoolean(key, defaultValue)
            }
            return value
        }


        fun setBooleanPreference(context: Context, key: String, value: Boolean): Boolean {
            val preferences = context.getSharedPreferences(sharedprefernce_key,mode)
            if (preferences != null) {
                val editor = preferences.edit()
                editor.putBoolean(key, value)
                return editor.commit()
            }
            return false
        }



        fun <T> getObjectList(context: Context,key: String, cls: Class<T>): MutableList<T> {
            val list = ArrayList<T>()
            try {
                val preferences = context.getSharedPreferences(sharedprefernce_key,mode)
                val gson = Gson()
                val json = preferences.getString(key, "")
                val arry = JsonParser().parse(json).asJsonArray
                for (jsonElement in arry) {
                    list.add(gson.fromJson(jsonElement, cls))
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }

            return list
        }

        fun <T> getListPreference(context: Context, key: String): MutableList<T> {

            val preferences = context.getSharedPreferences(sharedprefernce_key,mode)
            val gson = Gson()
            val json = preferences.getString(key, "")

            var yourArrayList = ArrayList<T>()

            val typeMyType = object : TypeToken<MutableList<T>>() {

            }.type

            yourArrayList =   gson.fromJson(json,typeMyType)

            return  yourArrayList
        }

        fun <T> setListPreference(context: Context, key: String, list: List<T>) {
            val preferences = context.getSharedPreferences(sharedprefernce_key,mode)
            val prefsEditor = preferences.edit()
            val gson = Gson()
            val json = gson.toJson(list)
            prefsEditor.putString(key, json)
            prefsEditor.commit()
        }

        fun removeSharedPreference(context: Context,key: String){
            val preferences = context.getSharedPreferences(sharedprefernce_key,mode)
            val prefsEditor = preferences.edit()
            prefsEditor.remove(key).commit()
        }

        fun remove(context: Context){
            val preferences = context.getSharedPreferences(sharedprefernce_key,mode)
            val prefsEditor = preferences.edit()
            prefsEditor.clear().commit()
        }

        fun setModelPreferences(context: Context,key: String, value: Any) {
            val preferences = context.getSharedPreferences(sharedprefernce_key,mode)
            val prefsEditor = preferences.edit()
            val gson = Gson()
            val json = gson.toJson(value)
            prefsEditor.putString(key, json)
            prefsEditor.commit()
            prefsEditor.apply()
        }

        fun <T> getModelPreferences(context: Context,key: String, objectClass: Class<T>): Any? {
            val preferences = context.getSharedPreferences(sharedprefernce_key,mode)
            val prefsEditor = preferences.edit()
            val gson = Gson()
            val json = preferences.getString(key, "")
            return if (!TextUtils.isEmpty(json)) {
                gson.fromJson(json, objectClass)
            }
            else null
        }



//
//
//        fun getLsi
//
//        fun getListPreference(context: Context,key: String): String? {
//
//            val appSharedPrefs = PreferenceManager
//                .getDefaultSharedPreferences(context)
//            val gson = Gson()
//            val json = appSharedPrefs.getString(key, "")
//
//            return json
//
//        }
    }
}