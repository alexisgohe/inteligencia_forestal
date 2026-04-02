package com.example.inteligencia_forestal

import android.app.Activity
import android.content.Intent
import android.graphics.Color
import android.os.Bundle
import android.util.Log
import android.view.MotionEvent
import android.view.View
import android.widget.Button
import android.widget.TextView
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.google.ar.core.Anchor
import com.google.ar.core.Config
import com.google.ar.core.HitResult
import com.google.ar.core.InstantPlacementPoint
import com.google.ar.core.Plane
import com.google.ar.core.Point
import com.google.ar.core.TrackingState
import com.google.ar.sceneform.AnchorNode
import com.google.ar.sceneform.Node
import com.google.ar.sceneform.math.Vector3
import com.google.ar.sceneform.rendering.MaterialFactory
import com.google.ar.sceneform.rendering.ShapeFactory
import com.google.ar.sceneform.rendering.ViewRenderable
import com.google.ar.sceneform.ux.ArFragment
import kotlin.math.sqrt

class ArMeasurementActivity : AppCompatActivity() {

    private lateinit var arFragment: ArFragment

    private var puntoA: Anchor? = null
    private var puntoB: Anchor? = null

    private var lineaNode: Node? = null
    private var textoNode: Node? = null
    private var anchorNodeA: AnchorNode? = null
    private var anchorNodeB: AnchorNode? = null
    private var modo: String = "altura"

