import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';
import '../models/registro_forestal.dart';
import '../services/database_service.dart';

class ListaRegistrosScreen extends StatefulWidget {
  const ListaRegistrosScreen({Key? key}) : super(key: key);

  @override
  State<ListaRegistrosScreen> createState() => _ListaRegistrosScreenState();
}

class _ListaRegistrosScreenState extends State<ListaRegistrosScreen> {
  List<RegistroForestal> _registros = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarRegistros();
  }

  Future<void> _cargarRegistros() async {
    setState(() => _isLoading = true);
    
    try {
      final registros = await DatabaseService.instance.obtenerTodosLosRegistros();
      setState(() {
        _registros = registros;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar registros: $e'),
          backgroundColor: Colors.red[700],
        ),
      );
    }
  }

  Future<void> _eliminarRegistro(int id, String especieNombre) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de eliminar el registro de "$especieNombre"?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        await DatabaseService.instance.eliminarRegistro(id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Registro eliminado'),
            backgroundColor: Colors.green[700],
          ),
        );
        _cargarRegistros();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar: $e'),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    }
  }

  void _verDetalles(RegistroForestal registro) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildDetallesSheet(registro),
    );
  }

  Widget _buildDetallesSheet(RegistroForestal registro) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: EdgeInsets.all(4.w),
          child: ListView(
            controller: scrollController,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: EdgeInsets.only(bottom: 2.h),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Título
              Row(
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
                      size: 28,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          registro.especieNombreComun,
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        Text(
                          'Árbol #${registro.numeroArbol}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 3.h),

              // Información general
              _buildSeccion('Información General', [
                _buildDetalle('Número de sitio', registro.numeroSitio, Icons.location_on),
                _buildDetalle('Número de árbol', registro.numeroArbol, Icons.tag),
                _buildDetalle('Fecha de registro', dateFormat.format(registro.fechaRegistro), Icons.calendar_today),
              ]),

              // Mediciones
              _buildSeccion('Mediciones', [
                _buildDetalle('Diámetro', '${registro.diametroNormal} cm', Icons.straighten),
                _buildDetalle('Altura total', '${registro.alturaTotal} m', Icons.height),
                if (registro.diametroTocon != null)
                  _buildDetalle('Diámetro del tocón', '${registro.diametroTocon} cm', Icons.straighten),
                if (registro.diametroCopa != null)
                  _buildDetalle('Diámetro de copa', '${registro.diametroCopa} m', Icons.forest),
              ]),

              // Cálculos
              _buildSeccion('Cálculos', [
                _buildDetalleDestacado('Área basal', '${registro.areaBasal} m²', Colors.blue),
                _buildDetalleDestacado('Volumen del cilindro', '${registro.volumenCilindro} m³', Colors.purple),
              ]),

              // Estado
              // if (registro.estadoFitosanitario != null || registro.dano != null || registro.vigorosidad != null)
              //   _buildSeccion('Estado del Árbol', [
              //     if (registro.estadoFitosanitario != null)
              //       _buildDetalle('Estado fitosanitario', registro.estadoFitosanitario!, Icons.health_and_safety),
              //     if (registro.dano != null)
              //       _buildDetalle('Daño', registro.dano!, Icons.warning),
              //     if (registro.vigorosidad != null)
              //       _buildDetalle('Vigorosidad', registro.vigorosidad!, Icons.trending_up),
              //   ]),

              SizedBox(height: 2.h),

              // Botón cerrar
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[700],
                  padding: EdgeInsets.symmetric(vertical: 1.5.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Cerrar'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSeccion(String titulo, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 1.h),
        Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: children,
          ),
        ),
        SizedBox(height: 2.h),
      ],
    );
  }

  Widget _buildDetalle(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.8.h),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          SizedBox(width: 2.w),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[600],
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetalleDestacado(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(2.w),
      margin: EdgeInsets.only(bottom: 1.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.calculate, size: 20, color: color),
          SizedBox(width: 2.w),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: const Text('Registros Forestales'),
        backgroundColor: Colors.green[700],
        actions: [
          IconButton(
            onPressed: _cargarRegistros,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _registros.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _cargarRegistros,
                  child: ListView.builder(
                    padding: EdgeInsets.all(3.w),
                    itemCount: _registros.length,
                    itemBuilder: (context, index) {
                      final registro = _registros[index];
                      return _buildRegistroCard(registro);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.forest_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 2.h),
          Text(
            'No hay registros',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Comienza agregando tu primer árbol',
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegistroCard(RegistroForestal registro) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    
    return Card(
      margin: EdgeInsets.only(bottom: 2.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 2,
      child: InkWell(
        onTap: () => _verDetalles(registro),
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: EdgeInsets.all(3.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.park,
                      color: Colors.green[700],
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          registro.especieNombreComun,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        Text(
                          'Sitio ${registro.numeroSitio} - Árbol ${registro.numeroArbol}',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _eliminarRegistro(
                      registro.id!,
                      registro.especieNombreComun,
                    ),
                    icon: Icon(Icons.delete, color: Colors.red[400]),
                    tooltip: 'Eliminar',
                  ),
                ],
              ),

              SizedBox(height: 2.h),

              // Mediciones principales
              Row(
                children: [
                  Expanded(
                    child: _buildMiniInfo(
                      'Diámetro',
                      '${registro.diametroNormal} cm',
                      Icons.straighten,
                      Colors.blue,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: _buildMiniInfo(
                      'Altura',
                      '${registro.alturaTotal} m',
                      Icons.height,
                      Colors.orange,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 1.5.h),

              // Cálculos
              Row(
                children: [
                  Expanded(
                    child: _buildMiniInfo(
                      'Área basal',
                      '${registro.areaBasal} m²',
                      Icons.calculate,
                      Colors.purple,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: _buildMiniInfo(
                      'Volumen',
                      '${registro.volumenCilindro} m³',
                      Icons.calculate,
                      Colors.teal,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 1.5.h),

              // Footer
              Divider(color: Colors.grey[300]),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                      SizedBox(width: 1.w),
                      Text(
                        dateFormat.format(registro.fechaRegistro),
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: () => _verDetalles(registro),
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('Ver detalles'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.green[700],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniInfo(String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              SizedBox(width: 1.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 0.5.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}