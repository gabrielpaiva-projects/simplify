import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationBadge extends StatefulWidget {
  final RemoteMessage message;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const NotificationBadge({
    super.key,
    required this.message,
    this.onTap,
    this.onDismiss,
  });

  @override
  State<NotificationBadge> createState() => _NotificationBadgeState();
}

class _NotificationBadgeState extends State<NotificationBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _animationController.forward();

    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _dismiss() async {
    await _animationController.reverse();
    if (mounted && widget.onDismiss != null) {
      widget.onDismiss!();
    }
  }

  void _handleTap() {
    if (widget.onTap != null) {
      widget.onTap!();
    }
    _dismiss();
  }

  IconData _getNotificationIcon() {
    final type = widget.message.data['type'] as String?;
    switch (type) {
      case 'payment_confirmed':
        return Icons.check_circle_outline;
      case 'appointment_reminder':
        return Icons.event_outlined;
      case 'service_completed':
        return Icons.task_alt_outlined;
      case 'new_message':
        return Icons.chat_bubble_outline;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _getNotificationColor() {
    final type = widget.message.data['type'] as String?;
    switch (type) {
      case 'payment_confirmed':
        return const Color(0xFF10B981); // Verde moderno
      case 'appointment_reminder':
        return const Color(0xFF3B82F6); // Azul moderno
      case 'service_completed':
        return const Color(0xFF8B5CF6); // Roxo moderno
      case 'new_message':
        return const Color(0xFFF59E0B); // Laranja moderno
      default:
        return const Color(0xFF6366F1); // Indigo moderno
    }
  }

  String _formatAmount(String? amount) {
    if (amount == null || amount.isEmpty) return '';
    try {
      final value = double.parse(amount);
      return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
    } catch (e) {
      return amount;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF1F2937) : Colors.white;
    final titleColor = isDark ? const Color(0xFFF9FAFB) : const Color(0xFF1A1A1A);
    final bodyColor = isDark ? const Color(0xFFD1D5DB) : const Color(0xFF6B7280);
    final closeButtonColor = isDark ? const Color(0xFF4B5563) : Colors.grey.withOpacity(0.1);
    final closeIconColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF9CA3AF);
    
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Material(
            elevation: 12,
            shadowColor: Colors.black.withOpacity(isDark ? 0.5 : 0.3),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: backgroundColor,
                border: Border.all(
                  color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: InkWell(
                onTap: _handleTap,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: _getNotificationColor().withOpacity(0.1),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Icon(
                          _getNotificationIcon(),
                          color: _getNotificationColor(),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.message.notification?.title ?? 'Notificação',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: titleColor,
                                letterSpacing: -0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.message.notification?.body ?? '',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: bodyColor,
                                height: 1.3,
                                letterSpacing: -0.1,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (widget.message.data['amount'] != null) ...[
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _getNotificationColor().withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _formatAmount(widget.message.data['amount']),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: _getNotificationColor(),
                                    letterSpacing: -0.1,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _dismiss,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: closeButtonColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.close,
                            color: closeIconColor,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class NotificationBadgeData {
  final RemoteMessage message;
  final DateTime timestamp;

  NotificationBadgeData({
    required this.message,
    required this.timestamp,
  });
}
