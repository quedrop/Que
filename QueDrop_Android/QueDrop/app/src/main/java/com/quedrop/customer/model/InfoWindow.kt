package com.quedrop.customer.model

data class InfoWindow(
    var storeId:Int,
    var image:String,
    var title:String,
    var address: String,
    var distance:String,
    var time:String,
    var latitude:String,
    var longitude:String,
    var schedule: ArrayList<Schedule>
)


data class InfoWindowForPoly(
    var distance:String,
    var time:String,
    var latitude: String,
    var longitude: String
)

data class InfoWindowMain  (val distance : String, val time: String)