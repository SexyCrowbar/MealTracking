package com.mealtracker.mealtracker

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import es.antonborri.home_widget.HomeWidgetProvider

class MealTrackerWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: android.content.SharedPreferences,
    ) {
        appWidgetIds.forEach { id ->
            val views = RemoteViews(context.packageName, R.layout.meal_tracker_widget)

            val remaining = widgetData.getInt("widget_remaining_kcal", -1)
            val target = widgetData.getInt("widget_target_kcal", -1)
            val consumed = widgetData.getInt("widget_consumed_kcal", -1)
            val caption = widgetData.getString("widget_caption", "kcal remaining")
                ?: "kcal remaining"
            val appLabel = widgetData.getString("widget_app_label", "MealTracker")
                ?: "MealTracker"

            views.setTextViewText(R.id.widget_app_label, appLabel)
            views.setTextViewText(R.id.widget_caption, caption)

            if (target > 0) {
                val shown = if (remaining < 0) 0 else remaining
                views.setTextViewText(R.id.widget_remaining_kcal, shown.toString())
                views.setTextViewText(
                    R.id.widget_subline,
                    "${if (consumed < 0) 0 else consumed} / $target",
                )
            } else {
                views.setTextViewText(R.id.widget_remaining_kcal, "—")
                views.setTextViewText(R.id.widget_subline, "")
            }

            val launchIntent = context.packageManager
                .getLaunchIntentForPackage(context.packageName)
            if (launchIntent != null) {
                launchIntent.flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or
                    Intent.FLAG_ACTIVITY_SINGLE_TOP
                val pi = PendingIntent.getActivity(
                    context,
                    0,
                    launchIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
                )
                views.setOnClickPendingIntent(R.id.widget_root, pi)
            }

            appWidgetManager.updateAppWidget(id, views)
        }
    }
}
