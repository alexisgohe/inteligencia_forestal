import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';

/// Splash screen for Intenigencia Forestal application
/// Handles app initialization, permission requests, and navigation
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _permissionsGranted = false;
  String _statusMessage = 'Inicializando...';
  bool _initializationComplete = false;
  bool _errorOccurred = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
    _initializeApp();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Initialize logo scale animation
  void _initializeAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.repeat(reverse: true);
  }

  /// Initialize app services and request permissions with error handling
  Future<void> _initializeApp() async {
    try {
      // 1. Intento de inicialización básica
      await _performInitialization();
      
      // 2. Manejar permisos (con reintentos y tolerancia a fallos)
      await _handlePermissions();
      
      // 3. Completar inicialización
      await _completeInitialization();
      
    } catch (e) {
      // Registrar error pero continuar
      print('Error durante inicialización: $e');
      setState(() {
        _errorOccurred = true;
        _statusMessage = 'Inicialización con advertencias';
      });
      
      // Esperar un momento y navegar de todos modos
      await Future.delayed(const Duration(seconds: 1));
      _navigateToMainMenu();
    }
  }

  /// Perform basic app initialization
  Future<void> _performInitialization() async {
    try {
      // Simulate database initialization
      setState(() => _statusMessage = 'Inicializando base de datos...');
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Puedes agregar aquí otras inicializaciones críticas
      // Ejemplo: inicializar Firebase, configuraciones, etc.
      
    } catch (e) {
      // Continuar incluso si hay errores en la inicialización
      print('Error en inicialización básica: $e');
      // No re-lanzamos la excepción, continuamos
    }
  }

  /// Handle permissions with graceful degradation
  Future<void> _handlePermissions() async {
    try {
      setState(() => _statusMessage = 'Verificando permisos...');
      
      // Intentar obtener permisos con reintento
      bool permissionsGranted = false;
      int retryCount = 0;
      const maxRetries = 2;
      
      while (retryCount < maxRetries && !permissionsGranted) {
        permissionsGranted = await _requestPermissionsWithFallback();
        retryCount++;
        
        if (!permissionsGranted && retryCount < maxRetries) {
          await Future.delayed(const Duration(milliseconds: 500));
          setState(() => _statusMessage = 'Reintentando permisos...');
        }
      }
      
      setState(() {
        _permissionsGranted = permissionsGranted;
        _statusMessage = permissionsGranted
            ? 'Preparando aplicación...'
            : 'Continuando con permisos limitados';
      });
      
      // Si no se obtuvieron permisos, mostrar advertencia pero continuar
      if (!permissionsGranted) {
        if (mounted) {
          await _showPermissionWarning();
        }
      }
      
    } catch (e) {
      // Si hay error en permisos, continuar de todos modos
      print('Error al manejar permisos: $e');
      setState(() => _statusMessage = 'Continuando sin verificación de permisos');
    }
  }

  /// Request permissions with individual error handling
  Future<bool> _requestPermissionsWithFallback() async {
    try {
      Map<Permission, PermissionStatus> results = {};
      
      // Intentar cada permiso individualmente
      try {
        final locationStatus = await Permission.location.request();
        results[Permission.location] = locationStatus;
      } catch (e) {
        print('Error en permiso de ubicación: $e');
      }
      
      try {
        final cameraStatus = await Permission.camera.request();
        results[Permission.camera] = cameraStatus;
      } catch (e) {
        print('Error en permiso de cámara: $e');
      }
      
      try {
        // Solo solicitar almacenamiento si no está restringido
        if (!(await Permission.storage.isRestricted)) {
          final storageStatus = await Permission.storage.request();
          results[Permission.storage] = storageStatus;
        }
      } catch (e) {
        print('Error en permiso de almacenamiento: $e');
      }
      
      // Considerar éxito si al menos algunos permisos fueron otorgados
      // O simplemente continuar de todos modos
      final grantedPermissions = results.values.where((status) => status.isGranted).length;
      
      // Si no se otorgó ningún permiso, preguntar si quiere configurar
      if (grantedPermissions == 0 && results.isNotEmpty) {
        return false;
      }
      
      // Continuar incluso con permisos parciales
      return true;
      
    } catch (e) {
      print('Error general en solicitud de permisos: $e');
      return false; // Continuar de todos modos
    }
  }

  /// Complete app initialization
  Future<void> _completeInitialization() async {
    try {
      // Simulate any final setup
      await Future.delayed(const Duration(milliseconds: 800));
      
      setState(() {
        _initializationComplete = true;
      });
      
      if (mounted) {
        _navigateToMainMenu();
      }
    } catch (e) {
      // Incluso si falla esto, navegar a la pantalla principal
      print('Error en finalización: $e');
      if (mounted) {
        _navigateToMainMenu();
      }
    }
  }

  /// Navigate to main menu screen
  void _navigateToMainMenu() {
    // Usar un pequeño delay para asegurar transición suave
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/main-menu-screen');
      }
    });
  }

  /// Show permission warning (not blocking)
  Future<void> _showPermissionWarning() async {
    final theme = Theme.of(context);

    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        title: Text(
          'Permisos Limitados',
          style: theme.textTheme.titleLarge,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'La aplicación funcionará con capacidades limitadas:',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            if (!_permissionsGranted) ...[
              Text(
                '• Algunas funciones pueden no estar disponibles',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
            ],
            Text(
              'Puede otorgar permisos más tarde desde Configuración.',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Continuar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: Text(
              'Configurar',
              style: TextStyle(color: theme.colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  /// Show non-blocking error notification
  void _showErrorNotification() {
    final scaffold = ScaffoldMessenger.of(context);
    
    scaffold.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.amber),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'La aplicación inició con algunas advertencias',
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.grey[900],
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Detalles',
          textColor: Colors.blue,
          onPressed: () {
            _showDetailedErrorDialog();
          },
        ),
      ),
    );
  }

  /// Show detailed error dialog (optional)
  void _showDetailedErrorDialog() {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Información de Inicialización',
          style: theme.textTheme.titleLarge,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!_permissionsGranted) ...[
              Text(
                '⚠️ Permisos limitados',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: Colors.amber,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Algunas funciones pueden no estar disponibles hasta que otorgue los permisos necesarios.',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
            ],
            Text(
              'La aplicación está lista para usar.',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
          if (!_permissionsGranted)
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await openAppSettings();
              },
              child: const Text('Configurar Permisos'),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Mostrar notificación de error si ocurrió
    if (_errorOccurred && _initializationComplete && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorNotification();
      });
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primary.withOpacity(0.8),
              theme.colorScheme.secondary.withOpacity(0.6),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Stack(
                        children: [
                          CustomIconWidget(
                            iconName: 'forest',
                            color: theme.colorScheme.onPrimary,
                            size: 80,
                          ),
                          if (_errorOccurred)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                padding: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.amber,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.info_outline,
                                  color: Colors.black,
                                  size: 16,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Intenigencia Forestal',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Gestión Forestal Profesional',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onPrimary.withOpacity(0.9),
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(flex: 2),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _errorOccurred ? Colors.amber : theme.colorScheme.onPrimary,
                      ),
                    ),
                    if (_errorOccurred)
                      Icon(
                        Icons.warning_amber,
                        color: Colors.amber,
                        size: 20,
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _statusMessage,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: _errorOccurred 
                            ? Colors.amber 
                            : theme.colorScheme.onPrimary.withOpacity(0.8),
                      ),
                    ),
                    if (_errorOccurred)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Icon(
                          Icons.info_outline,
                          color: Colors.amber,
                          size: 16,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}