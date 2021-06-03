package com.quedrop.driver.utils;

import android.app.ActivityManager;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.RectF;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.widget.ImageView;
import android.widget.Toast;

import com.bumptech.glide.Glide;

import java.io.File;
import java.util.List;

import okhttp3.MediaType;
import okhttp3.MultipartBody;
import okhttp3.RequestBody;

import static android.content.Context.CONNECTIVITY_SERVICE;

public class Utility {


    public static MultipartBody.Part getFileBody(String key, String filePath) {

        File file = new File(filePath);
        RequestBody fileReqBody = RequestBody.create(MediaType.parse("image/*"), file);
        return MultipartBody.Part.createFormData(key, file.getName(), fileReqBody);

    }

    public static Bitmap createDrawableNode(String strText) {
        Paint mTextPaint = new Paint();
        mTextPaint.setColor(Color.WHITE);
        mTextPaint.setTextAlign(Paint.Align.CENTER);
        mTextPaint.setDither(true);
        mTextPaint.setAntiAlias(true);
        mTextPaint.setFilterBitmap(true);
        mTextPaint.setTextSize(38);
        float vSize = 56;
        Bitmap bitmap = Bitmap.createBitmap((int) vSize, (int) vSize, Bitmap.Config.ARGB_8888);
        Canvas canvas = new Canvas(bitmap);
        Paint paint = new Paint();
        paint.setStyle(Paint.Style.FILL);
        paint.setColor(Color.BLACK);
        paint.setAntiAlias(true);
        RectF rectF = new RectF(0, 0, canvas.getWidth(), canvas.getHeight());

        int cornersRadius = 40;
        canvas.drawRoundRect(rectF, cornersRadius, cornersRadius, paint);
        int xPos = (canvas.getWidth() / 2);
        int yPos = (int) ((canvas.getHeight() / 2) - ((mTextPaint.descent() + mTextPaint.ascent()) / 2));
        canvas.drawText(strText, xPos, yPos, mTextPaint);
        return bitmap;
    }


    public static void toastLong(Context mContext, String message) {

        Toast.makeText(mContext, "" + message, Toast.LENGTH_SHORT).show();
    }

    public static void loadGlideImage(Context context, String path, int placeHolder, ImageView imageView) {
        try {
            if (!path.isEmpty()) {
                Glide.with(context)
                        .load(path)
                        .placeholder(placeHolder)
                        .circleCrop()
                        .into(imageView);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

    }


    public static boolean isNetworkAvailable(Context context) {
        ConnectivityManager cm = (ConnectivityManager) context.getSystemService(CONNECTIVITY_SERVICE);
        assert cm != null;
        NetworkInfo networkInfo = cm.getActiveNetworkInfo();
        return networkInfo != null && networkInfo.isConnected();
    }

    public static boolean isAppOnForeground(Context context, String appPackageName) {
        ActivityManager activityManager = (ActivityManager) context.getSystemService(Context.ACTIVITY_SERVICE);
        List<ActivityManager.RunningAppProcessInfo> appProcesses = activityManager.getRunningAppProcesses();
        if (appProcesses == null) {
            return false;
        }
        final String packageName = appPackageName;
        for (ActivityManager.RunningAppProcessInfo appProcess : appProcesses) {
            if (appProcess.importance == ActivityManager.RunningAppProcessInfo.IMPORTANCE_FOREGROUND && appProcess.processName.equals(packageName)) {
                //                Log.e("app",appPackageName);
                return true;
            }
        }
        return false;
    }


}


