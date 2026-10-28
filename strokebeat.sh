#!/usr/bin/env bash
set -euo pipefail
D="${1:-strokebeat}"
mkdir -p "$D/app/src/main/java/ai/venice/strokebeat"
mkdir -p "$D/app/src/main/res/values" "$D/app/src/main/res/drawable" "$D/app/src/main/res/mipmap-anydpi-v26"
mkdir -p "$D/.github/workflows"
cd "$D"

# ---------------- gradle ----------------
cat > settings.gradle.kts <<'EOF'
pluginManagement {
    repositories { google(); mavenCentral(); gradlePluginPortal() }
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories { google(); mavenCentral() }
}
rootProject.name = "Strokebeat"
include(":app")
EOF

cat > build.gradle.kts <<'EOF'
plugins {
    id("com.android.application") version "8.5.2" apply false
    id("org.jetbrains.kotlin.android") version "1.9.24" apply false
}
EOF

cat > gradle.properties <<'EOF'
org.gradle.jvmargs=-Xmx2048m -Dfile.encoding=UTF-8
android.useAndroidX=true
android.nonTransitiveRClass=true
kotlin.code.style=official
EOF

cat > .gitignore <<'EOF'
.gradle/
build/
local.properties
.idea/
*.apk
*.iml
EOF

cat > app/build.gradle.kts <<'EOF'
plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
}

val appVersion = "1.0"
val keystore = rootProject.file("strokebeat.jks")

