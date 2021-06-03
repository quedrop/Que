package com.quedrop.customer.db

import androidx.room.*
import com.quedrop.customer.model.NotesResponse

@Dao
public interface NotesDao {


        @Query("SELECT * FROM NotesResponse")
        fun getNotes():MutableList<NotesResponse>

         @Insert
        fun insertNotes(notesList: MutableList<NotesResponse>)

}