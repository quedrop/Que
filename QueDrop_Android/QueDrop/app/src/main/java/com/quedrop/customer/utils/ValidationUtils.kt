package com.quedrop.customer.utils

import java.util.regex.Matcher
import java.util.regex.Pattern


class ValidationUtils {

    companion object {

//        fun getTimeZOne(address: String):String{
//
//
//            val calender = Calendar.getInstance()
//            val timeZone = calender.getTimeZone()
//
//            return timeZone.getDisplayName()
//
//
//        }

        fun isEmailValid(email: String?): Boolean {
            val pattern: Pattern
            val matcher: Matcher
            val EMAIL_PATTERN =
                "^[_A-Za-z0-9-]+(\\.[_A-Za-z0-9-]+)*@[A-Za-z0-9]+(\\.[A-Za-z0-9]+)*(\\.[A-Za-z]{2,})$"
            pattern = Pattern.compile(EMAIL_PATTERN)
            matcher = pattern.matcher(email)
            return matcher.matches()
        }

        fun isValidMobile(phone: String?): Boolean {
            return if (phone != null && !Pattern.matches("[a-zA-Z]+", phone)) {
                phone.length > 6 && phone.length <= 13
            } else false
        }

        fun isCheckUrlOrNot(stringUrl:String):Boolean{
            val URL_REGEX =
                "^((https?|ftp)://|(www|ftp)\\.)?[a-z0-9-]+(\\.[a-z0-9-]+)+([/?].*)?$"

            val p = Pattern.compile(URL_REGEX)
            val m =
                p.matcher(stringUrl) //replace with string to compare

            return m.find()
        }


        fun isValidPassword(password: String): Boolean {
            val matcher = Pattern.compile("((?=.*[a-z])(?=.*\\d)(?=.*[A-Z])(?=.*[@#$%!]).{4,20})")
                .matcher(password)
            return matcher.matches()
        }

//        fun isValidMobile(phone: String?): Boolean {
//            return if (phone != null && !Pattern.matches("[a-zA-Z]+", phone)) {
//                phone.length in 6..20
//            } else false
//        }




//        fun showKeyboard() {
//            val inputMethodManager =
//                getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
//            inputMethodManager.toggleSoftInput(InputMethodManager.SHOW_FORCED, 0)
//        }
//
//        fun closeKeyboard() {
//            val inputMethodManager =
//                getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
//            inputMethodManager.toggleSoftInput(InputMethodManager.HIDE_IMPLICIT_ONLY, 0)
//        }


    }
}