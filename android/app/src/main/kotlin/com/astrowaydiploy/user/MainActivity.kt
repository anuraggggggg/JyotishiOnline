package com.astrowaydiploy.user
import io.flutter.embedding.android.FlutterActivity
import androidx.annotation.NonNull
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.os.Build.VERSION
import android.os.Build.VERSION_CODES
import android.app.NotificationManager;
import android.app.NotificationChannel;
import android.net.Uri;
import android.media.AudioAttributes;
import android.content.ContentResolver;
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.util.Log
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import com.hiennv.flutter_callkit_incoming.CallkitConstants
import com.otpless.otplessflutter.OtplessFlutterPlugin
class MainActivity: FlutterActivity() {
    private val CHANNEL_NAME = "com.astrowaydiploy.user/channel_test"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val channel = MethodChannel(flutterEngine?.dartExecutor?.binaryMessenger!!, CHANNEL_NAME)
        val appOpenedIntent = intent
        if (appOpenedIntent != null && appOpenedIntent.action == "com.hiennv.flutter_callkit_incoming.ACTION_CALL_ACCEPT") {
            val extras = appOpenedIntent.extras
            if (extras != null) {
                Log.d("CHANNEL_NAME", fromBundle((extras)).toString())
                channel.invokeMethod("CALL_ACCEPTED_INTENT", fromBundle(extras))
            }
        } else {
            channel.invokeMethod("CHAT_ACCEPTED_INTENT", null)
        }
    }
    private fun fromBundle(bundle: Bundle): HashMap<String, Any?> {
        var data: HashMap<String, Any?> = HashMap()
        val extraCallkitData = bundle.getBundle("EXTRA_CALLKIT_CALL_DATA") ?: return data
        data = extraCallkitData.getSerializable(CallkitConstants.EXTRA_CALLKIT_EXTRA) as HashMap<String, Any?>
        return data
    }
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_NAME).setMethodCallHandler {
            call, result ->
            Log.e("TAG", "channel name is ${call.method}")
            if (call.method == "mynotichannel"){
                Log.e("TAG", "argument start: ${call.arguments}")
                val argData = call.arguments as java.util.HashMap<String, String>
                val completed = createNotificationChannel(argData)
                Log.e("TAG", "completed: $completed")
                if (completed == true){
                    Log.e("TAG", "in true part")
                    result.success(completed)
                }
                else{
                    Log.e("TAG", "in false part")
                    result.error("Error Code", "Error Message", null)
                }
            }else if (call.method == "activeCalls") {
                result.success(getDataActiveCallsForFlutter(this))
            }

            else {
                result.notImplemented()
            }
        }
    }

    fun getDataActiveCallsForFlutter(context: Context?): ArrayList<Map<String, Any?>> {
        val json = getString(context, "ACTIVE_CALLS", "[]")
        return Gson().fromJson(json, object : TypeToken<ArrayList<Map<String, Any?>>>() {}.type)
    }

    private fun getString(context: Context?, key: String, defaultValue: String): String {
        val sharedPreferences = context?.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        return sharedPreferences?.getString(key, defaultValue) ?: defaultValue
    }


    private fun createNotificationChannel(mapData: HashMap<String,String>): Boolean {
        val completed: Boolean
        if (VERSION.SDK_INT >= VERSION_CODES.O) {
            // Create the NotificationChannel
            val id = mapData["id"]
            val name = mapData["name"]
            val descriptionText = mapData["description"]
            val sound = "app_sound"
            val importance = NotificationManager.IMPORTANCE_HIGH
            val mChannel = NotificationChannel(id, name, importance)
            mChannel.description = descriptionText
            val soundUri = Uri.parse(ContentResolver.SCHEME_ANDROID_RESOURCE + "://"+ applicationContext.packageName + "/raw/app_sound");
            val att = AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_NOTIFICATION)
                    .setContentType(AudioAttributes.CONTENT_TYPE_SPEECH)
                    .build();
            mChannel.setSound(soundUri, att)
            // Register the channel with the system; you can't change the importance
            // or other notification behaviors after this
            val notificationManager = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(mChannel)
            completed = true
        }
        else{
            completed = false
        }
        return completed
    }
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        val plugin = flutterEngine?.plugins?.get(OtplessFlutterPlugin::class.java)
        if (plugin is OtplessFlutterPlugin) {
            plugin.onNewIntent(intent)
        }
    }
    override fun onBackPressed() {
        val plugin = flutterEngine?.plugins?.get(OtplessFlutterPlugin::class.java)
        if (plugin is OtplessFlutterPlugin) {
            if (plugin.onBackPressed()) return
        }
        super.onBackPressed()
    }

}