android {
    namespace = "ai.venice.strokebeat"
    compileSdk = 34

    defaultConfig {
        applicationId = "ai.venice.strokebeat"
        minSdk = 26
        targetSdk = 34
        versionCode = 1
        versionName = appVersion
    }

    androidResources { noCompress += listOf("mp4", "webm", "mkv") }

    if (keystore.exists()) {
        signingConfigs {
            create("rel") {
                storeFile = keystore
                storePassword = "strokebeat"
                keyAlias = "strokebeat"
                keyPassword = "strokebeat"
            }
        }
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = false
            signingConfig =
                if (keystore.exists()) signingConfigs.getByName("rel")
                else signingConfigs.getByName("debug")
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions { jvmTarget = "17" }

    lint { abortOnError = false; checkReleaseBuilds = false }
}

androidComponents {
    onVariants { variant ->
        variant.outputs.forEach { out -> out.outputFileName.set("Strokebeat-$appVersion.apk") }
    }
}

dependencies {
    implementation("androidx.media3:media3-exoplayer:1.4.1")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.8.1")
}
EOF

# ---------------- manifest + resources ----------------
cat > app/src/main/AndroidManifest.xml <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.WAKE_LOCK" />

    <application
        android:hardwareAccelerated="true"
        android:icon="@mipmap/ic_launcher"
        android:roundIcon="@mipmap/ic_launcher_round"
        android:label="Strokebeat"
        android:theme="@style/AppTheme"
        android:usesCleartextTraffic="true">

        <activity
            android:name=".MainActivity"
            android:configChanges="orientation|screenSize|keyboardHidden|screenLayout|uiMode"
            android:exported="true"
            android:launchMode="singleTop"
            android:screenOrientation="portrait">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
    </application>
</manifest>
EOF

cat > app/src/main/res/values/colors.xml <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="bg">#FF07070C</color>
    <color name="icon_bg">#FF0B0B16</color>
    <color name="accent">#FFFF2E8B</color>
    <color name="hit">#FF00E5FF</color>
</resources>
EOF

cat > app/src/main/res/values/styles.xml <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="AppTheme" parent="@android:style/Theme.Material.NoActionBar.Fullscreen">
        <item name="android:windowBackground">@color/bg</item>
        <item name="android:colorAccent">@color/accent</item>
        <item name="android:windowDrawsSystemBarBackgrounds">true</item>
        <item name="android:statusBarColor">#00000000</item>
        <item name="android:navigationBarColor">#00000000</item>
    </style>
</resources>
EOF

cat > app/src/main/res/drawable/ic_launcher_background.xml <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:aapt="http://schemas.android.com/aapt"
    android:width="108dp" android:height="108dp"
    android:viewportWidth="108" android:viewportHeight="108">
    <path android:pathData="M0,0h108v108h-108z">
        <aapt:attr name="android:fillColor">
            <gradient android:type="radial"
                android:centerX="52" android:centerY="58" android:gradientRadius="76"
                android:startColor="#FF1A1030" android:endColor="#FF07070C" />
        </aapt:attr>
    </path>
</vector>
EOF

cat > app/src/main/res/drawable/ic_launcher_foreground.xml <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="108dp" android:height="108dp"
    android:viewportWidth="108" android:viewportHeight="108">
    <path android:fillColor="#2E00E5FF" android:pathData="M23,27 h14 v54 h-14 z" />
    <path android:fillColor="#FF00E5FF" android:pathData="M27,32 h6 v44 h-6 z" />
    <path android:fillColor="#FFFF2E8B"
        android:pathData="M50,54 m-7,0 a7,7 0 1,0 14,0 a7,7 0 1,0 -14,0" />
    <path android:fillColor="#FFFF5CA8"
        android:pathData="M66,54 m-5,0 a5,5 0 1,0 10,0 a5,5 0 1,0 -10,0" />
    <path android:fillColor="#FFFF8FC4"
        android:pathData="M80,54 m-3.5,0 a3.5,3.5 0 1,0 7,0 a3.5,3.5 0 1,0 -7,0" />
</vector>
EOF

cat > app/src/main/res/drawable/ic_launcher_monochrome.xml <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="108dp" android:height="108dp"
    android:viewportWidth="108" android:viewportHeight="108">
    <path android:fillColor="#FFFFFFFF" android:pathData="M27,32 h6 v44 h-6 z" />
    <path android:fillColor="#FFFFFFFF"
        android:pathData="M50,54 m-7,0 a7,7 0 1,0 14,0 a7,7 0 1,0 -14,0" />
    <path android:fillColor="#FFFFFFFF"
        android:pathData="M66,54 m-5,0 a5,5 0 1,0 10,0 a5,5 0 1,0 -10,0" />
    <path android:fillColor="#FFFFFFFF"
        android:pathData="M80,54 m-3.5,0 a3.5,3.5 0 1,0 7,0 a3.5,3.5 0 1,0 -7,0" />
</vector>
EOF

for f in ic_launcher ic_launcher_round; do
cat > "app/src/main/res/mipmap-anydpi-v26/$f.xml" <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@drawable/ic_launcher_background" />
    <foreground android:drawable="@drawable/ic_launcher_foreground" />
    <monochrome android:drawable="@drawable/ic_launcher_monochrome" />
</adaptive-icon>
EOF
done

# ---------------- kotlin ----------------
cat > app/src/main/java/ai/venice/strokebeat/BeatBarView.kt <<'EOF'
package ai.venice.strokebeat

import android.content.Context
import android.graphics.Canvas
import android.graphics.Paint
import android.view.View

class BeatBarView(context: Context) : View(context) {

    var currentBeat = 0.0
    var beatsPerBar = 4.0
    var pattern = Pattern.QUARTER
    var pulse = 0f

    private val p = Paint(Paint.ANTI_ALIAS_FLAG)
    private val bg = Paint(Paint.ANTI_ALIAS_FLAG)

    private fun dp(v: Float) = v * resources.displayMetrics.density

    override fun onDraw(canvas: Canvas) {
        val w = width.toFloat(); val h = height.toFloat(); val cy = h / 2f
        val hitX = w * 0.20f
        val pxPerBeat = (w - hitX) / 8f

        bg.color = 0xCC05050A.toInt()
        canvas.drawRect(0f, 0f, w, h, bg)

        p.style = Paint.Style.STROKE
        p.strokeWidth = dp(2.5f + pulse * 4f)
        p.color = 0xFF00E5FF.toInt()
        p.alpha = (150 + 105 * pulse).toInt().coerceIn(0, 255)
        canvas.drawLine(hitX, cy - h * 0.40f, hitX, cy + h * 0.40f, p)
        p.style = Paint.Style.FILL

        val step = pattern.step
        var b = Math.ceil((currentBeat + 0.03) / step) * step
        val limit = currentBeat + 8.2
        while (b <= limit) {
            val x = hitX + ((b - currentBeat) * pxPerBeat).toFloat()
            val isDown = (b % beatsPerBar) < step / 2.0
            val fade = (1f - ((b - currentBeat) / 8.2f).toFloat()).coerceIn(0.12f, 1f)
            p.color = if (isDown) 0xFFFF2E8B.toInt() else 0xFF8A94A6.toInt()
            p.alpha = (fade * 255).toInt()
            canvas.drawCircle(x, cy, if (isDown) dp(6.5f) else dp(3.5f), p)
            b += step
        }

        p.color = 0xFFFFFFFF.toInt(); p.alpha = 190
        canvas.drawCircle(hitX, cy, dp(3f), p)
    }
}
EOF

cat > app/src/main/java/ai/venice/strokebeat/Levels.kt <<'EOF'
package ai.venice.strokebeat

import androidx.media3.common.MediaItem
import kotlin.random.Random

enum class Pattern(val step: Double) { QUARTER(1.0), EIGHTH(0.5), HOLD(2.0) }

data class Section(val bars: Int, val bpm: Int, val pattern: Pattern, val pool: List<String>)

data class Level(val id: String, val title: String, val sections: List<Section>)

const val BEATS_PER_BAR = 4

object Levels {

    private val K = "Kimmy Granger"
    private val S = "Savannah Sixx"
    private val A = "Alexis Tae"
    private val M = "Mewslut"

    val all = listOf(
        Level("warmup", "Warm Up", listOf(
            Section(8,  72, Pattern.QUARTER, listOf(K, S)),
            Section(8,  84, Pattern.QUARTER, listOf(A, M)),
            Section(4,  84, Pattern.HOLD,    listOf(K)),
            Section(8,  96, Pattern.EIGHTH,  listOf(M, A))
        )),
        Level("ladder", "The Ladder", listOf(
            Section(4,  84, Pattern.QUARTER, listOf(S, K)),
            Section(8,  96, Pattern.QUARTER, listOf(K, A)),
            Section(8, 108, Pattern.EIGHTH,  listOf(A, M)),
            Section(4, 108, Pattern.HOLD,    listOf(S)),
            Section(12,120, Pattern.EIGHTH,  listOf(M, K, A, S))
        )),
        Level("final", "Last Round", listOf(
            Section(4,  96, Pattern.QUARTER, listOf(A, S)),
            Section(8, 112, Pattern.EIGHTH,  listOf(K, M)),
            Section(8, 128, Pattern.EIGHTH,  listOf(S, A, K)),
            Section(4, 128, Pattern.HOLD,    listOf(M)),
            Section(16,140, Pattern.EIGHTH,  listOf(K, S, A, M))
        ))
    )
}

class Schedule(level: Level, private val rnd: Random, lib: Map<String, List<Clip>>) {

    val items = ArrayList<MediaItem>()
    val barBpm = ArrayList<Int>()
    val barPattern = ArrayList<Pattern>()
    val barClipName = ArrayList<String>()

    init {
        var lastId: String? = null
        for (sec in level.sections) {
            val pool = sec.pool.flatMap { lib[it].orEmpty() }
                .filter { it.effectiveDuration > 700L }
            if (pool.isEmpty()) continue
            val barMs = (BEATS_PER_BAR * 60_000.0 / sec.bpm).toLong()
            repeat(sec.bars) {
                var clip = pool[rnd.nextInt(pool.size)]
                if (pool.size > 1 && clip.id == lastId) clip = pool[rnd.nextInt(pool.size)]
                lastId = clip.id
                barBpm.add(sec.bpm)
                barPattern.add(sec.pattern)
                barClipName.add(clip.performer)
                items.addAll(oneBar(clip, barMs, rnd))
            }
        }
    }

    private fun oneBar(clip: Clip, barMs: Long, rnd: Random): List<MediaItem> {
        val out = ArrayList<MediaItem>(2)
        val dur = clip.effectiveDuration
        if (dur >= barMs) {
            val slack = (dur - barMs).coerceAtLeast(0L)
            val start = if (slack > 600L) rnd.nextLong(slack) else 0L
            out += item(clip, start, start + barMs)
        } else {
            val reps = ((barMs + dur - 1) / dur).toInt()
            for (i in 0 until reps) {
                val end = if (i == reps - 1) barMs - i * dur else dur
                out += item(clip, 0L, end)
            }
        }
        return out
    }

    private fun item(clip: Clip, start: Long, end: Long): MediaItem =
        MediaItem.Builder()
            .setUri(clip.uri)
            .setClippingConfiguration(
                MediaItem.ClippingConfiguration.Builder()
                    .setStartPositionMs(start)
                    .setEndPositionMs(end.coerceAtLeast(start + 200L))
                    .build()
            )
            .build()
}
EOF

cat > app/src/main/java/ai/venice/strokebeat/Library.kt <<'EOF'
package ai.venice.strokebeat

import android.content.Context
import android.media.MediaMetadataRetriever
import org.json.JSONArray
import org.json.JSONObject
import java.io.File
import java.io.FileOutputStream
import java.net.HttpURLConnection
import java.net.URL
import java.net.URLEncoder

data class Clip(
    val id: String,
    val performer: String,
    val remoteUrl: String,
    val durationMs: Long,
    val localPath: String? = null,
    val assetPath: String? = null
) {
    val uri: String get() =
        assetPath?.let { "asset:///$it" }
            ?: localPath?.let { "file://$it" }
            ?: remoteUrl

    val effectiveDuration: Long get() = if (durationMs > 0L) durationMs else 15_000L
}

object Redgifs {

    private const val UA =
        "Mozilla/5.0 (Linux; Android 14; Pixel 8) AppleWebKit/537.36 " +
        "(KHTML, like Gecko) Chrome/124.0.0.0 Mobile Safari/537.36"

    private var token: String? = null
    private var tokenAt = 0L

    private fun open(url: String, auth: Boolean = false): HttpURLConnection {
        val c = URL(url).openConnection() as HttpURLConnection
        c.instanceFollowRedirects = true
        c.connectTimeout = 15000
        c.readTimeout = 25000
        c.setRequestProperty("User-Agent", UA)
        c.setRequestProperty("Accept", "*/*")
        if (auth) c.setRequestProperty("Authorization", "Bearer " + ensureToken())
        return c
    }

    private fun read(c: HttpURLConnection): String {
        val code = c.responseCode
        val stream = if (code in 200..299) c.inputStream else c.errorStream
        val body = stream?.bufferedReader()?.use { it.readText() } ?: ""
        if (code !in 200..299) throw RuntimeException("HTTP $code: ${body.take(180)}")
        return body
    }

    @Synchronized
    private fun ensureToken(): String {
        val t = token
        if (t != null && System.currentTimeMillis() - tokenAt < 12 * 3600_000L) return t
        val fresh = JSONObject(read(open("https://api.redgifs.com/v2/auth/temporary")))
            .getString("token")
        token = fresh
        tokenAt = System.currentTimeMillis()
        return fresh
    }

    fun search(query: String, count: Int = 40): List<Clip> {
        val q = URLEncoder.encode(query, "UTF-8")
        val url = "https://api.redgifs.com/v2/gifs/search" +
                  "?search_text=$q&order=trending&count=$count&page=1&type=g"
        val arr = JSONObject(read(open(url, auth = true))).optJSONArray("gifs")
            ?: return emptyList()
        val out = ArrayList<Clip>(arr.length())
        for (i in 0 until arr.length()) {
            val g = arr.getJSONObject(i)
            val urls = g.optJSONObject("urls") ?: continue
            val link = urls.optString("hd").ifBlank { urls.optString("sd") }
            if (link.isBlank()) continue
            out += Clip(
                id = g.getString("id"),
                performer = query,
                remoteUrl = link,
                durationMs = (g.optDouble("duration", 0.0) * 1000.0).toLong()
            )
        }
        return out
    }

    fun download(clip: Clip, dest: File) {
        dest.parentFile?.mkdirs()
        val tmp = File(dest.absolutePath + ".part")
        open(clip.remoteUrl).inputStream.use { ins ->
            FileOutputStream(tmp).use { outs -> ins.copyTo(outs, 65536) }
        }
        if (tmp.length() < 4096) { tmp.delete(); throw RuntimeException("empty file") }
        tmp.renameTo(dest)
    }
}

class ClipStore(private val ctx: Context) {

    private val dir = File(ctx.filesDir, "clips").apply { mkdirs() }
    private val index = File(ctx.filesDir, "clips.json")

    fun load(): MutableMap<String, MutableList<Clip>> {
        val out = HashMap<String, MutableList<Clip>>()
        if (!index.exists()) return out
        val arr = JSONArray(index.readText())
        for (i in 0 until arr.length()) {
            val o = arr.getJSONObject(i)
            val path = o.getString("local")
            val f = File(path)
            if (!f.exists()) continue
            val c = Clip(
                id = o.getString("id"),
                performer = o.getString("performer"),
                remoteUrl = o.optString("remote"),
                durationMs = o.getLong("durationMs"),
                localPath = path
            )
            out.getOrPut(c.performer) { ArrayList() }.add(c)
        }
        return out
    }

    fun save(lib: Map<String, List<Clip>>) {
        val arr = JSONArray()
        for (list in lib.values) for (c in list) {
            if (c.localPath == null) continue
            arr.put(JSONObject().apply {
                put("id", c.id); put("performer", c.performer)
                put("remote", c.remoteUrl); put("durationMs", c.durationMs)
                put("local", c.localPath)
            })
        }
        index.writeText(arr.toString())
    }

    fun fileFor(c: Clip) = File(dir, "${c.performer.hashCode().toString(16)}_${c.id}.mp4")

    fun bundled(): Map<String, MutableList<Clip>> {
        val out = HashMap<String, MutableList<Clip>>()
        val names = runCatching {
            ctx.assets.list("clips")?.toList() ?: emptyList()
        }.getOrDefault(emptyList())
        for (n in names) {
            if (!n.endsWith(".mp4") && !n.endsWith(".webm")) continue
            val base = n.substringBeforeLast('.')
            val performer = base.substringBefore("__").replace('_', ' ').trim()
                .ifBlank { "Bundled" }
            out.getOrPut(performer) { ArrayList() }.add(
                Clip(
                    id = base.substringAfter("__", base),
                    performer = performer,
                    remoteUrl = "",
                    durationMs = assetDuration("clips/$n"),
                    assetPath = "clips/$n"
                )
            )
        }
        return out
    }

    private fun assetDuration(path: String): Long = runCatching {
        val fd = ctx.assets.openFd(path)
        val r = MediaMetadataRetriever()
        r.setDataSource(fd.fileDescriptor, fd.startOffset, fd.length)
        val ms = r.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION)
            ?.toLongOrNull() ?: 0L
        r.release(); fd.close()
        ms
    }.getOrDefault(0L)

    fun clear() {
        dir.listFiles()?.forEach { it.delete() }
        index.delete()
    }
}
EOF

