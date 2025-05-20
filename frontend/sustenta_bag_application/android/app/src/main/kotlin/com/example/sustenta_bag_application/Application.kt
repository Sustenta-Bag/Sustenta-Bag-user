package com.example.sustenta_bag_application

import io.flutter.app.FlutterApplication
import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import android.content.Context

class Application : FlutterApplication() {
    override fun onCreate() {
        super.onCreate()
        
        // Criar o canal de notificação para Android O+
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channelId = "sustentabag_notifications_channel"
            val channelName = "SustentaBag Notifications"
            val channelDescription = "Notificações do aplicativo SustentaBag"
            val importance = NotificationManager.IMPORTANCE_HIGH
            
            val channel = NotificationChannel(channelId, channelName, importance).apply {
                description = channelDescription
                enableLights(true)
                enableVibration(true)
            }
            
            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }
}