    // UI elements
    private lateinit var placePointAButton: Button
    private lateinit var placePointBButton: Button
    private lateinit var instructionTextView: TextView
    private lateinit var confirmButton: Button
    private lateinit var resetButton: Button
    private lateinit var cancelButton: Button

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_ar_measurement)

        modo = intent.getStringExtra("modo") ?: "altura"

        arFragment = supportFragmentManager
            .findFragmentById(R.id.arFragment) as ArFragment

        // Initialize UI elements
        placePointAButton = findViewById(R.id.placePointAButton)
        placePointBButton = findViewById(R.id.placePointBButton)
        instructionTextView = findViewById(R.id.instructionTextView)
        confirmButton = findViewById(R.id.confirmButton)
        resetButton = findViewById(R.id.resetButton)
        cancelButton = findViewById(R.id.cancelButton)

        // Set up button listeners
        placePointAButton.setOnClickListener {
            tryPlacePointAtCenter()
        }
        placePointBButton.setOnClickListener {
            tryPlacePointAtCenter()
        }
        confirmButton.setOnClickListener {
            // Asumiendo que una medición ha sido calculada y mostrada
            val finalMeasurement = if (modo == "altura") calcularAltura() else calcularDistancia()
            Log.d("LOG_AR", "Usuario confirmó medición: $finalMeasurement m")
            val resultIntent = Intent()
            resultIntent.putExtra("distancia", finalMeasurement.toDouble())
            setResult(Activity.RESULT_OK, resultIntent)
            finish()
        }
        resetButton.setOnClickListener {
            Log.d("LOG_AR", "Usuario eligió repetir la medición.")
            resetear()
        }
        cancelButton.setOnClickListener {
            Log.d("LOG_AR", "Usuario canceló la medición.")
            setResult(Activity.RESULT_CANCELED)
            finish()
        }

        // Habilitar Instant Placement en la sesión AR para detectar
        // cualquier superficie sin necesitar feature points ni planos mapeados.
        // Esto soluciona el error "No point hit" del log.
        arFragment.arSceneView.session?.let { session ->
            val config = session.config
            config.instantPlacementMode = Config.InstantPlacementMode.LOCAL_Y_UP
            // Aseguramos que el modo de actualización sea más responsivo
            config.updateMode = Config.UpdateMode.LATEST_CAMERA_IMAGE
            session.configure(config)
            Log.d("LOG_AR", "Instant Placement habilitado correctamente.")
        }

        // Initial UI update
        updateUIForState()

        // Optional: Add a listener to ARCore session to update UI when tracking state changes
        arFragment.arSceneView.scene.addOnUpdateListener {
            val frame = arFragment.arSceneView.arFrame
            if (frame != null && frame.camera.trackingState == TrackingState.TRACKING) {
                // If we are tracking, enable buttons if not already placed
                if (puntoA == null || puntoB == null) {
                    placePointAButton.isEnabled = true
                    placePointBButton.isEnabled = true
                }
            } else {
                // If not tracking, disable buttons
                placePointAButton.isEnabled = false
                placePointBButton.isEnabled = false
                if (frame != null && frame.camera.trackingState == TrackingState.PAUSED) {
                    instructionTextView.text = "Mueve el dispositivo para iniciar el seguimiento AR."
                } else if (frame != null && frame.camera.trackingState == TrackingState.STOPPED) {
                    instructionTextView.text = "Seguimiento AR detenido. Reinicia la app."
                }
            }
        }
    }

    private fun updateUIForState() {
        if (puntoA == null) {
            placePointAButton.visibility = View.VISIBLE
            placePointBButton.visibility = View.GONE
            confirmButton.visibility = View.GONE
            resetButton.visibility = View.GONE
            instructionTextView.text = if (modo == "altura") "Presiona 'Colocar Punto A' en la base del árbol" else "Presiona 'Colocar Punto A' en un extremo del tronco"
        } else if (puntoB == null) {
            placePointAButton.visibility = View.GONE
            placePointBButton.visibility = View.VISIBLE
            confirmButton.visibility = View.GONE
            resetButton.visibility = View.GONE
            instructionTextView.text = if (modo == "altura") "Presiona 'Colocar Punto B' en la punta del árbol" else "Presiona 'Colocar Punto B' en el otro extremo del tronco"
        } else {
            // Both points placed, show confirmation/reset options
            placePointAButton.visibility = View.GONE
            placePointBButton.visibility = View.GONE
            confirmButton.visibility = View.VISIBLE
            resetButton.visibility = View.VISIBLE

            // Calculamos el valor para mostrarlo en el panel inferior antes de confirmar
            val valorMetros = if (modo == "altura") calcularAltura() else calcularDistancia()
            val unidad = if (modo == "diametro") "cm" else "m"
            val valorDisplay = if (modo == "diametro") valorMetros * 100 else valorMetros

            instructionTextView.text = "Resultado: ${"%.2f".format(valorDisplay)} $unidad\n¿Desea confirmar esta medición?"
        }
    }

    private fun tryPlacePointAtCenter() {
        val frame = arFragment.arSceneView.arFrame
        if (frame == null) {
            Log.w("LOG_AR", "Frame nulo al intentar colocar punto.")
            Toast.makeText(this, "Cámara AR no lista. Intenta de nuevo.", Toast.LENGTH_SHORT).show()
            return
        }

        val camera = frame.camera
        if (camera.trackingState != TrackingState.TRACKING) {
            Log.w("LOG_AR", "Cámara no en TRACKING. Estado: ${camera.trackingState}")
            Toast.makeText(this, "Escanee el entorno para iniciar el seguimiento AR.", Toast.LENGTH_SHORT).show()
            return
        }

        val centerX = arFragment.arSceneView.width / 2f
        val centerY = arFragment.arSceneView.height / 2f

        // --- INTENTO 1: Hit test normal (Planos y Feature Points) ---
        val hits = frame.hitTest(centerX, centerY)
        Log.d("LOG_AR", "Hit test normal (centro) devolvió ${hits.size} resultados.")
        for (hit in hits) {
            val trackable = hit.trackable

            // Si estamos midiendo altura y ya tenemos el punto A (base),
            // evitamos capturar el mismo plano del suelo para la punta del árbol.
            val esPlanoSuelo = trackable is Plane &&
                    trackable.type == Plane.Type.HORIZONTAL_UPWARD_FACING &&
                    puntoA != null && modo == "altura"

            if (!esPlanoSuelo && (
                (trackable is Plane && trackable.isPoseInPolygon(hit.hitPose) && trackable.trackingState == TrackingState.TRACKING) ||
                (trackable is Point && trackable.trackingState == TrackingState.TRACKING) ||
                (trackable is InstantPlacementPoint)
            )) {
                Log.d("LOG_AR", "Punto capturado mediante: ${trackable.javaClass.simpleName} en el centro.")
                manejarTap(hit)
                return
            }
        }

        // --- INTENTO 2: Instant Placement ---
        val distanciaEstimada = calcularDistanciaEstimada()
        Log.d("LOG_AR", "Intentando Instant Placement (centro) con distancia estimada: $distanciaEstimada m")

        val instantHits = frame.hitTestInstantPlacement(
            centerX,
            centerY,
            distanciaEstimada
        )
        Log.d("LOG_AR", "Instant Placement (centro) devolvió ${instantHits.size} resultados.")

        if (instantHits.isNotEmpty()) {
            Log.d("LOG_AR", "Hit exitoso vía Instant Placement en el centro.")
            manejarTap(instantHits[0])
            return
        }

        // Sin resultado en ninguno de los métodos
        Log.d("LOG_AR", "Sin hit detectado en el centro con ningún método.")
        Toast.makeText(this, "No se detectó superficie en el centro. Mueve la cámara y escanea el área.", Toast.LENGTH_SHORT).show()
    }

    /**
     * Calcula la distancia estimada al objeto que se va a tocar.
     * Para árboles:
     * - En modo altura, la base suele estar cerca (~1m) y la punta puede estar a varios metros.
     * - En modo diámetro, el tronco suele estar a ~1-2m de distancia.
     */
    private fun calcularDistanciaEstimada(): Float {
        return when (modo) {
            "altura" -> if (puntoA == null) 1.2f else 2.5f // Ajustado para mayor precisión en distancias cortas
            "diametro" -> 1.5f
            else -> 2.0f
        }
    }

    private fun manejarTap(hitResult: HitResult) {
        val anchor = hitResult.createAnchor()
        val pose = anchor.pose
        Log.d("LOG_AR", "Tap detectado en Y: ${pose.ty()}, X: ${pose.tx()}, Z: ${pose.tz()}")

        if (puntoA == null) {
            puntoA = anchor
            anchorNodeA = crearEsfera(anchor, Color.RED)
            val instruccion = if (modo == "altura") "Punto base fijado. Ahora toque la punta del árbol"
                              else "Punto inicial fijado. Toque el otro extremo del tronco"
            Toast.makeText(this, instruccion, Toast.LENGTH_SHORT).show()

        } else if (puntoB == null) {
            val poseA = puntoA!!.pose
            val poseB = anchor.pose

            // Validaciones para evitar mediciones sin sentido
            if (modo == "altura") {
                // Margen de 5cm para compensar ruido de sensores
                if (poseB.ty() < poseA.ty() - 0.05f) {
                    Toast.makeText(this, "El segundo punto debe estar más alto que la base.", Toast.LENGTH_SHORT).show()
                    anchor.detach()
                    return
                }

                // Si la altura es casi cero (como en tu log), avisar al usuario
                if (Math.abs(poseA.ty() - poseB.ty()) < 0.01f) {
                    Toast.makeText(this, "Altura muy baja. Asegúrate de apuntar a la punta del objeto.", Toast.LENGTH_LONG).show()
                }

            } else {
                if (Math.abs(poseA.ty() - poseB.ty()) > 0.25f) {
                    Toast.makeText(this, "Mantén los puntos a una altura similar para medir el diámetro.", Toast.LENGTH_SHORT).show()
                    anchor.detach()
                    return
                }
            }

            puntoB = anchor
            anchorNodeB = crearEsfera(anchor, Color.BLUE)

            if (modo == "altura") {
                dibujarLineaVertical(puntoA!!, puntoB!!)
                calcularAltura()
            } else {
                dibujarLineaDirecta(puntoA!!, puntoB!!)
                calcularDistancia()
            }

        } else {
            // Ya hay dos puntos: resetear e iniciar nueva medición
            resetear()
            puntoA = anchor
            anchorNodeA = crearEsfera(anchor, Color.RED)
            val instruccion = if (modo == "altura") "Nueva base fijada. Toque la punta del árbol"
                              else "Nueva medición iniciada. Toque el otro extremo"
            Toast.makeText(this, instruccion, Toast.LENGTH_SHORT).show()
        }
        updateUIForState()
    }

    private fun crearEsfera(anchor: Anchor, color: Int): AnchorNode {
        val anchorNode = AnchorNode(anchor)
        anchorNode.setParent(arFragment.arSceneView.scene)

        MaterialFactory.makeOpaqueWithColor(
            this,
            com.google.ar.sceneform.rendering.Color(color)
        ).thenAccept { material ->
            val sphere = ShapeFactory.makeSphere(0.03f, Vector3.zero(), material)
            val node = Node()
            node.renderable = sphere
            anchorNode.addChild(node)
        }
        return anchorNode
    }

    private fun dibujarLineaVertical(anchorA: Anchor, anchorB: Anchor) {
        val poseA = anchorA.pose
        val poseB = anchorB.pose

        val yMin = minOf(poseA.ty(), poseB.ty())
        val yMax = maxOf(poseA.ty(), poseB.ty())
        val altura = yMax - yMin

        val center = Vector3(poseA.tx(), yMin + altura / 2f, poseA.tz())

        MaterialFactory.makeOpaqueWithColor(
            this,
            com.google.ar.sceneform.rendering.Color(Color.GREEN)
        ).thenAccept { material ->
            val cylinder = ShapeFactory.makeCylinder(0.01f, altura, Vector3.zero(), material)
            val node = Node()
            node.renderable = cylinder
            node.worldPosition = center
            lineaNode = node
            arFragment.arSceneView.scene.addChild(node)
        }
    }

    private fun dibujarLineaDirecta(anchorA: Anchor, anchorB: Anchor) {
        val poseA = anchorA.pose
        val poseB = anchorB.pose

        val vectorA = Vector3(poseA.tx(), poseA.ty(), poseA.tz())
        val vectorB = Vector3(poseB.tx(), poseB.ty(), poseB.tz())
        val difference = Vector3.subtract(vectorA, vectorB)
        val distance = difference.length()
        val center = Vector3.add(vectorA, vectorB).scaled(0.5f)

        MaterialFactory.makeOpaqueWithColor(
            this,
            com.google.ar.sceneform.rendering.Color(Color.CYAN)
        ).thenAccept { material ->
            val cylinder = ShapeFactory.makeCylinder(0.008f, distance, Vector3.zero(), material)
            val node = Node()
            node.renderable = cylinder
            node.worldPosition = center

            // Orientar el cilindro en la dirección correcta entre los dos puntos
            val direction = Vector3.subtract(vectorA, vectorB).normalized()
            node.worldRotation = com.google.ar.sceneform.math.Quaternion.lookRotation(
                direction,
                Vector3.up()
            )

            lineaNode = node
            arFragment.arSceneView.scene.addChild(node)
        }
    }

    private fun calcularAltura(): Float {
        val a = puntoA!!.pose
        val b = puntoB!!.pose
        val altura = kotlin.math.abs(a.ty() - b.ty())
        Log.d("LOG_AR", "Altura calculada: $altura m")
        mostrarDistancia(puntoA!!, puntoB!!, altura)
        return altura
    }

    private fun calcularDistancia(): Float {
        val a = puntoA!!.pose
        val b = puntoB!!.pose
        val dx = a.tx() - b.tx()
        val dy = a.ty() - b.ty()
        val dz = a.tz() - b.tz()
        val distancia = sqrt((dx * dx + dy * dy + dz * dz).toDouble()).toFloat()
        Log.d("LOG_AR", "Distancia calculada: $distancia m")
        mostrarDistancia(puntoA!!, puntoB!!, distancia)
        return distancia
    }

    private fun mostrarDistancia(anchorA: Anchor, anchorB: Anchor, distancia: Float) {
        val poseA = anchorA.pose
        val poseB = anchorB.pose

        // Formatear el texto según el modo (metros o centímetros)
        val valorAMostrar = if (modo == "diametro") distancia * 100 else distancia
        val unidad = if (modo == "diametro") "cm" else "m"

        val center = Vector3(
            (poseA.tx() + poseB.tx()) / 2f,
            (poseA.ty() + poseB.ty()) / 2f + 0.15f, // un poco arriba de la línea
            (poseA.tz() + poseB.tz()) / 2f
        )

        val textView = TextView(this).apply {
            text = "${"%.2f".format(valorAMostrar)} $unidad"
            setTextColor(Color.WHITE)
            setBackgroundColor(Color.parseColor("#CC000000"))
            textSize = 16f
            setPadding(24, 12, 24, 12)
        }

        ViewRenderable.builder()
            .setView(this, textView)
            .build()
            .thenAccept { renderable ->
                textoNode?.setParent(null) // limpiar etiqueta anterior si existe
                val node = Node()
                node.renderable = renderable
                node.worldPosition = center
                textoNode = node
                arFragment.arSceneView.scene.addChild(node)
            }
            .exceptionally { throwable ->
                Log.e("LOG_AR", "Error al crear ViewRenderable: ${throwable.message}")
                null
            }
    }

    private fun resetear() {
        Log.d("LOG_AR", "Reseteando medición.")

        puntoA?.detach()
        puntoB?.detach()
        puntoA = null
        puntoB = null

        anchorNodeA?.setParent(null)
        anchorNodeB?.setParent(null)
        anchorNodeA = null
        anchorNodeB = null

        lineaNode?.setParent(null)
        lineaNode = null

        textoNode?.setParent(null)
        textoNode = null
        updateUIForState()
    }
}