cat > app/src/main/java/ai/venice/strokebeat/Engine.kt <<'EOF'
package ai.venice.strokebeat

import android.content.Context
import android.net.Uri
import androidx.media3.common.AudioAttributes
import androidx.media3.common.C
import androidx.media3.common.MediaItem
import androidx.media3.common.PlaybackParameters
import androidx.media3.common.Player
import androidx.media3.datasource.DefaultDataSource
import androidx.media3.datasource.DefaultHttpDataSource
import androidx.media3.exoplayer.DefaultLoadControl
import androidx.media3.exoplayer.ExoPlayer
import androidx.media3.exoplayer.source.DefaultMediaSourceFactory
import java.io.File
import java.io.RandomAccessFile
import java.nio.ByteBuffer
import java.nio.ByteOrder

object ClickTrack {

    const val SOURCE_BPM = 120.0
    const val MS_PER_BEAT = 60_000.0 / SOURCE_BPM
    const val BEATS = 256
    private const val SR = 44100

    fun ensure(ctx: Context): File {
        val f = File(ctx.filesDir, "click_${SOURCE_BPM.toInt()}_$BEATS.wav")
        if (!f.exists() || f.length() < 1_000_000L) render(f)
        return f
    }

    private fun render(file: File) {
        val spb = (60.0 / SOURCE_BPM * SR).toInt()
        val total = spb * BEATS
        val buf = ShortArray(total)
        for (b in 0 until BEATS) {
            val down = b % 4 == 0
            val start = b * spb
            val len = ((if (down) 0.10 else 0.045) * SR).toInt()
            val freq = if (down) 96.0 else 1400.0
            val decay = if (down) 22.0 else 70.0
            val amp = if (down) 0.50 else 0.26
            for (i in 0 until len) {
                if (start + i >= total) break
                val t = i.toDouble() / SR
                val s = Math.sin(2.0 * Math.PI * freq * t) * Math.exp(-t * decay) * amp
                buf[start + i] = (s * 32767.0).toInt().toShort()
            }
        }
        val bytes = ByteArray(total * 2)
        for (i in 0 until total) {
            val v = buf[i].toInt()
            bytes[i * 2] = (v and 0xFF).toByte()
            bytes[i * 2 + 1] = ((v shr 8) and 0xFF).toByte()
        }
        RandomAccessFile(file, "rw").use { raf ->
            raf.setLength(0)
            raf.write(wavHeader(bytes.size))
            raf.write(bytes)
        }
    }

