import 'modern_schedule_screen.dart';
import '../../data/enums/cleaning_type.dart';

void _handleScheduleService(ServiceModel service) {
  HapticFeedback.mediumImpact();
  
  // Verifica se é um serviço de limpeza
  if (service.title.toLowerCase().contains('limpeza')) {
    // Determina o tipo de limpeza baseado no título
    CleaningType cleaningType = CleaningType.standard;
    if (service.title.toLowerCase().contains('pesada')) {
      cleaningType = CleaningType.heavy;
    }
    
    // Navega para a tela de agendamento de limpeza
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ModernScheduleScreen(
              serviceTitle: service.title,
              cleaningType: cleaningType,
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeOutCubic;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  } else {
    // Resto do código permanece igual...
  }
}