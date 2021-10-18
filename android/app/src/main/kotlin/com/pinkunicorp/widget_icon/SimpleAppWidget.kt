package com.pinkunicorp.widget_icon

import android.app.Activity
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Color
import android.graphics.Matrix
import android.media.ExifInterface
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.widget.RemoteViews
import androidx.core.content.FileProvider
import java.io.File
import java.io.FileInputStream
import java.io.IOException
import java.net.MalformedURLException


/**
 * Implementation of App Widget functionality.
 */
class SimpleAppWidget : AppWidgetProvider() {

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        // There may be multiple widgets active, so update all of them
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    private fun updateAppWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {

        val sharedPref = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        var name = sharedPref.getString("flutter.name_$appWidgetId", "")
        var textColor = sharedPref.getString("flutter.text_color_$appWidgetId", null) ?: "#ffffffff"
        var type = sharedPref.getString("flutter.type_$appWidgetId", "0")?.toInt() ?: 0
        var path = sharedPref.getString("flutter.path_$appWidgetId", "")
        if (name.isNullOrBlank() && path.isNullOrBlank()) {
            name = sharedPref.getString("flutter.name_new", "")
            textColor = sharedPref.getString("flutter.text_color_new", null) ?: "#ffffffff"
            type = sharedPref.getString("flutter.type_new", "0")?.toInt() ?: 0
            path = sharedPref.getString("flutter.path_new", "")
            if (name.isNullOrBlank() && path.isNullOrBlank()) {
                return
            }
            saveWidgetData(context, sharedPref, appWidgetId, name!!, textColor, type, path!!)
        }
        // Construct the RemoteViews object
        val views = RemoteViews(context.packageName, R.layout.simple_app_widget)

        try {
            initWidget(views, name, textColor, type, path)

            views.setOnClickPendingIntent(R.id.root, getPendingIntent(context, type, path!!))

        } catch (e: MalformedURLException) {
            e.printStackTrace()
        } catch (e: IOException) {
            e.printStackTrace()
        }

        // Instruct the widget manager to update the widget
        appWidgetManager.updateAppWidget(appWidgetId, views)
    }