    private fun wavHeader(dataLen: Int): ByteArray {
        val ch = 1; val bits = 16
        val h = ByteBuffer.allocate(44).order(ByteOrder.LITTLE_ENDIAN)
        h.put("RIFF".toByteArray()); h.putInt(36 + dataLen); h.put("WAVE".toByteArray())
        h.put("fmt ".toByteArray()); h.putInt(16); h.putShort(1.toShort()); h.putShort(ch.toShort())
        h.putInt(SR); h.putInt(SR * ch * bits / 8)
        h.putShort((ch * bits / 8).toShort()); h.putShort(bits.toShort())
        h.put("data".toByteArray()); h.putInt(dataLen)
        return h.array()
    }
}

class Engine(private val ctx: Context) {

    private val audioAttrs = AudioAttributes.Builder()
        .setUsage(C.USAGE_MEDIA)
        .setContentType(C.AUDIO_CONTENT_TYPE_MUSIC)
        .build()

    private val httpFactory = DefaultHttpDataSource.Factory().setUserAgent(CLIP_UA)

    private fun build(renderVideo: Boolean): ExoPlayer {
        val ds = DefaultDataSource.Factory(ctx, httpFactory)
        return ExoPlayer.Builder(ctx)
            .setMediaSourceFactory(DefaultMediaSourceFactory(ds))
            .setLoadControl(
                DefaultLoadControl.Builder()
                    .setBufferDurationsMs(20_000, 90_000, 800, 2_000)
                    .build()
            )
            .setAudioAttributes(audioAttrs, true)
            .build()
            .apply {
                setHandleAudioBecomingNoisy(true)
                setWakeMode(C.WAKE_MODE_NETWORK)
                if (renderVideo) {
                    videoScalingMode = C.VIDEO_SCALING_MODE_SCALE_TO_FIT_WITH_CROPPING
                }
            }
    }

