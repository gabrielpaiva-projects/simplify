#!/usr/bin/env python3

import re

# Read the login_screen.dart file
with open('/workspace/lib/features/auth/presentation/screens/login_screen.dart', 'r') as f:
    content = f.read()

# Replace the import
content = content.replace(
    "import '../widgets/profile_selection_bottom_sheet.dart';\nimport 'client_registration_screen.dart';\nimport 'professional_registration_screen.dart';",
    "import 'welcome_registration_screen.dart';"
)

# Replace the ProfileSelectionBottomSheet usage
old_code = """                HapticFeedback.lightImpact();
                
                // Abre o BottomSheet para seleção do tipo de perfil
                final UserType? selectedType = await ProfileSelectionBottomSheet.show(context);
                
                if (selectedType != null && mounted) {
                  // Navega para a tela de cadastro apropriada
                  if (selectedType == UserType.client) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ClientRegistrationScreen(),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfessionalRegistrationScreen(),
                      ),
                    );
                  }
                }"""

new_code = """                HapticFeedback.lightImpact();
                
                // Navega para a nova tela de boas-vindas do cadastro
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const WelcomeRegistrationScreen(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.0, 0.1),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic,
                          )),
                          child: child,
                        ),
                      );
                    },
                    transitionDuration: const Duration(milliseconds: 600),
                  ),
                );"""

content = content.replace(old_code, new_code)

# Write the updated content back
with open('/workspace/lib/features/auth/presentation/screens/login_screen.dart', 'w') as f:
    f.write(content)

print("Login screen updated successfully!")