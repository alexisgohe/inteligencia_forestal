import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:sizer/sizer.dart';
import '../models/registro_forestal.dart';
import '../services/database_service.dart';

class GestionForestalForm extends StatefulWidget {
  const GestionForestalForm({Key? key}) : super(key: key);

  @override
  State<GestionForestalForm> createState() => _GestionForestalFormState();
}

class _GestionForestalFormState extends State<GestionForestalForm> {
  final _formKey = GlobalKey<FormState>();
  
  // Controladores para los campos
  final _numeroSitioController = TextEditingController();
  final _numeroArbolController = TextEditingController();
  final _especieController = TextEditingController();
  final _diametroToconController = TextEditingController();
  final _diametroNormalController = TextEditingController();
  final _alturaTotalController = TextEditingController();
  final _diametroCopaController = TextEditingController();
  final _areaBasalController = TextEditingController();
  final _volumenCilindroController = TextEditingController();
  
  // String? _estadoFitosanitario;
  String? _dano;
  String? _vigorosidad;

  @override
  void initState() {
    super.initState();
    
    // Listeners para cálculos automáticos
    _diametroNormalController.addListener(_calcularAreaBasal);
    _alturaTotalController.addListener(_calcularVolumen);
  }

  @override
  void dispose() {
    _numeroSitioController.dispose();
    _numeroArbolController.dispose();
    _especieController.dispose();
    _diametroToconController.dispose();
    _diametroNormalController.dispose();
    _alturaTotalController.dispose();
    _diametroCopaController.dispose();
    _areaBasalController.dispose();
    _volumenCilindroController.dispose();
    super.dispose();
  }

  // Calcular área basal automáticamente
  void _calcularAreaBasal() {
    final diametro = double.tryParse(_diametroNormalController.text);
    
    if (diametro != null && diametro > 0) {
      // Fórmula: ((Diámetro/100)^2) * 0.7854
      final areaBasal = ((diametro / 100) * (diametro / 100)) * 0.7854;
      _areaBasalController.text = areaBasal.toStringAsFixed(2);
      
      // Recalcular volumen si ya hay altura
      _calcularVolumen();
    } else {
      _areaBasalController.text = '';
      _volumenCilindroController.text = '';
    }
  }

  // Calcular volumen del cilindro automáticamente
  void _calcularVolumen() {
    final areaBasal = double.tryParse(_areaBasalController.text);
    final altura = double.tryParse(_alturaTotalController.text);
    
    if (areaBasal != null && altura != null && areaBasal > 0 && altura > 0) {
      final volumen = areaBasal * altura;
      _volumenCilindroController.text = volumen.toStringAsFixed(2);
    } else {
      _volumenCilindroController.text = '';
    }
  }

