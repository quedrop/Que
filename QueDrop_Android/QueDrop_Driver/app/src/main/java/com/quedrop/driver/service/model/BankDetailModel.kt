package com.quedrop.driver.service.model

import java.io.Serializable

data class BankDetailModel(
    var bank_id: Int,
    var bank_name: String,
    var bank_logo: String

) : Serializable
