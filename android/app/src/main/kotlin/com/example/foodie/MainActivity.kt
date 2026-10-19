package com.example.foodie

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Application
import android.content.Context
import android.os.Build
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity()

class FoodieApplication : Application() {
    override fun onCreate() {
        super.onCreate()

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                "foodie_high_importance_channel",
                "Foodie Alerts",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Foodie order and flash sale alerts"
                enableVibration(true)
            }

            getSystemService(Context.NOTIFICATION_SERVICE)
                ?.let { service ->
                    (service as NotificationManager).createNotificationChannel(channel)
                }
        }
    }
}
