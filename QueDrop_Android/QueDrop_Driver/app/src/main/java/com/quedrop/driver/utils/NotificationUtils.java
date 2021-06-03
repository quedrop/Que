package com.quedrop.driver.utils;

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

import com.quedrop.driver.R;
import com.quedrop.driver.ui.mainActivity.view.MainActivity;
import com.quedrop.driver.ui.orderDetailsFragment.view.OrderDetailActivity;
import com.quedrop.driver.ui.requestDetailsFragment.RequestDetailActivity;
import com.quedrop.driver.ui.splash.SplashActivity;
import com.google.firebase.messaging.RemoteMessage;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.Map;

import static com.quedrop.driver.utils.ConstantUtilsKt.NOTI_LOGS;


public class NotificationUtils {

    private Context mContext;
    private NotificationManager notificationManager;
    private NotificationCompat.Builder notificationBuilder;
    private Notification notification;
    private Resources mResources;

    public static final int NOTIFY_ACTIVITY_ID_SERVICE = 309;

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
        String channelId = "quedrop_service_channel_id";
        String channelName = "QueDrop Notification";
        NotificationChannel channel = new NotificationChannel(channelId, channelName, NotificationManager.IMPORTANCE_HIGH);
        channel.setImportance(NotificationManager.IMPORTANCE_HIGH);
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
            Log.i(NOTI_LOGS, "onMessageServiceY==>" + jsonObject.toString());


            String title = String.valueOf(jsonObject.get("title"));
            String message = String.valueOf(jsonObject.get("body"));

            String fmtTitle = title.replace("\"", "");
            String fmtMessage = message.replace("\"", "");

            //JSONObject jsonObject1=new JSONObject();
            String notificationType= String.valueOf(jsonObject.get("notification_type"));

            if(Integer.parseInt(notificationType)==ENUMNotificationType.ORDER_REQUEST.getPosVal()){
                Intent resultIntent = new Intent(mContext, RequestDetailActivity.class);
                resultIntent.putExtra("remote_message", jsonObject.toString());
                launchIntent = PendingIntent.getActivity(mContext, 100, resultIntent, PendingIntent.FLAG_UPDATE_CURRENT);
            }else {
                Intent resultIntent = new Intent(mContext, SplashActivity.class);
                resultIntent.putExtra("remote_message", jsonObject.toString());
                launchIntent = PendingIntent.getActivity(mContext, 100, resultIntent, PendingIntent.FLAG_UPDATE_CURRENT);
            }

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
        String val;

        for (String mykey : map.keySet()) {
            val = map.get(mykey);
            try {
                jsonObject.add(mykey, jsonParser.parse(val));
            } catch (Exception e) {
                jsonObject.addProperty(mykey, val);
            }
        }
        return jsonObject;
    }

    public void sendIntentData(String remoteMessage) {

        try {
            JSONObject jsonObject = new JSONObject(remoteMessage);
            int notificationType = Integer.parseInt(jsonObject.getString("notification_type"));
            if (notificationType == ENUMNotificationType.ORDER_REQUEST.getPosVal()) {

                Intent intent = new Intent(mContext, RequestDetailActivity.class);
                intent.putExtra("remote_message", remoteMessage);
                // mContext.startActivity(intent);
                launchIntent = PendingIntent.getActivity(mContext, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT);

            } else if (notificationType == ENUMNotificationType.ORDER_DISPATCH.getPosVal()) {
                Intent intent = new Intent(mContext, OrderDetailActivity.class);
                intent.putExtra("remote_message", remoteMessage);
                //mContext.startActivity(intent);
                launchIntent = PendingIntent.getActivity(mContext, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT);

            }
        } catch (JSONException e) {
            e.printStackTrace();
        }

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
