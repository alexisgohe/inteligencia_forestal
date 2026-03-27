import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Bottom action bar with Export Data and Sync Status
/// Implements 60pt minimum touch targets for field use
class ActionBarWidget extends StatelessWidget {
  final int totalRecords;
  final bool isSynced;
  final VoidCallback onExportTap;
  final VoidCallback onSyncTap;

  const ActionBarWidget({
    super.key,
    required this.totalRecords,
    required this.isSynced,
    required this.onExportTap,
    required this.onSyncTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onExportTap,
                icon: CustomIconWidget(
                  iconName: 'file_download',
                  color: theme.colorScheme.onPrimary,
                  size: 5.w,
                ),
                label: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Exportar Datos',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontSize: 13.sp,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                    Text(
                      '$totalRecords registros',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 10.sp,
                        color:
                            theme.colorScheme.onPrimary.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 8.h),
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                ),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onSyncTap,
                icon: CustomIconWidget(
                  iconName: isSynced ? 'cloud_done' : 'sync',
                  color: isSynced
                      ? theme.colorScheme.primary
                      : theme.colorScheme.error,
                  size: 5.w,
                ),
                label: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isSynced ? 'Sincronizado' : 'Sincronizar',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontSize: 12.sp,
                        color: isSynced
                            ? theme.colorScheme.primary
                            : theme.colorScheme.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      isSynced ? 'Al día' : 'Pendiente',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 9.sp,
                        color: isSynced
                            ? theme.colorScheme.primary.withValues(alpha: 0.7)
                            : theme.colorScheme.error.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(double.infinity, 8.h),
                  padding: EdgeInsets.symmetric(horizontal: 2.w),
                  side: BorderSide(
                    color: isSynced
                        ? theme.colorScheme.primary
                        : theme.colorScheme.error,
                  ),
                  backgroundColor: isSynced
                      ? theme.colorScheme.primary.withValues(alpha: 0.05)
                      : theme.colorScheme.error.withValues(alpha: 0.05),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
