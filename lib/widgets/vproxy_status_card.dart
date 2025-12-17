import 'package:flutter/material.dart';
import 'package:tm/protos/app/api/api.pb.dart';

/// A beautiful card widget displaying vx status information
class VproxyStatusCard extends StatelessWidget {
  final VproxyStatusResponse status;
  final VoidCallback? onRefresh;

  const VproxyStatusCard({
    super.key,
    required this.status,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isInstalled = status.installed;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isInstalled
                ? [
                    theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                    theme.colorScheme.secondaryContainer.withValues(alpha: 0.2),
                  ]
                : [
                    theme.colorScheme.errorContainer.withValues(alpha: 0.3),
                    theme.colorScheme.errorContainer.withValues(alpha: 0.1),
                  ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with title and refresh button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isInstalled
                              ? theme.colorScheme.primary.withValues(alpha: 0.1)
                              : theme.colorScheme.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          isInstalled ? Icons.cloud_done : Icons.cloud_off,
                          color: isInstalled
                              ? theme.colorScheme.primary
                              : theme.colorScheme.error,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'VX Status',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (onRefresh != null)
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: onRefresh,
                      tooltip: 'Refresh',
                      style: IconButton.styleFrom(
                        backgroundColor:
                            theme.colorScheme.surface.withValues(alpha: 0.5),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),

              // Status Badge
              _StatusBadge(isInstalled: isInstalled),
              const SizedBox(height: 16),

              // Divider
              Divider(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
                height: 1,
              ),
              const SizedBox(height: 16),

              // Status Details
              if (isInstalled) ...[
                _InfoRow(
                  icon: Icons.info_outline,
                  label: 'Version',
                  value: status.version.isNotEmpty ? status.version : 'N/A',
                  iconColor: theme.colorScheme.primary,
                ),
                const SizedBox(height: 12),
                _InfoRow(
                  icon: Icons.access_time,
                  label: 'Start Time',
                  value: status.startTime.isNotEmpty
                      ? _formatStartTime(status.startTime)
                      : 'N/A',
                  iconColor: theme.colorScheme.secondary,
                ),
                const SizedBox(height: 12),
                _InfoRow(
                  icon: Icons.memory,
                  label: 'Memory',
                  value: _formatMemory(status.memory),
                  iconColor: theme.colorScheme.tertiary,
                  trailing: _MemoryIndicator(memory: status.memory),
                ),
              ] else ...[
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'VX is not installed',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatStartTime(String startTime) {
    try {
      final dateTime = DateTime.parse(startTime);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 0) {
        return '${difference.inDays}d ${difference.inHours % 24}h ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ${difference.inMinutes % 60}m ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return startTime;
    }
  }

  String _formatMemory(double memory) {
    if (memory < 1024) {
      return '${memory.toStringAsFixed(1)} MB';
    } else {
      return '${(memory / 1024).toStringAsFixed(2)} GB';
    }
  }
}

/// Status badge showing whether vx is running
class _StatusBadge extends StatelessWidget {
  final bool isInstalled;

  const _StatusBadge({required this.isInstalled});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isInstalled
            ? theme.colorScheme.primary.withValues(alpha: 0.15)
            : theme.colorScheme.error.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isInstalled
              ? theme.colorScheme.primary.withValues(alpha: 0.3)
              : theme.colorScheme.error.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isInstalled
                  ? theme.colorScheme.primary
                  : theme.colorScheme.error,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: isInstalled
                      ? theme.colorScheme.primary.withValues(alpha: 0.5)
                      : theme.colorScheme.error.withValues(alpha: 0.5),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isInstalled ? 'Running' : 'Not Installed',
            style: theme.textTheme.labelLarge?.copyWith(
              color: isInstalled
                  ? theme.colorScheme.primary
                  : theme.colorScheme.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Information row displaying an icon, label, and value
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;
  final Widget? trailing;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 18,
            color: iconColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// Visual indicator for memory usage
class _MemoryIndicator extends StatelessWidget {
  final double memory;

  const _MemoryIndicator({required this.memory});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isHighMemory = memory > 512; // More than 512MB

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isHighMemory
            ? theme.colorScheme.error.withValues(alpha: 0.1)
            : theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        isHighMemory ? Icons.warning_amber : Icons.check_circle_outline,
        size: 16,
        color: isHighMemory
            ? theme.colorScheme.error
            : theme.colorScheme.primary,
      ),
    );
  }
}
