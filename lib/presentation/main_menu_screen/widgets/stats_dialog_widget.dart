import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Quick stats dialog shown on long-press of module cards
/// Displays total records, last entry date, and storage usage
class StatsDialogWidget extends StatelessWidget {
  final String moduleTitle;
  final int totalRecords;
  final String lastEntryDate;
  final String storageUsage;

  const StatsDialogWidget({
    super.key,
    required this.moduleTitle,
    required this.totalRecords,
    required this.lastEntryDate,
    required this.storageUsage,
  });

  @override
  Widget build(BuildContext context) {
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
                    'Estadísticas - $moduleTitle',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontSize: 16.sp,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
            SizedBox(height: 3.h),
            _buildStatRow(
              context: context,
              icon: 'folder',
              label: 'Total de registros',
              value: totalRecords.toString(),
            ),
            SizedBox(height: 2.h),
            _buildStatRow(
              context: context,
              icon: 'schedule',
              label: 'Última entrada',
              value: lastEntryDate,
            ),
            SizedBox(height: 2.h),
            _buildStatRow(
              context: context,
              icon: 'storage',
              label: 'Uso de almacenamiento',
              value: storageUsage,
            ),
            SizedBox(height: 3.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Cerrar',
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

  Widget _buildStatRow({
    required BuildContext context,
    required String icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 10.w,
          height: 10.w,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: Center(
            child: CustomIconWidget(
              iconName: icon,
              color: theme.colorScheme.primary,
              size: 5.w,
            ),
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 11.sp,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 14.sp,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