    val clicks: ExoPlayer = build(false)
    val video: ExoPlayer = build(true)

    init {
        val clickFile = ClickTrack.ensure(ctx)
        clicks.setMediaItem(MediaItem.fromUri(Uri.fromFile(clickFile)))
        clicks.repeatMode = Player.REPEAT_MODE_ONE
        clicks.volume = 0.8f
        clicks.prepare()
    }

    fun setSpeed(speed: Float) {
        val s = speed.coerceIn(0.4f, 2.5f)
        clicks.playbackParameters = PlaybackParameters(s, 1.0f)
        video.playbackParameters = PlaybackParameters(s, 1.0f)
    }

    fun load(schedule: Schedule) {
        video.setMediaItems(schedule.items, 0, 0L)
        video.repeatMode = Player.REPEAT_MODE_ALL
        video.prepare()
    }

    fun start() {
        clicks.seekTo(0L)
        video.seekTo(0, 0L)
        clicks.play()
        video.play()
    }

    fun pause() { clicks.pause(); video.pause() }
    fun resume() { clicks.play(); video.play() }
    fun release() { clicks.release(); video.release() }

    companion object {
        const val CLIP_UA =
            "Mozilla/5.0 (Linux; Android 14; Pixel 8) AppleWebKit/537.36 " +
            "(KHTML, like Gecko) Chrome/124.0.0.0 Mobile Safari/537.36"
    }
}
EOF

cat > app/src/main/java/ai/venice/strokebeat/MainActivity.kt <<'EOF'
package ai.venice.strokebeat

import android.app.Activity
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.TypedValue
import android.view.Gravity
import android.view.SurfaceView
import android.view.View
import android.view.ViewGroup
import android.view.WindowInsets
import android.view.WindowInsetsController
import android.view.WindowManager
import android.widget.Button
import android.widget.CheckBox
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.ScrollView
import android.widget.TextView
import androidx.annotation.OptIn
import androidx.media3.common.util.UnstableApi
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import kotlin.random.Random

@OptIn(UnstableApi::class)
class MainActivity : Activity() {

    private lateinit var root: FrameLayout
    private lateinit var surface: SurfaceView
    private lateinit var bar: BeatBarView
    private lateinit var hudTop: TextView
    private lateinit var hudBig: TextView
    private lateinit var panel: ScrollView
    private lateinit var status: TextView

    private lateinit var engine: Engine
    private lateinit var store: ClipStore
    private var library = HashMap<String, MutableList<Clip>>()

    private var schedule: Schedule? = null
    private var levelIndex = 0
    private var running = false
    private var beatBase = 0.0
    private var lastPos = 0L
    private var lastBar = -1
    private var paused = false
    private var manualSpeed = 1f

    private val ui = Handler(Looper.getMainLooper())
    private val scope = CoroutineScope(Dispatchers.Main + Job())
    private var fetchJob: Job? = null

    private val performers = listOf("Kimmy Granger", "Savannah Sixx", "Alexis Tae", "Mewslut")

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        immersive()

        engine = Engine(this)
        store = ClipStore(this)
        library = store.load()
        for ((k, v) in store.bundled()) library.getOrPut(k) { ArrayList() }.addAll(v)

        root = FrameLayout(this)
        root.setBackgroundColor(0xFF07070C.toInt())

        surface = SurfaceView(this)
        root.addView(surface, FrameLayout.LayoutParams(MATCH, MATCH))
        engine.video.setVideoSurfaceView(surface)

        bar = BeatBarView(this)
        root.addView(bar, FrameLayout.LayoutParams(MATCH, dp(96)).apply {
            gravity = Gravity.BOTTOM
            bottomMargin = dp(56)
            leftMargin = dp(10); rightMargin = dp(10)
        })

        hudTop = label("", 13f, 0xFFB9C2D0.toInt()).apply {
            setPadding(dp(16), dp(28), dp(16), 0)
        }
        root.addView(hudTop, FrameLayout.LayoutParams(MATCH, WRAP).apply { gravity = Gravity.TOP })

        hudBig = label("", 30f, 0xFFFFFFFF.toInt()).apply {
            setPadding(dp(16), dp(58), dp(16), 0)
        }
        root.addView(hudBig, FrameLayout.LayoutParams(MATCH, WRAP).apply { gravity = Gravity.TOP })

        surface.setOnClickListener { togglePause() }
        bar.setOnClickListener { togglePause() }

