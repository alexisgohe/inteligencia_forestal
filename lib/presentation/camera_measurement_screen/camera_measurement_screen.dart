import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

class CameraMeasurementScreen extends StatefulWidget {
  const CameraMeasurementScreen({super.key});

  @override
  State<CameraMeasurementScreen> createState() => _CameraMeasurementScreenState();
}

class _CameraMeasurementScreenState extends State<CameraMeasurementScreen> {
  static const platform = MethodChannel('ar_measure_channel');
  String? _modo;
  double _medicionActual = 0.0;
  bool _isOpeningAR = false;
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    // Inicia la cámara automáticamente después del primer frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isFirstLoad) _abrirAR();
      _isFirstLoad = false;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _modo = ModalRoute.of(context)?.settings.arguments as String?;
  }

  Future<void> _abrirAR() async {
    if (_isOpeningAR) return;
    setState(() => _isOpeningAR = true);
    try {
      final dynamic result = await platform.invokeMethod('openAR', {'modo': _modo});
      
      if (mounted) {
        if (result != null && result is double) {
          double valorFinal = _modo == 'diametro' ? result * 100 : result;
          // Retornamos el valor directamente y cerramos esta pantalla puente
          Navigator.pop(context, valorFinal);
        } else {
          // Si el resultado es null (usuario canceló en Android), cerramos sin valor
          Navigator.pop(context);
        }
      }
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error AR: ${e.message}")),
      );
    } finally {
      if (mounted) setState(() => _isOpeningAR = false);
    }
  }

  void _resetMedicion() {
    setState(() => _medicionActual = 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final String titulo =
        _modo == 'diametro' ? 'Medir Diámetro' : 'Medir Altura';

    return Scaffold(
      appBar: AppBar(
        title: Text(titulo),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // UI de estado
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_medicionActual == 0)
                  const CircularProgressIndicator(color: Colors.white54)
                else
                  Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                    size: 80.sp,
                  ),
                SizedBox(height: 2.h),
                Text(
                  _medicionActual > 0
                      ? "¡Medición capturada!"
                      : "Iniciando cámara AR...",
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          
          Positioned(
            bottom: 5.h,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  '${_medicionActual.toStringAsFixed(2)} ${_modo == 'diametro' ? 'cm' : 'm'}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 3.h),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      onPressed: _abrirAR,
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                      child: Text(_medicionActual > 0
                          ? 'Repetir Medida'
                          : 'Reintentar'),
                    ),
                    ElevatedButton(
                      onPressed: _medicionActual > 0
                          ? () => Navigator.pop(context, _medicionActual)
                          : null,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700]),
                      child: const Text('Confirmar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}