package com.newpl.star_settlers

import android.content.Intent
import android.net.Uri
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, FEEDBACK_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "send" -> result.success(sendFeedback())
                    else -> result.notImplemented()
                }
            }
    }

    /**
     * 개발자에게 메일로 피드백을 보낸다 (tfkeyboard 와 같은 방식).
     *
     * 본문에 기기·안드로이드·앱 버전을 미리 채워 둔다 — "안 돼요" 한 줄만 오면 재현할 수가 없다.
     * 메일 앱이 없으면 false 를 돌려주고, 화면에서 주소를 알려 준다.
     */
    private fun sendFeedback(): Boolean {
        val appName = applicationInfo.loadLabel(packageManager).toString()
        val info = packageManager.getPackageInfo(packageName, 0)
        @Suppress("DEPRECATION")
        val build = if (Build.VERSION.SDK_INT >= 28) info.longVersionCode else info.versionCode.toLong()
        val body = buildString {
            appendLine()
            appendLine()
            appendLine("----------")
            appendLine("$appName ${info.versionName} ($build)")
            appendLine("${Build.MANUFACTURER} ${Build.MODEL}")
            appendLine("Android ${Build.VERSION.RELEASE} (API ${Build.VERSION.SDK_INT})")
        }
        val subject = "[$appName] 피드백"
        // 제목·본문은 mailto URI 에 실어 보낸다. EXTRA_SUBJECT/EXTRA_TEXT 만 넣으면
        // Gmail 은 받는사람만 채우고 나머지를 버린다. 둘 다 넣어 어느 앱이든 받게 한다.
        val intent = Intent(Intent.ACTION_SENDTO).apply {
            data = Uri.parse(
                "mailto:$FEEDBACK_EMAIL" +
                    "?subject=" + Uri.encode(subject) +
                    "&body=" + Uri.encode(body)
            )
            putExtra(Intent.EXTRA_SUBJECT, subject)
            putExtra(Intent.EXTRA_TEXT, body)
        }
        return runCatching { startActivity(intent) }.isSuccess
    }

    companion object {
        private const val FEEDBACK_CHANNEL = "star_settlers/feedback"
        private const val FEEDBACK_EMAIL = "mkideabox.feedback@gmail.com"
    }
}
