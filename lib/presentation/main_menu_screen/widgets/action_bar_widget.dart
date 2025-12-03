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
            Container(
              height: 8.h,
              width: 15.w,
              decoration: BoxDecoration(
                color: isSynced
                    ? theme.colorScheme.primary.withValues(alpha: 0.1)
                    : theme.colorScheme.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4.0),
                border: Border.all(
                  color: isSynced
                      ? theme.colorScheme.primary
                      : theme.colorScheme.error,
                  width: 1,
                ),
              ),
              child: InkWell(
                onTap: onSyncTap,
                borderRadius: BorderRadius.circular(4.0),
                child: Center(
                  child: CustomIconWidget(
                    iconName: isSynced ? 'cloud_done' : 'cloud_off',
                    color: isSynced
                        ? theme.colorScheme.primary
                        : theme.colorScheme.error,
                    size: 7.w,
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
