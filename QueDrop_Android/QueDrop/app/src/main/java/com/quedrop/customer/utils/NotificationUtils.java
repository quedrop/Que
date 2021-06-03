package com.quedrop.customer.utils;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.content.res.Resources;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;

import androidx.annotation.RequiresApi;
import androidx.core.app.NotificationCompat;

import com.quedrop.customer.R;
import com.quedrop.customer.ui.splash.SplashActivity;
import com.google.firebase.messaging.RemoteMessage;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

import org.json.JSONObject;

import java.util.Map;


public class NotificationUtils {

    private Context mContext;
    private NotificationManager notificationManager;
    private NotificationCompat.Builder notificationBuilder;
    private Notification notification;
    private Resources mResources;

    public static final int NOTIFY_ACTIVITY_ID_SERVICE = 1001;

    private String channelId = "";

    public PendingIntent launchIntent;

    public NotificationUtils(Context context) {
        this.mContext = context;
        notificationManager = (NotificationManager) mContext.getSystemService(Context.NOTIFICATION_SERVICE);
        this.mResources = mContext.getResources();
        channelId = Build.VERSION.SDK_INT >= Build.VERSION_CODES.O ? createNotificationChannel(notificationManager) : "";
        notificationBuilder = new NotificationCompat.Builder(mContext, channelId);

    }


    @RequiresApi(Build.VERSION_CODES.O)
    private String createNotificationChannel(NotificationManager notificationManager) {
        String channelId = "quedrop_service_customer_channel_id";
        String channelName = "QueDrop Customer Notification";
        NotificationChannel channel = new NotificationChannel(channelId, channelName, NotificationManager.IMPORTANCE_HIGH);
        channel.setImportance(NotificationManager.IMPORTANCE_DEFAULT);
        channel.enableVibration(true);
        channel.setLightColor(Color.GREEN);
        channel.setVibrationPattern(new long[]{100, 200, 300, 400, 500, 400, 300, 200, 400});
        channel.setLockscreenVisibility(Notification.VISIBILITY_PRIVATE);
        notificationManager.createNotificationChannel(channel);
        return channelId;
    }

    public void startNotification(RemoteMessage remoteMessage) {

        try {

            JsonObject jsonObject = convertRemoteMessage(remoteMessage);
            Log.i(ConstantUtils.NOTICES, "onMessageServiceY==>" + jsonObject.toString());


            String title = String.valueOf(jsonObject.get("title"));
            String message = String.valueOf(jsonObject.get("body"));

            String fmtTitle = title.replace("\"", "");
            String fmtMessage = message.replace("\"", "");
//
//        {"customer_id":205,"notification_type":1,"first_name":"zp","body":"You have received new order request.","title":"New Order Request","order_id":819,"order_drivers":"125,224,196,215,195","last_name":"Patel"}

            //sendIntentData(jsonObject.toString());
            Intent resultIntent = new Intent(mContext, SplashActivity.class);
            resultIntent.putExtra("remote_message_data", jsonObject.toString());
            PendingIntent launchIntent = PendingIntent.getActivity(mContext, 100, resultIntent, PendingIntent.FLAG_UPDATE_CURRENT);


            notification = notificationBuilder.setOngoing(false)
                    .setSmallIcon(R.drawable.ic_app_icon)
                    .setContentTitle(fmtTitle)
                    .setContentText(fmtMessage)
                    .setPriority(NotificationCompat.PRIORITY_DEFAULT)
                    .setCategory(NotificationCompat.CATEGORY_SERVICE)
                    .setAutoCancel(true)
                    .setContentIntent(launchIntent)
                    .setTicker(fmtMessage)
                    .setDefaults(Notification.DEFAULT_ALL)
                    .setVibrate(new long[]{100, 200, 300, 400, 500, 400, 300, 200, 400})
                    .build();

            notification = notificationBuilder.setOngoing(false)
                    .setSmallIcon(R.drawable.ic_app_trans)
                    .setColor(mResources.getColor(R.color.colorThemeGreen))
                    .setContentTitle(fmtTitle)
                    .setContentText(fmtMessage)
                    .setPriority(NotificationCompat.PRIORITY_DEFAULT)
                    .setCategory(NotificationCompat.CATEGORY_SERVICE)
                    .setAutoCancel(true)
                    .setContentIntent(launchIntent)
                    .setTicker(fmtMessage)
                    .setDefaults(Notification.DEFAULT_ALL)
                    .setVibrate(new long[]{100, 200, 300, 400, 500, 400, 300, 200, 400})
                    .build();

            notificationManager.notify(NOTIFY_ACTIVITY_ID_SERVICE, notification);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }


    public void cancelNotification(int cancelId) {
        if (notificationManager != null) {
            notificationManager.cancel(cancelId);
        }
    }


    private Bitmap getLargeIconBitmap(int iconDrawable) {
        if (iconDrawable == 0) return null;
        Bitmap largeIcon = BitmapFactory.decodeResource(mResources, iconDrawable);
        int height = (int) mResources.getDimension(android.R.dimen.notification_large_icon_height);
        int width = (int) mResources.getDimension(android.R.dimen.notification_large_icon_width);
        return Bitmap.createScaledBitmap(largeIcon, width, height, false);
    }

    public JsonObject convertRemoteMessage(RemoteMessage remoteMessage) {
        JsonObject jsonObject = new JsonObject(); // com.google.gson.JsonObject
        JsonParser jsonParser = new JsonParser(); // com.google.gson.JsonParser
        Map<String, String> map = remoteMessage.getData();
        String valData;

        for (String mykey : map.keySet()) {
            valData = map.get(mykey);
            try {
                jsonObject.add(mykey, jsonParser.parse(valData));
            } catch (Exception e) {
                jsonObject.addProperty(mykey, valData);
            }
        }
        return jsonObject;
    }

    public static String convertBundleToJsonObject(Bundle bundle) {
        JSONObject jsonObject = new JSONObject();
        for (String key : bundle.keySet()) {
            String value = bundle.getString(key);
            try {
                jsonObject.put(key, value);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        Log.e("jsonObject", " bundlyo ==>" + jsonObject);
        return jsonObject.toString();
    }

}
