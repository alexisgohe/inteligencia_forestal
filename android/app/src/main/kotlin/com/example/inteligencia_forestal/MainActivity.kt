package com.example.inteligencia_forestal

import android.content.Intent
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "ar_measure_channel"
    private var pendingResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "openAR") {
                    Log.d("LOG_AR", "Llamada desde Flutter: openAR")
                    if (pendingResult != null) {
                        Log.w("LOG_AR", "Ya existe un pendingResult, rechazando nueva llamada")
                        result.error("ALREADY_RUNNING", "Sesión AR activa", null)
                        return@setMethodCallHandler
                    }
                    try {
                        val modo = call.argument<String>("modo") ?: "altura"
                        Log.d("LOG_AR", "Iniciando ArMeasurementActivity con modo: $modo")
                        val intent = Intent(this, ArMeasurementActivity::class.java)
                        intent.putExtra("modo", modo)
                        startActivityForResult(intent, 1001)
                        // Solo guardamos el result si el intent no lanzó excepción
                        pendingResult = result
                    } catch (e: Exception) {
                        Log.e("LOG_AR", "Error al iniciar actividad: ${e.message}")
                        result.error("ACTIVITY_START_FAILED", e.message, null)
                    }
                }
            }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        Log.d("LOG_AR", "onActivityResult: req=$requestCode, res=$resultCode")
        if (requestCode == 1001) {
            val result = pendingResult
            if (result != null) {
                pendingResult = null 
                try {
                    if (resultCode == RESULT_OK) {
                        val distancia = data?.getDoubleExtra("distancia", 0.0) ?: 0.0
                        Log.d("LOG_AR", "Enviando éxito a Flutter: $distancia")
                        result.success(distancia)
                    } else {
                        Log.d("LOG_AR", "Actividad cancelada o sin resultado, enviando null")
                        result.success(null)
                    }
                } catch (e: IllegalStateException) {
                    Log.e("LOG_AR", "Error al responder: ${e.message}. El canal ya estaba cerrado.")
                } catch (e: Exception) {
                    Log.e("LOG_AR", "Error inesperado: ${e.message}")
                }
            } else {
                Log.w("LOG_AR", "Se recibió un resultado para 1001 pero pendingResult era null")
            }
            return
        }
        super.onActivityResult(requestCode, resultCode, data)
    }
}