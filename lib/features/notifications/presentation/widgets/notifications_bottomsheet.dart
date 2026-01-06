import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../services/notification_storage_service.dart';
import '../../../../models/notification_model.dart';

class NotificationsBottomSheet extends StatefulWidget {
  const NotificationsBottomSheet({super.key});

  @override
  State<NotificationsBottomSheet> createState() => _NotificationsBottomSheetState();

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const NotificationsBottomSheet(),
    );
  }
}

class _NotificationsBottomSheetState extends State<NotificationsBottomSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationStorageService>().cleanupOldNotifications();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        height: screenHeight * 0.85,
        decoration: const BoxDecoration(
          color: Color(0xFFF8F9FA),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            _buildHeader(),
            
            Expanded(
              child: Consumer<NotificationStorageService>(
                builder: (context, notificationService, child) {
                  final notifications = notificationService.notifications;
                  
                  if (notifications.isEmpty) {
                    return _buildEmptyState();
                  }
                  
                  return Column(
                    children: [
                      if (notifications.isNotEmpty) _buildStatsCard(notificationService),
                      
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                          itemCount: notifications.length,
                          itemBuilder: (context, index) {
                            final notification = notifications[index];
                            return _buildNotificationItem(notification, notificationService);
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.notifications_rounded,
              color: AppColors.primaryGreen,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notificações',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                Text(
                  'Suas atualizações recentes',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          Consumer<NotificationStorageService>(
            builder: (context, notificationService, child) {
              if (notificationService.hasUnreadNotifications) {
                return TextButton.icon(
                  onPressed: () {
                    notificationService.markAllAsRead();
                    _showSnackBar('Todas marcadas como lidas');
                  },
                  icon: const Icon(
                    Icons.done_all,
                    size: 16,
                    color: AppColors.primaryGreen,
                  ),
                  label: const Text(
                    'Marcar todas',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(NotificationStorageService service) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildStatItem(
            icon: Icons.notifications_rounded,
            label: 'Total',
            value: service.totalCount.toString(),
            color: Colors.blue,
          ),
          const SizedBox(width: 24),
          _buildStatItem(
            icon: Icons.circle,
            label: 'Não lidas',
            value: service.unreadCount.toString(),
            color: AppColors.primaryGreen,
          ),
          const Spacer(),
          if (service.totalCount > 0)
            IconButton(
              onPressed: () => _showClearAllDialog(),
              icon: Icon(
                Icons.delete_outline,
                color: Colors.grey[400],
                size: 20,
              ),
              tooltip: 'Limpar todas',
            ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: color,
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNotificationItem(NotificationModel notification, NotificationStorageService service) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        service.removeNotification(notification.id);
        _showSnackBar('Notificação removida');
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: Icon(
          Icons.delete_outline,
          color: Colors.red[400],
          size: 20,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: notification.isRead
              ? null
              : Border.all(
                  color: AppColors.primaryGreen.withOpacity(0.2),
                  width: 1,
                ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _handleNotificationTap(notification, service),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _getNotificationColor(notification.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getNotificationIcon(notification.type),
                      color: _getNotificationColor(notification.type),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w600,
                                  color: const Color(0xFF1A1A1A),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (!notification.isRead) ...[
                              const SizedBox(width: 8),
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: AppColors.primaryGreen,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (notification.body.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            notification.body,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              _formatDate(notification.receivedAt),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                            if (notification.type != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _getNotificationColor(notification.type).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _getTypeLabel(notification.type!),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: _getNotificationColor(notification.type),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_none_outlined,
                size: 40,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Nenhuma notificação',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Quando você receber notificações,\nelas aparecerão aqui.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleNotificationTap(NotificationModel notification, NotificationStorageService service) {
    if (!notification.isRead) {
      service.markAsRead(notification.id);
    }

    Navigator.of(context).pop();

    final type = notification.type;
    switch (type) {
      case 'appointment':
        debugPrint('Navigate to appointments');
        break;
      case 'payment':
        debugPrint('Navigate to payments');
        break;
      case 'promotion':
        debugPrint('Navigate to promotions');
        break;
      default:
        debugPrint('Show notification details');
    }
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Limpar notificações'),
        content: const Text('Deseja remover todas as notificações?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: TextStyle(color: Colors.grey[600])),
          ),
          TextButton(
            onPressed: () {
              context.read<NotificationStorageService>().clearAllNotifications();
              Navigator.pop(context);
              _showSnackBar('Todas as notificações foram removidas');
            },
            child: const Text('Limpar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primaryGreen,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  IconData _getNotificationIcon(String? type) {
    switch (type) {
      case 'appointment':
        return Icons.calendar_today_rounded;
      case 'payment':
        return Icons.payment_rounded;
      case 'promotion':
        return Icons.local_offer_rounded;
      case 'service':
        return Icons.cleaning_services_rounded;
      case 'reminder':
        return Icons.alarm_rounded;
      case 'message':
        return Icons.message_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _getNotificationColor(String? type) {
    switch (type) {
      case 'appointment':
        return Colors.blue;
      case 'payment':
        return Colors.green;
      case 'promotion':
        return Colors.orange;
      case 'service':
        return AppColors.primaryGreen;
      case 'reminder':
        return Colors.purple;
      case 'message':
        return Colors.cyan;
      default:
        return AppColors.primaryGreen;
    }
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'appointment':
        return 'Agendamento';
      case 'payment':
        return 'Pagamento';
      case 'promotion':
        return 'Promoção';
      case 'service':
        return 'Serviço';
      case 'reminder':
        return 'Lembrete';
      case 'message':
        return 'Mensagem';
      default:
        return 'Geral';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Agora mesmo';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}min';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${date.day}/${date.month}';
    }
  }
}
