import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Welcome message widget for new users with getting started tips
/// Shown when no records exist in the system
class WelcomeMessageWidget extends StatelessWidget {
  const WelcomeMessageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(4.0),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'info',
                color: theme.colorScheme.primary,
                size: 6.w,
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  '¡Bienvenido a Intenigencia Forestal!',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: 16.sp,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            'Comienza a recopilar datos forestales de manera eficiente. Aquí hay algunos consejos para empezar:',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 13.sp,
            ),
          ),
          SizedBox(height: 2.h),
          _buildTipItem(
            context: context,
            icon: 'forest',
            text:
                'Selecciona "Gestión Forestal" para registrar inventarios de árboles con mediciones de diámetro y altura.',
          ),
          SizedBox(height: 1.5.h),
          _buildTipItem(
            context: context,
            icon: 'health_and_safety',
            text:
                'Usa "Salud Forestal" para evaluar daños y condiciones sanitarias de los árboles.',
          ),
          SizedBox(height: 1.5.h),
          _buildTipItem(
            context: context,
            icon: 'camera_alt',
            text:
                'Captura fotos y utiliza herramientas de medición asistida por cámara para mayor precisión.',
          ),
          SizedBox(height: 1.5.h),
          _buildTipItem(
            context: context,
            icon: 'cloud_off',
            text:
                'Todos los datos se guardan localmente. Puedes trabajar sin conexión a internet.',
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem({
    required BuildContext context,
    required String icon,
    required String text,
  }) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(top: 0.5.h),
          child: CustomIconWidget(
            iconName: icon,
            color: theme.colorScheme.primary,
            size: 4.5.w,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 12.sp,
            ),
          ),
        ),
      ],
    );
  }
}