        root.addView(buildControls(), FrameLayout.LayoutParams(MATCH, dp(56)).apply {
            gravity = Gravity.BOTTOM
        })
        root.addView(buildPanel())

        setContentView(root)

        ui.postDelayed({ if (library.values.all { it.isEmpty() }) showPanel() }, 300)
    }

    private fun label(text: String, size: Float, color: Int) = TextView(this).apply {
        this.text = text
        textSize = size
        setTextColor(color)
        setShadowLayer(6f, 0f, 2f, 0xCC000000.toInt())
    }

    private fun buildControls(): LinearLayout {
        val ctrl = LinearLayout(this)
        ctrl.orientation = LinearLayout.HORIZONTAL
        ctrl.gravity = Gravity.CENTER
        ctrl.setPadding(dp(8), dp(4), dp(8), dp(8))
        ctrl.addView(btn("LIB") { showPanel() })
        ctrl.addView(btn("PLAY") { togglePause() })
        ctrl.addView(btn("NEXT") { nextLevel() })
        ctrl.addView(btn("-BPM") { nudgeSpeed(-0.05f) })
        ctrl.addView(btn("+BPM") { nudgeSpeed(0.05f) })
        ctrl.addView(btn("STOP") { stopPlay() })
        return ctrl
    }

    private fun btn(text: String, onClick: () -> Unit) = Button(this).apply {
        this.text = text
        textSize = 11f
        setOnClickListener { onClick() }
        layoutParams = LinearLayout.LayoutParams(0, dp(44), 1f).apply { marginEnd = dp(4) }
    }

    private fun buildPanel(): ScrollView {
        panel = ScrollView(this)
        val box = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(dp(22), dp(48), dp(22), dp(48))
            setBackgroundColor(0xF207070C.toInt())
        }

        box.addView(ImageView(this).apply {
            setImageResource(R.drawable.ic_launcher_foreground)
            layoutParams = LinearLayout.LayoutParams(dp(72), dp(72))
        })
        box.addView(label("STROKEBEAT", 32f, 0xFFFF2E8B.toInt()))
        box.addView(label("beat-locked clip trainer", 13f, 0xFF8A94A6.toInt()).apply {
            setPadding(0, 0, 0, dp(24))
        })

        val boxes = HashMap<String, CheckBox>()
        for (p in performers) {
            val cb = CheckBox(this).apply {
                text = p
                textSize = 17f
                setTextColor(0xFFE6EAF2.toInt())
                isChecked = library[p]?.isNotEmpty() == true
            }
            boxes[p] = cb
            box.addView(cb)
        }

        status = label("", 13f, 0xFF00E5FF.toInt()).apply { setPadding(0, dp(18), 0, dp(18)) }
        box.addView(status)

        box.addView(btnWide("FETCH CLIPS") { fetch(boxes) })
        box.addView(btnWide("PLAY") { showPlay() })
        box.addView(btnWide("DELETE ALL CLIPS") {
            store.clear(); library = HashMap(); refreshStatus(); status.text = "wiped."
        })
        box.addView(label(
            "Fetch pulls ~10 clips per selected performer from Redgifs and caches them " +
            "on the device. Needs internet the first time only.", 12f, 0xFF6E7686.toInt()
        ).apply { setPadding(0, dp(16), 0, 0) })

        panel.addView(box)
        panel.visibility = View.GONE
        return panel
    }

    private fun btnWide(text: String, onClick: () -> Unit) = Button(this).apply {
        this.text = text
        textSize = 15f
        setOnClickListener { onClick() }
        layoutParams = LinearLayout.LayoutParams(MATCH, dp(52)).apply { topMargin = dp(8) }
    }

    private fun showPanel() {
        running = false
        engine.pause()
        panel.visibility = View.VISIBLE
        bar.visibility = View.GONE
        hudBig.text = ""
        refreshStatus()
    }

    private fun showPlay() {
        if (library.values.all { it.isEmpty() }) {
            status.text = "no clips yet - hit FETCH."
            return
        }
        panel.visibility = View.GONE
        bar.visibility = View.VISIBLE
        levelIndex = 0
        startLevel()
    }

    private fun refreshStatus() {
        val total = library.values.sumOf { it.size }
        status.text = if (total == 0) "library empty"
        else library.entries.filter { it.value.isNotEmpty() }
            .joinToString("  .  ") { "${it.key}: ${it.value.size}" }
    }

    private fun fetch(boxes: Map<String, CheckBox>) {
        val chosen = boxes.filterValues { it.isChecked }.keys.toList()
        if (chosen.isEmpty()) { status.text = "pick at least one performer."; return }
        fetchJob?.cancel()
        fetchJob = scope.launch {
            var done = 0
            for (p in chosen) {
                status.text = "searching $p..."
                val found = withContext(Dispatchers.IO) {
                    runCatching { Redgifs.search(p, 40) }.getOrElse { emptyList() }
                }
                if (found.isEmpty()) { status.text = "$p - nothing found (or blocked)"; continue }
                for (clip in found.take(10)) {
                    val dest = store.fileFor(clip)
                    if (dest.exists()) { done++; continue }
                    status.text = "$p  $done cached  -  ${clip.id}"
                    val ok = withContext(Dispatchers.IO) {
                        runCatching { Redgifs.download(clip, dest) }.isSuccess
                    }
                    if (ok) {
                        library.getOrPut(p) { ArrayList() }
                            .add(clip.copy(localPath = dest.absolutePath))
                        done++
                    }
                }
                store.save(library)
                refreshStatus()
            }
            status.text = "done - $done clips cached. hit PLAY."
        }
    }

    private fun startLevel() {
        val level = Levels.all[levelIndex % Levels.all.size]
        val sched = Schedule(level, Random(System.currentTimeMillis()), library)
        if (sched.items.isEmpty()) {
            status.text = "no usable clips for this level"
            showPanel()
            return
        }
        schedule = sched
        engine.load(sched)
        beatBase = 0.0; lastPos = 0L; lastBar = -1; paused = false
        engine.start()
        running = true
        hudTop.text = "LEVEL ${levelIndex + 1}/${Levels.all.size}  -  ${level.title.uppercase()}"
        ui.removeCallbacks(tick)
        ui.post(tick)
    }

    private fun nextLevel() { levelIndex++; startLevel() }

    private fun stopPlay() {
        running = false
        engine.pause()
        ui.removeCallbacks(tick)
        showPanel()
    }

    private fun togglePause() {
        if (schedule == null) return
        paused = !paused
        if (paused) engine.pause() else engine.resume()
    }

    private fun nudgeSpeed(d: Float) {
        manualSpeed = (manualSpeed + d).coerceIn(0.5f, 2.0f)
        hudTop.text = "MANUAL SPEED  ${"%.2f".format(manualSpeed)}x"
    }

    private val tick = object : Runnable {
        override fun run() {
            if (!running) return
            val s = schedule ?: return

            val pos = engine.clicks.currentPosition
            if (pos + 80L < lastPos) beatBase += ClickTrack.BEATS.toDouble()
            lastPos = pos
            val beat = beatBase + pos / ClickTrack.MS_PER_BEAT
            val barIdx = (beat / BEATS_PER_BAR).toInt()

            if (barIdx != lastBar && barIdx in s.barBpm.indices) {
                lastBar = barIdx
                val target = s.barBpm[barIdx] / ClickTrack.SOURCE_BPM
                engine.setSpeed(target.toFloat() * manualSpeed)
                if (engine.video.currentMediaItemIndex != barIdx) {
                    engine.video.seekTo(barIdx, 0L)
                }
                if (!paused) engine.video.play()
                bar.pattern = s.barPattern[barIdx]
                hudBig.text = "${s.barBpm[barIdx]} BPM   bar ${barIdx + 1}/${s.items.size}"
                hudTop.text = s.barClipName[barIdx].uppercase()
                bar.pulse = 1f
            }

            bar.currentBeat = beat
            bar.pulse = (bar.pulse - 0.09f).coerceAtLeast(0f)
            bar.invalidate()

            ui.postDelayed(this, 16L)
        }
    }

    override fun onPause() { super.onPause(); if (running) engine.pause() }
    override fun onResume() { super.onResume(); if (running && !paused) engine.resume() }
    override fun onDestroy() { super.onDestroy(); ui.removeCallbacks(tick); engine.release() }

    private fun immersive() {
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            window.setDecorFitsSystemWindows(false)
            window.insetsController?.let {
                it.hide(WindowInsets.Type.systemBars())
                it.systemBarsBehavior =
                    WindowInsetsController.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE
            }
        } else {
            @Suppress("DEPRECATION")
            window.decorView.systemUiVisibility =
                View.SYSTEM_UI_FLAG_LAYOUT_STABLE or
                View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION or
                View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN or
                View.SYSTEM_UI_FLAG_HIDE_NAVIGATION or
                View.SYSTEM_UI_FLAG_FULLSCREEN or
                View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY
        }
    }

    private fun dp(v: Int) = TypedValue.applyDimension(
        TypedValue.COMPLEX_UNIT_DIP, v.toFloat(), resources.displayMetrics
    ).toInt()

    private companion object {
        const val MATCH = ViewGroup.LayoutParams.MATCH_PARENT
        const val WRAP = ViewGroup.LayoutParams.WRAP_CONTENT
    }
}
EOF

