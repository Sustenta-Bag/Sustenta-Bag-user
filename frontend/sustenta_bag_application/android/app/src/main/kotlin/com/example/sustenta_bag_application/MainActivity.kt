package com.example.sustenta_bag_application

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.sustenta_bag_application/fcm"
    private val TAG = "MainActivity"
    private var notificationReceiver: BroadcastReceiver? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "isNotificationServiceRunning") {
                result.success(true)
            } else {
                result.notImplemented()
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.d(TAG, "MainActivity onCreate")
        
        // Registrar broadcast receiver para notificações FCM
        registerNotificationReceiver()
        
        // Verificar se a atividade foi iniciada por uma notificação
        handleNotificationIntent(intent)
    }
    
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        // Verificar se a intent vem de uma notificação
        handleNotificationIntent(intent)
    }
    
    private fun handleNotificationIntent(intent: Intent) {
        val title = intent.getStringExtra("notification_title")
        val body = intent.getStringExtra("notification_body")
        
        if (title != null && body != null) {
            Log.d(TAG, "Notification clicked: $title - $body")
            // Aqui você poderia enviar essas informações para o Flutter via MethodChannel
        }
    }
      private fun registerNotificationReceiver() {
        notificationReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context, intent: Intent) {
                val title = intent.getStringExtra("title") ?: "SustentaBag"
                val body = intent.getStringExtra("body") ?: "Nova notificação recebida"
                val timestamp = intent.getLongExtra("timestamp", System.currentTimeMillis())
                
                Log.d(TAG, "Received notification broadcast: $title - $body")
                
                // Enviar para o Flutter via MethodChannel
                if (flutterEngine != null) {
                    MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL)
                        .invokeMethod("onNotificationReceived", 
                            mapOf(
                                "title" to title,
                                "body" to body,
                                "timestamp" to timestamp
                            )
                        )
                }
            }
        }
        
        val filter = IntentFilter("com.example.sustenta_bag_application.NOTIFICATION_RECEIVED")
        
        // Em Android 12 (API 31) e superior, precisamos especificar RECEIVER_EXPORTED ou RECEIVER_NOT_EXPORTED
        // Como esse receiver é apenas para comunicação interna do app, usamos NOT_EXPORTED
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.S) {
            registerReceiver(notificationReceiver, filter, android.content.Context.RECEIVER_NOT_EXPORTED)
        } else {
            registerReceiver(notificationReceiver, filter)
        }
        
        Log.d(TAG, "Notification receiver registered")
    }
    
    override fun onDestroy() {
        // Desregistrar o receiver ao destruir a activity
        if (notificationReceiver != null) {
            unregisterReceiver(notificationReceiver)
            notificationReceiver = null
            Log.d(TAG, "Notification receiver unregistered")
        }
        super.onDestroy()
    }
}
