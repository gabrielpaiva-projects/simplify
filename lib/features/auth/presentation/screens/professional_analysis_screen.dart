import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';

class ProfessionalAnalysisScreen extends StatefulWidget {
  const ProfessionalAnalysisScreen({super.key});

  @override
  State<ProfessionalAnalysisScreen> createState() => _ProfessionalAnalysisScreenState();
}

class _ProfessionalAnalysisScreenState extends State<ProfessionalAnalysisScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    ));

    _animationController.forward();
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              AppColors.charcoalGrey.withOpacity(0.5),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                
                // Animated Icon
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primaryGreen.withOpacity(0.1),
                            border: Border.all(
                              color: AppColors.primaryGreen.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Rotating outer circle
                              Transform.rotate(
                                angle: _rotationAnimation.value * 2 * 3.14159,
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.primaryGreen.withOpacity(0.2),
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.hourglass_empty_rounded,
                                color: AppColors.primaryGreen,
                                size: 60,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 48),
                
                // Title
                const Text(
                  'Cadastro em Análise',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 16),
                
                // Subtitle
                Text(
                  'Parabéns! Seu cadastro foi enviado com sucesso.',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 32),
                
                // Description
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: AppColors.primaryGreen,
                        size: 32,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Estamos analisando seus documentos e informações. '
                        'Este processo é necessário para garantir a segurança '
                        'e qualidade dos serviços oferecidos em nossa plataforma.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Time info
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: AppColors.primaryGreen.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.access_time,
                        color: AppColors.primaryGreen,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Prazo de análise: até 48 horas',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Email notification info
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.email_outlined,
                      color: Colors.white.withOpacity(0.5),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Você receberá um e-mail quando a análise for concluída',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
                
                const Spacer(),
                
                // Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        '/login',
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Voltar ao Login',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Contact support
                TextButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    // TODO: Abrir suporte
                  },
                  child: Text(
                    'Dúvidas? Fale com o suporte',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.5),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}