# ---------------- build scripts ----------------
cat > build.sh <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NAME="Strokebeat"; VERSION="1.0"
need(){ command -v "$1" >/dev/null 2>&1 || { echo "missing: $1"; exit 1; }; }
need curl; need unzip

if [ -z "${JAVA_HOME:-}" ] || ! "$JAVA_HOME/bin/java" -version >/dev/null 2>&1; then
  for c in "/Applications/Android Studio.app/Contents/jbr/Contents/Home" \
           "$HOME/Android/android-studio/jbr" \
           "/usr/lib/jvm/java-17-openjdk-amd64" \
           "/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home"; do
    if [ -x "$c/bin/java" ]; then export JAVA_HOME="$c"; break; fi
  done
fi
[ -n "${JAVA_HOME:-}" ] || { echo "No JDK 17 found. Set JAVA_HOME."; exit 1; }

SDK="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-$HOME/Android/Sdk}}"
export ANDROID_HOME="$SDK"
if [ ! -d "$SDK/cmdline-tools/latest" ]; then
  echo "==> installing Android cmdline-tools"
  mkdir -p "$SDK/cmdline-tools"
  case "$(uname -s)" in
    Darwin) CT=commandlinetools-mac-11076708_latest.zip ;;
    *)      CT=commandlinetools-linux-11076708_latest.zip ;;
  esac
  curl -fL "https://dl.google.com/android/repository/$CT" -o /tmp/ct.zip
  unzip -q -o /tmp/ct.zip -d "$SDK/cmdline-tools"
  mv "$SDK/cmdline-tools/cmdline-tools" "$SDK/cmdline-tools/latest"
fi
export PATH="$SDK/cmdline-tools/latest/bin:$SDK/platform-tools:$PATH"
printf 'sdk.dir=%s\n' "$SDK" > "$ROOT/local.properties"

