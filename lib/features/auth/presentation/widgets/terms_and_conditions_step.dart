import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../../core/constants/app_colors.dart';

class TermsAndConditionsStep extends StatefulWidget {
  final AnimationController animationController;
  final GlobalKey<FormState> formKey;
  final Function(bool) onAcceptanceChanged;
  
  const TermsAndConditionsStep({
    super.key,
    required this.animationController,
    required this.formKey,
    required this.onAcceptanceChanged,
  });

  @override
  State<TermsAndConditionsStep> createState() => TermsAndConditionsStepState();
}

class TermsAndConditionsStepState extends State<TermsAndConditionsStep> {
  bool _acceptedTerms = false;
  final ScrollController _scrollController = ScrollController();
  bool _hasScrolledToBottom = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      if (!_hasScrolledToBottom) {
        setState(() {
          _hasScrolledToBottom = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    return AnimatedBuilder(
      animation: widget.animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.9 + (widget.animationController.value * 0.1),
          child: Opacity(
            opacity: widget.animationController.value,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: widget.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Title
                        const Text(
                          'Termos e Condições',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        Text(
                          'Por favor, leia com atenção os termos de uso',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Terms container with fixed height
                        Container(
                          height: constraints.maxHeight * 0.5, // 50% of available height
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Stack(
                              children: [
                                // Terms text with independent scroll
                                RawScrollbar(
                                  controller: _scrollController,
                                  thumbVisibility: true,
                                  trackVisibility: true,
                                  thickness: 8,
                                  radius: const Radius.circular(4),
                                  thumbColor: AppColors.primaryGreen.withOpacity(0.5),
                                  trackColor: Colors.white.withOpacity(0.05),
                                  trackBorderColor: Colors.transparent,
                                  child: SingleChildScrollView(
                                    controller: _scrollController,
                                    physics: const BouncingScrollPhysics(),
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'TERMOS E CONDIÇÕES DE USO',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primaryGreen,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          _getTermsText(),
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.white.withOpacity(0.8),
                                            height: 1.6,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                
                                // Gradient overlay at bottom if not scrolled
                                if (!_hasScrolledToBottom)
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      height: 80,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            Colors.black.withOpacity(0.9),
                                          ],
                                        ),
                                      ),
                                      child: Center(
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.arrow_downward,
                                              color: AppColors.primaryGreen,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Role para baixo para ler todos os termos',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: AppColors.primaryGreen,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Checkbox
                        GestureDetector(
                          onTap: _hasScrolledToBottom
                              ? () {
                                  setState(() {
                                    _acceptedTerms = !_acceptedTerms;
                                  });
                                  widget.onAcceptanceChanged(_acceptedTerms);
                                }
                              : null,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _acceptedTerms
                                  ? AppColors.primaryGreen.withOpacity(0.1)
                                  : Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _acceptedTerms
                                    ? AppColors.primaryGreen
                                    : Colors.white.withOpacity(0.2),
                                width: _acceptedTerms ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: _acceptedTerms
                                        ? AppColors.primaryGreen
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: _hasScrolledToBottom
                                          ? (_acceptedTerms
                                              ? AppColors.primaryGreen
                                              : Colors.white.withOpacity(0.5))
                                          : Colors.white.withOpacity(0.2),
                                      width: 2,
                                    ),
                                  ),
                                  child: _acceptedTerms
                                      ? const Icon(
                                          Icons.check,
                                          size: 16,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Li e aceito os termos e condições',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: _hasScrolledToBottom
                                              ? Colors.white
                                              : Colors.white.withOpacity(0.4),
                                        ),
                                      ),
                                      if (!_hasScrolledToBottom)
                                        Text(
                                          'Leia todos os termos para habilitar',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.orange.withOpacity(0.8),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Privacy policy info
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primaryGreen.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.privacy_tip_outlined,
                                color: AppColors.primaryGreen,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Ao aceitar, você concorda com nossa Política de Privacidade e o processamento dos seus dados pessoais',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withOpacity(0.7),
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
  
  String _getTermsText() {
    return '''1. ACEITAÇÃO DOS TERMOS

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.

2. DESCRIÇÃO DO SERVIÇO

Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.

3. CADASTRO E CONTA DO USUÁRIO

Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.

4. OBRIGAÇÕES DO USUÁRIO

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua:

• Ut enim ad minim veniam, quis nostrud exercitation
• Ullamco laboris nisi ut aliquip ex ea commodo consequat
• Duis aute irure dolor in reprehenderit in voluptate
• Velit esse cillum dolore eu fugiat nulla pariatur
• Excepteur sint occaecat cupidatat non proident

5. POLÍTICA DE PRIVACIDADE

Sunt in culpa qui officia deserunt mollit anim id est laborum. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.

6. PROPRIEDADE INTELECTUAL

Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Lorem ipsum dolor sit amet, consectetur adipiscing elit.

7. LIMITAÇÃO DE RESPONSABILIDADE

Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.

8. MODIFICAÇÕES DOS TERMOS

Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.

9. RESCISÃO

Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.

10. DISPOSIÇÕES GERAIS

Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.

11. CONTATO

Para questões sobre estes termos e condições, entre em contato conosco através do e-mail: suporte@simplify.com.br

Data da última atualização: Janeiro de 2024''';
  }
  
  bool validate() {
    if (!_hasScrolledToBottom) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor, leia todos os termos e condições'),
          backgroundColor: Colors.orange,
        ),
      );
      return false;
    }
    
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Você deve aceitar os termos e condições para continuar'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    
    return true;
  }
}