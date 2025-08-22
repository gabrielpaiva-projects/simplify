import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/user_model.dart';
import '../providers/auth_provider.dart';

class AuthDrawer extends StatelessWidget {
  const AuthDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;
        final userData = authProvider.userData;
        final userType = authProvider.userType;
        
        return Drawer(
          backgroundColor: isDarkMode ? AppColors.deepBlack : AppColors.iceWhite,
          child: Column(
            children: [
              // Header
              DrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryBlue,
                      AppColors.primaryBlue.withValues(alpha: 0.7),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Avatar
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.white,
                      child: Icon(
                        _getIconForUserType(userType),
                        size: 35,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Nome do usuário
                    Text(
                      userData?['fullName'] ?? user?.displayName ?? 'Usuário',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    
                    // Email
                    Text(
                      user?.email ?? '',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    
                    // Tipo de usuário
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getUserTypeLabel(userType),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Menu Items
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    // Perfil
                    ListTile(
                      leading: Icon(
                        Icons.person_outline,
                        color: isDarkMode ? Colors.white : AppColors.charcoalGrey,
                      ),
                      title: Text(
                        'Meu Perfil',
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : AppColors.charcoalGrey,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        // TODO: Navegar para tela de perfil
                      },
                    ),
                    
                    // Configurações
                    ListTile(
                      leading: Icon(
                        Icons.settings_outlined,
                        color: isDarkMode ? Colors.white : AppColors.charcoalGrey,
                      ),
                      title: Text(
                        'Configurações',
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : AppColors.charcoalGrey,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        // TODO: Navegar para tela de configurações
                      },
                    ),
                    
                    // Divider
                    const Divider(),
                    
                    // Informações da conta
                    if (userData != null) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Text(
                          'Informações da Conta',
                          style: TextStyle(
                            color: isDarkMode 
                                ? Colors.white70 
                                : AppColors.charcoalGrey.withValues(alpha: 0.7),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      
                      // CPF
                      if (userData['cpf'] != null)
                        _buildInfoTile(
                          'CPF',
                          _formatCpf(userData['cpf']),
                          isDarkMode,
                        ),
                      
                      // Telefone
                      if (userData['phone'] != null)
                        _buildInfoTile(
                          'Telefone',
                          userData['phone'],
                          isDarkMode,
                        ),
                      
                      // RG (apenas para profissionais)
                      if (userType == UserType.professional && userData['rg'] != null)
                        _buildInfoTile(
                          'RG',
                          _formatRg(userData['rg']),
                          isDarkMode,
                        ),
                      
                      const Divider(),
                    ],
                    
                    // Ajuda
                    ListTile(
                      leading: Icon(
                        Icons.help_outline,
                        color: isDarkMode ? Colors.white : AppColors.charcoalGrey,
                      ),
                      title: Text(
                        'Ajuda',
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : AppColors.charcoalGrey,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        // TODO: Navegar para tela de ajuda
                      },
                    ),
                    
                    // Sobre
                    ListTile(
                      leading: Icon(
                        Icons.info_outline,
                        color: isDarkMode ? Colors.white : AppColors.charcoalGrey,
                      ),
                      title: Text(
                        'Sobre',
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : AppColors.charcoalGrey,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        // TODO: Navegar para tela sobre
                      },
                    ),
                  ],
                ),
              ),
              
              // Logout button
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: isDarkMode
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.black.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                child: ListTile(
                  leading: const Icon(
                    Icons.logout,
                    color: AppColors.error,
                  ),
                  title: const Text(
                    'Sair',
                    style: TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () async {
                    // Confirmar logout
                    final shouldLogout = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: isDarkMode 
                            ? AppColors.charcoalGrey 
                            : Colors.white,
                        title: Text(
                          'Confirmar Saída',
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : AppColors.deepBlack,
                          ),
                        ),
                        content: Text(
                          'Deseja realmente sair da sua conta?',
                          style: TextStyle(
                            color: isDarkMode 
                                ? Colors.white70 
                                : AppColors.charcoalGrey,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text(
                              'Cancelar',
                              style: TextStyle(
                                color: isDarkMode 
                                    ? Colors.white70 
                                    : AppColors.charcoalGrey,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text(
                              'Sair',
                              style: TextStyle(
                                color: AppColors.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                    
                    if (shouldLogout == true) {
                      await authProvider.signOut();
                      if (context.mounted) {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          '/login',
                          (route) => false,
                        );
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildInfoTile(String label, String value, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isDarkMode 
                  ? Colors.white70 
                  : AppColors.charcoalGrey.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isDarkMode ? Colors.white : AppColors.charcoalGrey,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  IconData _getIconForUserType(UserType? userType) {
    switch (userType) {
      case UserType.client:
        return Icons.person;
      case UserType.professional:
        return Icons.work;
      case UserType.admin:
        return Icons.admin_panel_settings;
      default:
        return Icons.person_outline;
    }
  }
  
  String _getUserTypeLabel(UserType? userType) {
    switch (userType) {
      case UserType.client:
        return 'Cliente';
      case UserType.professional:
        return 'Profissional';
      case UserType.admin:
        return 'Administrador';
      default:
        return 'Usuário';
    }
  }
  
  String _formatCpf(String cpf) {
    if (cpf.length != 11) return cpf;
    return '${cpf.substring(0, 3)}.${cpf.substring(3, 6)}.${cpf.substring(6, 9)}-${cpf.substring(9)}';
  }
  
  String _formatRg(String rg) {
    if (rg.length < 8) return rg;
    return '${rg.substring(0, 2)}.${rg.substring(2, 5)}.${rg.substring(5, 8)}-${rg.substring(8)}';
  }
}