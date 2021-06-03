package com.quedrop.customer.model

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

/*data class BankDetails (
    val bank_detail_id: Int = 0,
    val bank_id: Int = 0,
    val bank_name: String,
    val bank_logo: String,
    val account_type: String,
    val account_number: String,
    val ifsc_code: String,
    val other_detail: String? = null,
    val is_primary: Int = 0,

    var swipeFromEnd:Boolean = true,

    val pull:Boolean = false


):Serializable*/

class BankDetails :Serializable{

    @SerializedName("bank_detail_id")
    val bank_detail_id: Int? = 0

    @SerializedName("bank_id")
    val bank_id: Int? = 0

    @SerializedName("bank_name")
    val bank_name: String? = null

    @SerializedName("bank_logo")
    val bank_logo: String? = null

    @SerializedName("account_type")
    val account_type: String? = null

    @SerializedName("account_number")
    val account_number: String? = null

    @SerializedName("ifsc_code")
    val ifsc_code: String? = null

    @SerializedName("other_detail")
    val other_detail: String? = null

    @SerializedName("is_primary")
    val is_primary: Int? = null

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