if command -v sdkmanager >/dev/null 2>&1; then
  yes | sdkmanager --licenses >/dev/null 2>&1 || true
  sdkmanager --install "platform-tools" "platforms;android-34" "build-tools;34.0.0" >/dev/null
fi

GRADLE="$HOME/.strokebeat-gradle/gradle-8.7/bin/gradle"
if [ ! -x "$GRADLE" ]; then
  echo "==> fetching Gradle 8.7"
  mkdir -p "$HOME/.strokebeat-gradle"
  curl -fL "https://services.gradle.org/distributions/gradle-8.7-bin.zip" -o /tmp/g.zip
  unzip -q -o /tmp/g.zip -d "$HOME/.strokebeat-gradle"
fi

if [ ! -f "$ROOT/strokebeat.jks" ]; then
  echo "==> generating signing key"
  "$JAVA_HOME/bin/keytool" -genkeypair -keystore "$ROOT/strokebeat.jks" \
    -alias strokebeat -keyalg RSA -keysize 2048 -validity 10000 \
    -storepass strokebeat -keypass strokebeat -dname "CN=Strokebeat" >/dev/null 2>&1
fi

cd "$ROOT"
"$GRADLE" --no-daemon assembleRelease
cp "app/build/outputs/apk/release/$NAME-$VERSION.apk" "./$NAME-$VERSION.apk"
echo
echo "  APK -> $ROOT/$NAME-$VERSION.apk"
EOF
chmod +x build.sh

cat > build.ps1 <<'EOF'
$ErrorActionPreference = "Stop"
$root = $PSScriptRoot; $name = "Strokebeat"; $ver = "1.0"

if (-not $env:JAVA_HOME -or -not (Test-Path "$env:JAVA_HOME\bin\java.exe")) {
  foreach ($c in @("$env:ProgramFiles\Android\Android Studio\jbr",
                   "$env:LOCALAPPDATA\Programs\Android Studio\jbr",
                   "$env:ProgramFiles\Java\jdk-17")) {
    if (Test-Path "$c\bin\java.exe") { $env:JAVA_HOME = $c; break }
  }
}
if (-not $env:JAVA_HOME) { throw "No JDK 17 found. Set JAVA_HOME." }

$sdk = if ($env:ANDROID_HOME) { $env:ANDROID_HOME } else { "$env:LOCALAPPDATA\Android\Sdk" }
if (-not (Test-Path "$sdk\cmdline-tools\latest")) {
  New-Item -ItemType Directory -Force "$sdk\cmdline-tools" | Out-Null
  curl.exe -fL "https://dl.google.com/android/repository/commandlinetools-win-11076708_latest.zip" -o "$env:TEMP\ct.zip"
  Expand-Archive "$env:TEMP\ct.zip" -DestinationPath "$sdk\cmdline-tools" -Force
  Move-Item "$sdk\cmdline-tools\cmdline-tools" "$sdk\cmdline-tools\latest"
}
$env:ANDROID_HOME = $sdk
$env:PATH = "$sdk\cmdline-tools\latest\bin;$sdk\platform-tools;$env:PATH"
"sdk.dir=$($sdk -replace '\\','\\')" | Set-Content "$root\local.properties"

if (Get-Command sdkmanager -ErrorAction SilentlyContinue) {
  echo y | sdkmanager --licenses | Out-Null
  sdkmanager --install "platform-tools" "platforms;android-34" "build-tools;34.0.0" | Out-Null
}

$gdir = "$env:USERPROFILE\.strokebeat-gradle"
$gradle = "$gdir\gradle-8.7\bin\gradle.bat"
if (-not (Test-Path $gradle)) {
  New-Item -ItemType Directory -Force $gdir | Out-Null
  curl.exe -fL "https://services.gradle.org/distributions/gradle-8.7-bin.zip" -o "$env:TEMP\g.zip"
  Expand-Archive "$env:TEMP\g.zip" -DestinationPath $gdir -Force
}

if (-not (Test-Path "$root\strokebeat.jks")) {
  & "$env:JAVA_HOME\bin\keytool.exe" -genkeypair -keystore "$root\strokebeat.jks" -alias strokebeat `
    -keyalg RSA -keysize 2048 -validity 10000 -storepass strokebeat -keypass strokebeat -dname "CN=Strokebeat"
}

Push-Location $root
& $gradle --no-daemon assembleRelease
Copy-Item "app\build\outputs\apk\release\$name-$ver.apk" "$root\$name-$ver.apk" -Force
Pop-Location
Write-Host "`n  APK -> $root\$name-$ver.apk"
EOF

# ---------------- CI ----------------
cat > .github/workflows/build.yml <<'EOF'
name: build-apk
on:
  push:
    branches: [ main, master ]
  workflow_dispatch:

permissions:
  contents: write

jobs:
  apk:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: '17'

      - name: cache gradle
        uses: actions/cache@v4
        with:
          path: ~/.strokebeat-gradle
          key: gradle-8.7

      - name: cache signing key
        uses: actions/cache@v4
        with:
          path: strokebeat.jks
          key: strokebeat-keystore-v1

      - name: build
        run: bash build.sh

      - uses: actions/upload-artifact@v4
        with:
          name: Strokebeat-apk
          path: Strokebeat-*.apk
          if-no-files-found: error

      - name: attach to release
        if: startsWith(github.ref, 'refs/tags/v')
        uses: softprops/action-gh-release@v2
        with:
          files: Strokebeat-*.apk
EOF

echo
echo "Project created in: $(pwd)"
echo "Next: bash build.sh   (or Route A: push to GitHub and let Actions build it)"