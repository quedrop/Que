package com.quedrop.customer.model

import androidx.room.ColumnInfo
import androidx.room.Entity
import androidx.room.PrimaryKey

data class AllCategories(
    var secret_key :String ,
    var access_key :String

)

data class Categories(
    var service_category_id:Int,
    var service_category_name:String,
    var service_category_image:String,
    var service_category_description:String
)

data class GetNotes(
    var secret_key :String,
    var access_key :String
)

@Entity(tableName = "NotesResponse")
data class NotesResponse(

    @PrimaryKey(autoGenerate = true)
    var id:Int,

    @ColumnInfo(name = "term_note_id")
    var term_note_id:String,

    @ColumnInfo(name = "note")
    var note:String,

    @ColumnInfo(name = "note_type")
    var note_type:String
)
