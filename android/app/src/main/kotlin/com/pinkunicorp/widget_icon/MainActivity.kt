package com.pinkunicorp.widget_icon

import android.app.Activity
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


class MainActivity : FlutterActivity() {

    private val CHANNEL = "samples.flutter.dev/widgets"
    private var resultAddWidget: MethodChannel.Result? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "isSupportAddWidget" -> {
                    Log.e("FLUTTER_CHANNEL", "call method: isSupportAddWidget; result: ${isSupportAddWidget()}")
                    result.success(isSupportAddWidget())
                }
                "createWidget" -> {
                    resultAddWidget = result
                    createWidget(call.argument("name") ?: "", call.argument("textColor") ?: "#ffffffff", call.argument("type") ?: 0, call.argument("path") ?: "")
                }
                "setConfigResult" -> {
                    setConfigResult(call.argument("id") ?: "-1")
                    result.success(true)
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

    private fun createWidget(name: String, textColor: String, type: Int, path: String) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val mAppWidgetManager = getSystemService(AppWidgetManager::class.java)
            val myProvider = ComponentName(this, SimpleAppWidget::class.java)
            if (mAppWidgetManager.isRequestPinAppWidgetSupported) {

                val remoteViews = SimpleAppWidget.getRemoteViews(this, name, textColor, type, path)
                val bundle = Bundle()
                bundle.putParcelable(AppWidgetManager.EXTRA_APPWIDGET_PREVIEW, remoteViews)

                mAppWidgetManager.requestPinAppWidget(myProvider, bundle, SimpleAppWidget.getPendingIntent(this, name, textColor, type, path))
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        if (intent.extras?.containsKey(PARAM_WIDGET_CREATED) == true) {
            resultAddWidget?.success(intent.extras?.getBoolean(PARAM_WIDGET_CREATED) == true)
        }
        super.onNewIntent(intent)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (REQUEST_CODE_ADD_WIDGET == requestCode) {
            if (Activity.RESULT_OK == resultCode) {
                resultAddWidget?.success(true)
            } else {
                resultAddWidget?.success(false)
            }
        } else {
            super.onActivityResult(requestCode, resultCode, data)
        }
    }

    fun setConfigResult(id: String) {
        val updateIntent = Intent()
        updateIntent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, id.toInt())
        setResult(Activity.RESULT_OK, updateIntent)
    }

    companion object {
        private const val REQUEST_CODE_ADD_WIDGET = 1001

        const val PARAM_WIDGET_CREATED = "PARAM_WIDGET_CREATED"
    }
}
