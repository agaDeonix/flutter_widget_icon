package com.pinkunicorp.widget_icon

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel


class MainActivity: FlutterActivity() {

    private val CHANNEL = "samples.flutter.dev/widgets"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
                call, result ->
            when(call.method) {
                "isSupportAddWidget" -> {
                    Log.e("FLUTTER_CHANNEL", "call method: isSupportAddWidget; result: ${isSupportAddWidget()}")
                    result.success(isSupportAddWidget())
                }
                "createWidget" -> {
                    createWidget()
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun isSupportAddWidget(): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val mAppWidgetManager: AppWidgetManager = getSystemService(AppWidgetManager::class.java)
            return mAppWidgetManager.isRequestPinAppWidgetSupported
        }
        return false
    }

    private fun createWidget() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val mAppWidgetManager = getSystemService(AppWidgetManager::class.java)
            val myProvider = ComponentName(this, SimpleAppWidget::class.java)
            val b = Bundle()
            b.putString("ggg", "ggg")
            if (mAppWidgetManager.isRequestPinAppWidgetSupported) {
                val pinnedWidgetCallbackIntent = Intent(this, SimpleAppWidget::class.java)
                val successCallback: PendingIntent = PendingIntent.getBroadcast(this, 0, pinnedWidgetCallbackIntent, 0)
                mAppWidgetManager.requestPinAppWidget(myProvider, b, successCallback)
            }
        }
    }
}
