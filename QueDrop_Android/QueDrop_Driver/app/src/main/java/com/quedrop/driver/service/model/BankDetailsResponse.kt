package com.quedrop.driver.service.model

import com.google.gson.annotations.SerializedName
import java.io.Serializable


class BankDetailsResponse {

    @SerializedName("status")
    val status: Boolean? = null

    @SerializedName("message")
    val message: String? = null

    @SerializedName("data")
    val bankData: BankData? = null
}

class BankData {
    @SerializedName("bank_details")
    val bankDetails: MutableList<BankDetails>? = null
}

class BankDetails :Serializable{

    @SerializedName("bank_detail_id")
    val bankDetailId: Int? = null

    @SerializedName("bank_id")
    val bankId: Int? = null

    @SerializedName("bank_name")
    val bankName: String? = null

    @SerializedName("bank_logo")
    val bankLogo: String? = null

    @SerializedName("account_type")
    val accountType: String? = null

    @SerializedName("account_number")
    val accountNumber: String? = null

    @SerializedName("ifsc_code")
    val ifsc_code: String? = null

    @SerializedName("other_detail")
    val otherDetail: String? = null

    @SerializedName("is_primary")
    val isPrimary: Int? = null

    private var swipeFromEnd = true

    private val pull = false

    fun isSwipeFromEnd(): Boolean {
        return swipeFromEnd
    }

    fun toggleSwipeFromEnd() {
        swipeFromEnd = !swipeFromEnd
    }

    fun isPull(): Boolean {
        return pull
    }

}
