package com.quedrop.customer.ui.verifyphone

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.telephony.SmsMessage

class VerifyOtpReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        // This method is called when the BroadcastReceiver is receiving an Intent broadcast.

        val data = intent.extras

        var pdus: Array<Any?>? = arrayOfNulls(0)
        if (data != null) {
            pdus = data["pdus"] as Array<Any?>?
        }

        if (pdus != null) {
            for (pdu in pdus) {
                val smsMessage: SmsMessage = SmsMessage.createFromPdu(pdu as ByteArray?)
                mListener?.onOTPReceived(smsMessage.messageBody.split(":").toTypedArray()[1].trim())
                break
            }
        }
    }

    companion object {
        private var mListener: OTPListener? = null

        fun bindListener(listener: com.quedrop.customer.ui.verifyphone.OTPListener) {
            mListener = listener
        }

        fun unbindListener() {
            mListener = null
        }
    }
}
