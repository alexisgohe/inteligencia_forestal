import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/action_bar_widget.dart';
import './widgets/module_card_widget.dart';
import './widgets/stats_dialog_widget.dart';
import './widgets/welcome_message_widget.dart';

import '/forms/gestion_forestal_form.dart';

/// Main Menu Screen - Primary navigation hub for Intenigencia Forestal
/// Provides access to Forest Management and Forest Health modules
/// Optimized for field use with large touch targets and offline capabilities
class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  // Mock data for demonstration
  int _forestManagementRecords = 0;
  int _forestHealthRecords = 0;
  bool _isSynced = true;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadRecordCounts();
  }

  /// Load record counts from local database (simulated)
  Future<void> _loadRecordCounts() async {
    // Simulate database query
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _forestManagementRecords = 0;
      _forestHealthRecords = 0;
    });
  }

  /// Refresh record counts and sync status
  Future<void> _refreshData() async {
    setState(() => _isRefreshing = true);

    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isRefreshing = false;
      _isSynced = true;
    });

    Fluttertoast.showToast(
      msg: "Datos actualizados",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  /// Handle export data action
  void _handleExportData() {
    final totalRecords = _forestManagementRecords + _forestHealthRecords;

    if (totalRecords == 0) {
      Fluttertoast.showToast(
        msg: "No hay registros para exportar",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => _buildExportDialog(),
    );
  }

  /// Handle sync action
  void _handleSync() {
    Fluttertoast.showToast(
      msg: _isSynced ? "Datos sincronizados" : "Sincronizando datos...",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );

    if (!_isSynced) {
      setState(() => _isSynced = true);
    }
  }

  /// Show module statistics dialog
  void _showModuleStats({
    required String moduleTitle,
    required int recordCount,
  }) {
    showDialog(
      context: context,
      builder: (context) => StatsDialogWidget(
        moduleTitle: moduleTitle,
        totalRecords: recordCount,
        lastEntryDate: recordCount > 0 ? '03/12/2025' : 'Sin registros',
        storageUsage: recordCount > 0
            ? '${(recordCount * 0.5).toStringAsFixed(1)} MB'
            : '0 MB',
      ),
    );
  }

  /// Navigate to Forest Management module
  void _navigateToForestManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const GestionForestalForm(),
      ),
    );
  }

  /// Navigate to Forest Health module
void _navigateToForestHealth() {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Módulo en desarrollo'),
      backgroundColor: Colors.orange,
    ),
  );
  // Navigator.pushNamed(context, '/records-list-screen');
}

  /// Navigate to settings
  void _navigateToSettings() {
    Fluttertoast.showToast(
      msg: "Configuración próximamente",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalRecords = _forestManagementRecords + _forestHealthRecords;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Intenigencia Forestal',
          style: theme.appBarTheme.titleTextStyle,
        ),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: _navigateToSettings,
            icon: CustomIconWidget(
              iconName: 'settings',
              color: theme.appBarTheme.foregroundColor ??
                  theme.colorScheme.onPrimary,
              size: 6.w,
            ),
            tooltip: 'Configuración',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 2.h),

                // Welcome message for new users
                if (totalRecords == 0) const WelcomeMessageWidget(),

                // Module cards
                SizedBox(height: 2.h),
                ModuleCardWidget(
                  title: 'Gestión Forestal',
                  description:
                      'Registra inventarios de árboles con mediciones de diámetro, altura y cálculos automáticos de volumen.',
                  iconName: 'forest',
                  recordCount: _forestManagementRecords,
                  lastEntryDate: _forestManagementRecords > 0
                      ? '03/12/2025'
                      : null,
                  onTap: _navigateToForestManagement,
                  onLongPress: () => _showModuleStats(
                    moduleTitle: 'Gestión Forestal',
                    recordCount: _forestManagementRecords,
                  ),
                ),

                ModuleCardWidget(
                  title: 'Salud Forestal',
                  description:
                      'Evalúa el estado sanitario de los árboles, registra daños y niveles de intensidad.',
                  iconName: 'health_and_safety',
                  recordCount: _forestHealthRecords,
                  lastEntryDate: _forestHealthRecords > 0 ? '03/12/2025' : null,
                  onTap: _navigateToForestHealth,
                  onLongPress: () => _showModuleStats(
                    moduleTitle: 'Salud Forestal',
                    recordCount: _forestHealthRecords,
                  ),
                ),

                SizedBox(height: 10.h),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: ActionBarWidget(
        totalRecords: totalRecords,
        isSynced: _isSynced,
        onExportTap: _handleExportData,
        onSyncTap: _handleSync,
      ),
    );
  }

  /// Build export dialog
  Widget _buildExportDialog() {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Container(
        padding: EdgeInsets.all(5.w),
        constraints: BoxConstraints(
          maxWidth: 80.w,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Exportar Datos',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontSize: 16.sp,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: CustomIconWidget(
                    iconName: 'close',
                    color: theme.colorScheme.onSurface,
                    size: 5.w,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Text(
              'Selecciona el formato de exportación:',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 13.sp,
              ),
            ),
            SizedBox(height: 3.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  Fluttertoast.showToast(
                    msg: "Exportando a Excel...",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                  );
                },
                icon: CustomIconWidget(
                  iconName: 'table_chart',
                  color: theme.colorScheme.onPrimary,
                  size: 5.w,
                ),
                label: Text(
                  'Exportar a Excel (XLSX)',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontSize: 13.sp,
                  ),
                ),
              ),
            ),
            SizedBox(height: 2.h),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Cancelar',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontSize: 13.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