  void _guardarRegistro() async {
  if (_formKey.currentState!.validate()) {
    try {
      final registro = RegistroForestal(
        id: const Uuid().v4(),
        numeroSitio: _numeroSitioController.text,
        numeroArbol: _numeroArbolController.text,
        especieNombreComun: _especieController.text,
        diametroTocon: double.tryParse(_diametroToconController.text),
        diametroNormal: double.parse(_diametroNormalController.text),
        alturaTotal: double.parse(_alturaTotalController.text),
        diametroCopa: double.tryParse(_diametroCopaController.text),
        // estadoFitosanitario: _estadoFitosanitario, -- este se va a trabajar luego
        dano: _dano,
        vigorosidad: _vigorosidad,
        areaBasal: double.parse(_areaBasalController.text),
        volumenCilindro: double.parse(_volumenCilindroController.text),
        fechaRegistro: DateTime.now(),
      );

      await DatabaseService.instance.insertarRegistro(registro);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 10),
              const Text('Registro guardado exitosamente'),
            ],
          ),
          backgroundColor: Colors.green[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      Navigator.pop(context, true);
      // Marcar que hubo cambios
        // setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar: $e'),
          backgroundColor: Colors.red[700],
        ),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: Text(
          'Gestión Forestal - Nuevo Registro',
          style: theme.appBarTheme.titleTextStyle,
        ),
        // backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.park,
                        color: Colors.green[700],
                        size: 30,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Registro de Inventario',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          Text(
                            'Complete todos los campos requeridos',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 3.h),

              // Campos del formulario
              _buildTextField(
                controller: _numeroSitioController,
                label: 'Número de sitio',
                hint: 'Ej: 001',
                icon: Icons.location_on,
              ),

              _buildTextField(
                controller: _numeroArbolController,
                label: 'Número de árbol',
                hint: 'Ej: 101',
                icon: Icons.tag,
              ),

              _buildTextField(
                controller: _especieController,
                label: 'Especie o nombre común',
                hint: 'Ej: Pino, Roble, Cedro',
                icon: Icons.eco,
                required: true,
              ),

              _buildTextField(
                controller: _diametroToconController,
                label: 'Diámetro del tocón (cm)',
                hint: 'Ej: 25.5',
                icon: Icons.straighten,
                isNumber: true,
              ),

              _buildTextField(
                controller: _diametroNormalController,
                label: 'Diámetro (cm) *',
                hint: 'Ej: 26',
                icon: Icons.straighten,
                isNumber: true,
                required: true,
                isHighlighted: true,
                helperText: 'Se usa para calcular el área basal',
              ),

              _buildTextField(
                controller: _alturaTotalController,
                label: 'Altura total (m) *',
                hint: 'Ej: 15.5',
                icon: Icons.height,
                isNumber: true,
                required: true,
                isHighlighted: true,
                helperText: 'Se usa para calcular el volumen',
              ),

              _buildTextField(
                controller: _diametroCopaController,
                label: 'Diámetro de copa (m)',
                hint: 'Ej: 8.5',
                icon: Icons.forest,
                isNumber: true,
              ),

              // _buildDropdown(
              //   value: _estadoFitosanitario,
              //   label: 'Estado fitosanitario',
              //   hint: 'Seleccionar...',
              //   icon: Icons.health_and_safety,
              //   items: ['Sano', 'Enfermo', 'Plagado', 'Muerto'],
              //   onChanged: (value) => setState(() => _estadoFitosanitario = value),
              // ),

              _buildDropdown(
                value: _dano,
                label: 'Daño',
                hint: 'Seleccionar...',
                icon: Icons.warning,
                items: ['Ninguno', 'Leve', 'Moderado', 'Severo'],
                onChanged: (value) => setState(() => _dano = value),
              ),

              _buildDropdown(
                value: _vigorosidad,
                label: 'Vigorosidad',
                hint: 'Seleccionar...',
                icon: Icons.trending_up,
                items: ['Alta', 'Media', 'Baja'],
                onChanged: (value) => setState(() => _vigorosidad = value),
              ),

              // Sección de cálculos automáticos
              SizedBox(height: 2.h),
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.blue[300]!, width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calculate, color: Colors.blue[700], size: 24),
                        SizedBox(width: 2.w),
                        Text(
                          'Cálculos automáticos',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),

                    _buildCalculatedField(
                      controller: _areaBasalController,
                      label: 'Área basal (m²)',
                      formula: 'Fórmula: ((Diámetro/100)²) × 0.7854',
                    ),

                    SizedBox(height: 2.h),

                    _buildCalculatedField(
                      controller: _volumenCilindroController,
                      label: 'Volumen del cilindro (m³)',
                      formula: 'Fórmula: Área basal × Altura total',
                    ),
                  ],
                ),
              ),

              SizedBox(height: 3.h),

              // Botón de guardar
              ElevatedButton.icon(
                onPressed: _guardarRegistro,
                icon: const Icon(Icons.save),
                label: Text(
                  'Guardar Registro',
                  style: TextStyle(fontSize: 14.sp),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                ),
              ),

              SizedBox(height: 2.h),

              // Nota informativa
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.amber[300]!),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: Colors.amber[800], size: 20),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        'Los campos marcados con (*) son obligatorios. Los cálculos se realizan automáticamente al ingresar el diámetro y la altura.',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.amber[900],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isNumber = false,
    bool required = false,
    bool isHighlighted = false,
    String? helperText,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 1.h),
          TextFormField(
            controller: controller,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon, color: isHighlighted ? Colors.green[700] : Colors.grey[600]),
              filled: true,
              fillColor: isHighlighted ? Colors.green[50] : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isHighlighted ? Colors.green[400]! : Colors.grey[300]!,
                  width: 2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isHighlighted ? Colors.green[400]! : Colors.grey[300]!,
                  width: 2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.green[700]!,
                  width: 2,
                ),
              ),
              helperText: helperText,
              helperStyle: TextStyle(
                fontSize: 10.sp,
                color: Colors.grey[600],
              ),
            ),
            validator: required
                ? (value) {
                    if (value == null || value.isEmpty) {
                      return 'Este campo es obligatorio';
                    }
                    if (isNumber && double.tryParse(value) == null) {
                      return 'Ingresa un número válido';
                    }
                    return null;
                  }
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String label,
    required String hint,
    required IconData icon,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 1.h),
          DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon, color: Colors.grey[600]),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!, width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!, width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.green[700]!, width: 2),
              ),
            ),
            items: items.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildCalculatedField({
    required TextEditingController controller,
    required String label,
    required String formula,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
            color: Colors.blue[900],
          ),
        ),
        SizedBox(height: 0.5.h),
        TextField(
          controller: controller,
          readOnly: true,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.bold,
            color: Colors.blue[900],
            fontFamily: 'monospace',
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.blue[300]!, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.blue[300]!, width: 2),
            ),
            hintText: 'Se calcula automáticamente',
            hintStyle: TextStyle(
              fontSize: 11.sp,
              color: Colors.grey[400],
            ),
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          formula,
          style: TextStyle(
            fontSize: 10.sp,
            color: Colors.blue[700],
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}