    private fun getPendingIntent(context: Context, type: Int, path: String): PendingIntent {
        return if (type == 0) {
            val file = File(path)
            val pathFile = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) FileProvider.getUriForFile(context, context.packageName.toString() + ".provider", file) else Uri.fromFile(file)
            val intent = Intent(Intent.ACTION_VIEW)
            intent.setDataAndType(pathFile, "image/*")
            intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            PendingIntent.getActivity(context, 0, intent, android.app.PendingIntent.FLAG_UPDATE_CURRENT)
        } else {
            var newPath = path
            if (!path.startsWith("http://") && !path.startsWith("https://")) {
                newPath = "http://" + path
            }
            val intent = Intent(Intent.ACTION_VIEW, Uri.parse(newPath))
            PendingIntent.getActivity(context, 0, intent, PendingIntent.FLAG_CANCEL_CURRENT)
        }
    }

    private fun saveWidgetData(context: Context, prefs: SharedPreferences, widgetId: Int, name: String, textColor: String, type: Int, path: String) {
        val editor = prefs.edit()
        val list = prefs.getString("flutter.list_ids", null) ?: ""
        list.split(",").filter { it.isNotEmpty() }.toMutableList().let { ids ->
            ids.add(widgetId.toString())
            editor.putString("flutter.list_ids", ids.joinToString(","))
        }
        editor.putString("flutter.name_$widgetId", name)
        editor.putString("flutter.text_color_$widgetId", textColor)
        editor.putString("flutter.type_$widgetId", type.toString())
        editor.putString("flutter.path_$widgetId", path)
        editor.remove("flutter.name_new")
        editor.remove("flutter.text_color_new")
        editor.remove("flutter.type_new")
        editor.remove("flutter.path_new")
        editor.apply()

        Handler(Looper.getMainLooper()).postDelayed({
            val i = Intent(context, MainActivity::class.java)
            i.putExtra(MainActivity.PARAM_WIDGET_CREATED, true)
            i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            context.startActivity(i)
        }, 1000)
    }

    override fun onDeleted(context: Context, appWidgetIds: IntArray) {
        val sharedPref = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val editor = sharedPref.edit()
        val list = sharedPref.getString("flutter.list_ids", null)
        list?.split(",")?.filter { it.isNotEmpty() }?.toMutableList()?.let { ids ->
            appWidgetIds.map { it.toString() }.forEach {
                ids.remove(it)
            }
            editor.putString("flutter.list_ids", ids.joinToString(","))
        }
        for (appWidgetId in appWidgetIds) {
            editor.remove("flutter.name_$appWidgetId")
            editor.remove("flutter.path_$appWidgetId")
        }
        editor.apply()
    }

    companion object {
        const val WIDGET_NAME = "WIDGET_NAME"
        const val WIDGET_TEXT_COLOR = "WIDGET_TEXT_COLOR"
        const val WIDGET_TYPE = "WIDGET_TYPE"
        const val WIDGET_PATH = "WIDGET_PATH"
        const val BROADCAST_ID = 123456

        private fun initWidget(views: RemoteViews, name: String?, textColor: String, type: Int, path: String?) {
            if (type == 0) {
                val file = File(path!!)
                var image = BitmapFactory.decodeStream(FileInputStream(file))

                val exif = ExifInterface(file.absolutePath)
                val orientation: Int = exif.getAttributeInt(ExifInterface.TAG_ORIENTATION, 1)
                Log.d("EXIF", "Exif: $orientation")
                val matrix = Matrix()
                if (orientation == 6) {
                    matrix.postRotate(90f)
                } else if (orientation == 3) {
                    matrix.postRotate(180f)
                } else if (orientation == 8) {
                    matrix.postRotate(270f)
                }

                image = if (image.width >= image.height) {
                    Bitmap.createBitmap(
                        image,
                        image.width / 2 - image.height / 2,
                        0,
                        image.height,
                        image.height,
                        matrix,
                        true
                    )
                } else {
                    Bitmap.createBitmap(
                        image,
                        0,
                        image.height / 2 - image.width / 2,
                        image.width,
                        image.width,
                        matrix,
                        true
                    )
                }
                views.setImageViewBitmap(R.id.ivIcon, resize(image, 200, 200))
            } else {
                views.setImageViewResource(R.id.ivIcon, R.drawable.ic_url)
            }
            views.setTextColor(R.id.tvName, Color.parseColor(textColor))
            views.setTextViewText(R.id.tvName, name)
        }

        private fun resize(image: Bitmap, maxWidth: Int, maxHeight: Int): Bitmap {
            var resizedImage = image
            return if (maxHeight > 0 && maxWidth > 0) {
                val width = image.width
                val height = image.height
                val ratioBitmap = width.toFloat() / height.toFloat()
                val ratioMax = maxWidth.toFloat() / maxHeight.toFloat()
                var finalWidth = maxWidth
                var finalHeight = maxHeight
                if (ratioMax > ratioBitmap) {
                    finalWidth = (maxHeight.toFloat() * ratioBitmap).toInt()
                } else {
                    finalHeight = (maxWidth.toFloat() / ratioBitmap).toInt()
                }
                resizedImage = Bitmap.createScaledBitmap(image, finalWidth, finalHeight, true)
                resizedImage
            } else {
                resizedImage
            }
        }

        fun getRemoteViews(context: Context, name: String, textColor: String, type: Int, path: String): RemoteViews {
            val remoteViews = RemoteViews(context.packageName, R.layout.simple_app_widget_preview)
            initWidget(remoteViews, name, textColor, type, path)
            return remoteViews
        }

        fun getPendingIntent(context: Context, widgetName: String, textColor: String, type: Int, widgetPath: String): PendingIntent {
            val callbackIntent = Intent(context, SimpleAppWidget::class.java)
            val bundle = Bundle()
            bundle.putString(WIDGET_NAME, widgetName)
            bundle.putString(WIDGET_TEXT_COLOR, textColor)
            bundle.putInt(WIDGET_TYPE, type)
            bundle.putString(WIDGET_PATH, widgetPath)
            callbackIntent.putExtras(bundle)
            return PendingIntent.getBroadcast(context, BROADCAST_ID, callbackIntent, PendingIntent.FLAG_UPDATE_CURRENT)
        }
    }
}