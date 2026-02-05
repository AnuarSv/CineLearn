package com.cinelearn.cinelearn

import android.media.MediaCodec
import android.media.MediaExtractor
import android.media.MediaFormat
import android.media.MediaMuxer
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.nio.ByteBuffer

import android.media.MediaMetadataRetriever
import android.graphics.Bitmap
import java.io.FileOutputStream
import java.io.File

import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.Rect
import android.graphics.Typeface

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.cinelearn.cinelearn/video_tools"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "trimVideo" -> {
                    val inputPath = call.argument<String>("inputPath")
                    val outputPath = call.argument<String>("outputPath")
                    val startMs = call.argument<Int>("startMs")?.toLong() ?: 0L
                    val durationMs = call.argument<Int>("durationMs")?.toLong() ?: 0L
                    
                    if (inputPath != null && outputPath != null) {
                        try {
                            genVideoUsingMuxer(inputPath, outputPath, startMs, startMs + durationMs)
                            result.success(outputPath)
                        } catch (e: Exception) {
                            result.error("TRIM_ERROR", e.message, null)
                        }
                    }
                }
                "getThumbnail" -> {
                    val videoPath = call.argument<String>("videoPath")
                    val outputPath = call.argument<String>("outputPath")
                    val timeMs = call.argument<Int>("timeMs")?.toLong() ?: 1000L
                    val word = call.argument<String>("word")
                    val contextText = call.argument<String>("context")
                    
                    if (videoPath != null && outputPath != null) {
                        try {
                            val retriever = MediaMetadataRetriever()
                            retriever.setDataSource(videoPath)
                            var bitmap = retriever.getFrameAtTime(timeMs * 1000, MediaMetadataRetriever.OPTION_CLOSEST_SYNC)
                            
                            if (bitmap != null && (word != null || contextText != null)) {
                                // Создаем копию для рисования
                                val mutableBitmap = bitmap.copy(Bitmap.Config.ARGB_8888, true)
                                val canvas = Canvas(mutableBitmap)
                                val paint = Paint(Paint.ANTI_ALIAS_FLAG)
                                
                                // Рисуем затемнение внизу для читаемости текста
                                paint.color = Color.parseColor("#80000000")
                                canvas.drawRect(0f, mutableBitmap.height * 0.7f, mutableBitmap.width.toFloat(), mutableBitmap.height.toFloat(), paint)

                                // Настройки для слова (Word)
                                paint.color = Color.YELLOW
                                paint.textSize = mutableBitmap.height / 12f
                                paint.typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
                                paint.textAlign = Paint.Align.CENTER
                                
                                word?.let {
                                    canvas.drawText(it.uppercase(), mutableBitmap.width / 2f, mutableBitmap.height * 0.82f, paint)
                                }

                                // Настройки для контекста (Subtitle)
                                paint.color = Color.WHITE
                                paint.textSize = mutableBitmap.height / 20f
                                paint.typeface = Typeface.create(Typeface.DEFAULT, Typeface.NORMAL)
                                
                                contextText?.let {
                                    canvas.drawText(it, mutableBitmap.width / 2f, mutableBitmap.height * 0.92f, paint)
                                }
                                
                                bitmap = mutableBitmap
                            }

                            val file = File(outputPath)
                            val out = FileOutputStream(file)
                            bitmap?.compress(Bitmap.CompressFormat.JPEG, 90, out)
                            out.flush()
                            out.close()
                            retriever.release()
                            result.success(outputPath)
                        } catch (e: Exception) {
                            result.error("THUMB_ERROR", e.message, null)
                        }
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun genVideoUsingMuxer(srcPath: String, dstPath: String, startMs: Long, endMs: Long) {
        val extractor = MediaExtractor()
        extractor.setDataSource(srcPath)
        
        val trackCount = extractor.trackCount
        val muxer = MediaMuxer(dstPath, MediaMuxer.OutputFormat.MUXER_OUTPUT_MPEG_4)
        val indexMap = HashMap<Int, Int>()
        
        var bufferSize = -1
        for (i in 0 until trackCount) {
            val format = extractor.getTrackFormat(i)
            val mime = format.getString(MediaFormat.KEY_MIME)
            if (mime?.startsWith("video/") == true || mime?.startsWith("audio/") == true) {
                extractor.selectTrack(i)
                val dstIndex = muxer.addTrack(format)
                indexMap[i] = dstIndex
                if (format.containsKey(MediaFormat.KEY_MAX_INPUT_SIZE)) {
                    val newSize = format.getInteger(MediaFormat.KEY_MAX_INPUT_SIZE)
                    bufferSize = if (newSize > bufferSize) newSize else bufferSize
                }
            }
        }

        if (bufferSize < 0) bufferSize = 1024 * 1024
        
        val buffer = ByteBuffer.allocate(bufferSize)
        val bufferInfo = MediaCodec.BufferInfo()
        
        muxer.start()
        // SEEK_TO_PREVIOUS_SYNC важен для того, чтобы видео не начиналось с черного экрана
        extractor.seekTo(startMs * 1000, MediaExtractor.SEEK_TO_PREVIOUS_SYNC)
        
        while (true) {
            val trackIndex = extractor.sampleTrackIndex
            if (trackIndex < 0) break
            
            val presentationTimeUs = extractor.sampleTime
            if (presentationTimeUs > endMs * 1000) break
            
            bufferInfo.offset = 0
            bufferInfo.size = extractor.readSampleData(buffer, 0)
            bufferInfo.flags = extractor.sampleFlags
            bufferInfo.presentationTimeUs = presentationTimeUs
            
            muxer.writeSampleData(indexMap[trackIndex]!!, buffer, bufferInfo)
            extractor.advance()
        }
        
        muxer.stop()
        muxer.release()
        extractor.release()
    }
}
