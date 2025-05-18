package com.example.sustenta_bag_application

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.media.RingtoneManager
import android.os.Build
import android.util.Log
import androidx.core.app.NotificationCompat
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage

class SustentaBagFirebaseMessagingService : FirebaseMessagingService() {
    private val TAG = "FCMService"
    
    override fun onMessageReceived(message: RemoteMessage) {
        Log.d(TAG, "From: ${message.from}")
        Log.d(TAG, "Message received at ${System.currentTimeMillis()}")

        // Always log the notification content for debugging
        if (message.notification != null) {
            Log.d(TAG, "Message Notification Payload - Title: ${message.notification?.title}, Body: ${message.notification?.body}")
            sendNotification(message.notification?.title ?: "SustentaBag", message.notification?.body ?: "Nova notificação recebida")
        }
        
        if (message.data.isNotEmpty()) {
            Log.d(TAG, "Message Data Payload: ${message.data}")
            
            // If there's no notification payload but there is data payload
            if (message.notification == null) {
                val title = message.data["title"] ?: "SustentaBag"
                val body = message.data["body"] ?: "Nova notificação recebida"
                sendNotification(title, body)
            }
        }
        
        // Send broadcast to Flutter
        val title = message.notification?.title ?: message.data["title"] ?: "SustentaBag"
        val body = message.notification?.body ?: message.data["body"] ?: "Nova notificação recebida"
          val intent = Intent("com.example.sustenta_bag_application.NOTIFICATION_RECEIVED")
        intent.setPackage(packageName) // Restringir o broadcast apenas para nosso aplicativo
        intent.putExtra("title", title)
        intent.putExtra("body", body)
        intent.putExtra("timestamp", System.currentTimeMillis())
        sendBroadcast(intent)
        Log.d(TAG, "Broadcast intent sent with title: $title, body: $body")
    }

    override fun onNewToken(token: String) {
        Log.d(TAG, "Refreshed token: $token")
    }
    
    private fun sendNotification(title: String, messageBody: String) {
        val intent = Intent(this, MainActivity::class.java)
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
        intent.putExtra("notification_title", title)
        intent.putExtra("notification_body", messageBody)
        val pendingIntent = PendingIntent.getActivity(
            this, 0, intent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )
        
        val channelId = "sustentabag_notifications_channel"
        val defaultSoundUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
        val notificationBuilder = NotificationCompat.Builder(this, channelId)
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setContentTitle(title)
            .setContentText(messageBody)
            .setAutoCancel(true)
            .setSound(defaultSoundUri)
            .setContentIntent(pendingIntent)
            .setPriority(NotificationCompat.PRIORITY_MAX)

        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        // Since Android Oreo notification channel is needed
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId,
                "SustentaBag Notifications",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Notificações do aplicativo SustentaBag"
                enableLights(true)
                enableVibration(true)
            }
            notificationManager.createNotificationChannel(channel)
        }

        // Use System.currentTimeMillis() to generate unique ID for each notification
        val notificationId = System.currentTimeMillis().toInt() and 0xfffffff
        notificationManager.notify(notificationId, notificationBuilder.build())
        Log.d(TAG, "Notification displayed with ID: $notificationId")
    }
}
