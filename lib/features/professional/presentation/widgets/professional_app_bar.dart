import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';

class ProfessionalAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ProfessionalAppBar({Key? key}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primaryGreen,
      foregroundColor: Colors.white,
      elevation: 0,
      title: const Text(
        'Simplify Pro',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => _showProfileMenu(context),
          icon: Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              final profileImageUrl = authProvider.userData?['profileImageUrl'];
              
              if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
                return CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(profileImageUrl),
                  backgroundColor: Colors.white.withOpacity(0.2),
                );
              }
              
              return CircleAvatar(
                radius: 16,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 20,
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  void _showProfileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _ProfileMenuBottomSheet(),
    );
  }
}

class _ProfileMenuBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.secondaryText.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          _buildProfileHeader(context),
          const SizedBox(height: 20),
          _buildMenuItems(context),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final userData = authProvider.userData;
        final profileImageUrl = userData?['profileImageUrl'];
        final fullName = userData?['fullName'] ?? 'Profissional';
        final email = authProvider.user?.email ?? '';

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: profileImageUrl != null && profileImageUrl.isNotEmpty
                    ? NetworkImage(profileImageUrl)
                    : null,
                backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
                child: profileImageUrl == null || profileImageUrl.isEmpty
                    ? Icon(
                        Icons.person,
                        size: 30,
                        color: AppColors.primaryGreen,
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Profissional Verificado',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.success,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuItems(BuildContext context) {
    return Column(
      children: [
        _buildMenuItem(
          context,
          icon: Icons.person_outline,
          title: 'Meu Perfil',
          onTap: () {
            Navigator.pop(context);
            // TODO: Navegar para tela de perfil
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Tela de perfil em desenvolvimento'),
                backgroundColor: Colors.orange,
              ),
            );
          },
        ),
        _buildMenuItem(
          context,
          icon: Icons.work_outline,
          title: 'Meus Serviços',
          onTap: () {
            Navigator.pop(context);
            // TODO: Navegar para tela de serviços do profissional
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Tela de serviços em desenvolvimento'),
                backgroundColor: Colors.orange,
              ),
            );
          },
        ),
        _buildMenuItem(
          context,
          icon: Icons.notifications_outlined,
          title: 'Notificações',
          onTap: () {
            Navigator.pop(context);
            // TODO: Navegar para tela de notificações
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Tela de notificações em desenvolvimento'),
                backgroundColor: Colors.orange,
              ),
            );
          },
        ),
        _buildMenuItem(
          context,
          icon: Icons.help_outline,
          title: 'Ajuda e Suporte',
          onTap: () {
            Navigator.pop(context);
            // TODO: Navegar para tela de ajuda
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Tela de ajuda em desenvolvimento'),
                backgroundColor: Colors.orange,
              ),
            );
          },
        ),
        const Divider(height: 1),
        _buildMenuItem(
          context,
          icon: Icons.logout,
          title: 'Sair',
          titleColor: AppColors.error,
          iconColor: AppColors.error,
          onTap: () async {
            Navigator.pop(context);
            await _showLogoutDialog(context);
          },
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? titleColor,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? AppColors.primaryText,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: titleColor ?? AppColors.primaryText,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar saída'),
        content: const Text('Tem certeza que deseja sair da sua conta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.signOut();
    }
  }
}
