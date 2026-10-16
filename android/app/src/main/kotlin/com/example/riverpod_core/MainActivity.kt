package com.example.riverpod_core

import android.app.AlarmManager
import android.content.Context
import android.os.Build
import android.view.WindowManager
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// local_auth needs a FragmentActivity for the biometric prompt.
class MainActivity: FlutterFragmentActivity() {
    private val CHANNEL = "flutter_alarm_check"
    private val SECURE_CHANNEL = "riverpod_core/secure_screen"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // FLAG_SECURE blocks screenshots, screen recording and the app
        // switcher thumbnail while it is set.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SECURE_CHANNEL).setMethodCallHandler {
            call, result ->
            if (call.method == "setSecure") {
                val secure = call.arguments as? Boolean ?: false
                if (secure) {
                    window.setFlags(WindowManager.LayoutParams.FLAG_SECURE, WindowManager.LayoutParams.FLAG_SECURE)
                } else {
                    window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                }
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            if (call.method == "canScheduleExactAlarms") {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                    val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
                    result.success(alarmManager.canScheduleExactAlarms())
                } else {
                    // Below Android 12, exact alarms are allowed by default/permission is not runtime revoked usually
                    result.success(true)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
