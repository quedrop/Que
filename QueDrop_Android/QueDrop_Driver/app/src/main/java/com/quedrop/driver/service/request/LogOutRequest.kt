package com.quedrop.driver.service.request

class LogOutRequest (

    var secret_key:String,
    var access_key:String,
    var user_id:Int,
    var device_token:String,
    var device_type:Int
    )