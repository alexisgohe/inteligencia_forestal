import 'package:flutter/material.dart';
import '../presentation/splash_screen/splash_screen.dart';
// import '../presentation/photo_capture_screen/photo_capture_screen.dart';
// import '../presentation/camera_measurement_screen/camera_measurement_screen.dart';
// import '../presentation/records_list_screen/records_list_screen.dart';
import '../presentation/main_menu_screen/main_menu_screen.dart';
import '../forms/gestion_forestal_form.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String splash = '/splash-screen';
  static const String photoCapture = '/photo-capture-screen';
  static const String cameraMeasurement = '/camera-measurement-screen';
  static const String recordsList = '/records-list-screen';
  static const String mainMenu = '/main-menu-screen';
  static const String formGestionForestal = '/gestion-forestal-form';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    splash: (context) => const SplashScreen(),
    // photoCapture: (context) => const PhotoCaptureScreen(),
    // cameraMeasurement: (context) => const CameraMeasurementScreen(),
    // recordsList: (context) => const RecordsListScreen(),
    mainMenu: (context) => const MainMenuScreen(),
    formGestionForestal: (context) => const GestionForestalForm(), 
    // TODO: Add your other routes here
  };
}
