package com.quedrop.driver.api.authentication

import com.quedrop.driver.prefs.LocalPrefs
import com.quedrop.driver.service.model.User
import com.google.gson.Gson
import timber.log.Timber

class LoggedInUserCache(private val localPrefs: LocalPrefs) {

    private var qurDropUser: User? = null

    enum class PreferenceKey(val identifier: String) {
        LOGGED_IN_USER_JSON_KEY("loggedInUser"),
        LOGGED_IN_USER_CURRENT_ORDER_ID("orderId"),
    }

    init {
        loadLoggedInUserFromLocalPrefs()
    }

    private var loggedInUserCurrentOrderId: String?
        get() {
            return localPrefs.getString(PreferenceKey.LOGGED_IN_USER_CURRENT_ORDER_ID.identifier, null)
        }
        set(value) {
            localPrefs.putString(PreferenceKey.LOGGED_IN_USER_CURRENT_ORDER_ID.identifier, value)
        }


    fun setCurrentOrderId(orderId: String?) {
        loggedInUserCurrentOrderId = orderId
    }


    fun getCurrentOrderId(): String? {
        return loggedInUserCurrentOrderId
    }

    private fun loadLoggedInUserFromLocalPrefs() {
        val userJsonString = localPrefs.getString(PreferenceKey.LOGGED_IN_USER_JSON_KEY.identifier, null)
        var qurDropUser: User? = null

        if (userJsonString != null) {
            try {
                qurDropUser= Gson().fromJson(userJsonString, User::class.java)
            } catch (e: Exception) {
                Timber.e(e, "Failed to parse logged in user from json string")
            }
        }
        this.qurDropUser= qurDropUser
    }

    fun setLoggedInUser(genieUser: User?) {
        localPrefs.putString(PreferenceKey.LOGGED_IN_USER_JSON_KEY.identifier, Gson().toJson(genieUser))
        loadLoggedInUserFromLocalPrefs()
    }

    fun getLoggedInUser(): User? {
        return qurDropUser ?: return null
    }

    fun clearLoggedInUserLocalPrefs() {
        clearUserPreferences()
    }

    /**
     * Clear previous user preferences, if the current logged in user is different
     */
    private fun clearUserPreferences() {
        try {
            qurDropUser= null
            for (preferenceKey in PreferenceKey.values()) {
                localPrefs.removeValue(preferenceKey.identifier)
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
}
