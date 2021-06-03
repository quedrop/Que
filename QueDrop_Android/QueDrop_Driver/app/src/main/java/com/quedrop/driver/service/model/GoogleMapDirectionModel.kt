package com.quedrop.driver.service.model

import android.os.Parcelable
import com.google.gson.annotations.SerializedName
import kotlinx.android.parcel.Parcelize



@Parcelize
data class GoogleMapDirection(

    @SerializedName("routes")
    var arrayListRouts: MutableList<Routs>

) : Parcelable

@Parcelize
data class Routs(
    @SerializedName("legs")
    var arrayListLegs: MutableList<Legs>

) : Parcelable

@Parcelize
data class Legs(
    @SerializedName("steps")
    var arrayListSteps: MutableList<Steps>,

    @SerializedName("distance")
    var distance: Distance,

    @SerializedName("duration")
    var duration: Duration

) : Parcelable

@Parcelize
data class Duration(
    @SerializedName("text")
    var text: String = "",

    @SerializedName("value")
    var value: String = ""

) : Parcelable


@Parcelize
data class Distance(
    @SerializedName("text")
    var text: String = "",

    @SerializedName("value")
    var value: String = ""

) : Parcelable


@Parcelize
data class Steps(

    @SerializedName("polyline")
    var polyline: PolyLine = PolyLine()

) : Parcelable


@Parcelize
data class PolyLine(

    @SerializedName("points")
    var points: String? = ""

) : Parcelable