package com.quedrop.customer.db;

import android.content.Context;

import androidx.room.Database;
import androidx.room.Room;
import androidx.room.RoomDatabase;
import com.quedrop.customer.model.NotesResponse;

@Database(entities = {NotesResponse.class},version = 1, exportSchema = false)
public abstract class AppDatabase extends RoomDatabase {

    private static AppDatabase mINSTANCE;

    public static AppDatabase getAppDatabase(Context context) {
        if (mINSTANCE == null) {
            mINSTANCE =Room.databaseBuilder(context, AppDatabase.class, "demo-database")
                            .allowMainThreadQueries()
                            .build();
        }
        return mINSTANCE;
    }

    public static void destroyInstance() {
        mINSTANCE = null;
    }


    public abstract NotesDao notesDao();

}
