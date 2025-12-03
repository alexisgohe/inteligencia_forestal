import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Reusable module card widget for Forest Management and Forest Health modules
/// Implements 60pt minimum touch target with haptic feedback
class ModuleCardWidget extends StatelessWidget {
  final String title;
  final String description;
  final String iconName;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final int recordCount;
  final String? lastEntryDate;

  const ModuleCardWidget({
    super.key,
    required this.title,
    required this.description,
    required this.iconName,
    required this.onTap,
    this.onLongPress,
    this.recordCount = 0,
    this.lastEntryDate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 4.0,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(4.0),
        child: Container(
          constraints: BoxConstraints(
            minHeight: 20.h,
          ),
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 15.w,
                    height: 15.w,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: Center(
                      child: CustomIconWidget(
                        iconName: iconName,
                        color: theme.colorScheme.primary,
                        size: 8.w,
                      ),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontSize: 16.sp,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          '$recordCount registros',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 11.sp,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              Text(
                description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 13.sp,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              if (lastEntryDate != null) ...[
                SizedBox(height: 2.h),
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'schedule',
                      color: theme.colorScheme.onSurfaceVariant,
                      size: 4.w,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Última entrada: $lastEntryDate',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 10.sp,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
