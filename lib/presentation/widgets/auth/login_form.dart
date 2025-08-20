import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reactive_forms/reactive_forms.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/extensions/string_extensions.dart';
import '../shared/custom_text_field.dart';

class LoginForm extends StatefulWidget {
  final Function(String email, String password, bool rememberMe) onSubmit;
  final VoidCallback onForgotPassword;
  final bool isLoading;

  const LoginForm({
    super.key,
    required this.onSubmit,
    required this.onForgotPassword,
    this.isLoading = false,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  
  bool _rememberMe = false;

  late FormGroup form;

  @override
  void initState() {
    super.initState();
    _setupForm();
  }

  void _setupForm() {
    form = FormGroup({
      'email': FormControl<String>(
        validators: [
          Validators.required,
          Validators.email,
        ],
      ),
      'password': FormControl<String>(
        validators: [
          Validators.required,
          Validators.minLength(8),
        ],
      ),
      'rememberMe': FormControl<bool>(value: false),
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value.isNullOrEmpty) {
      return 'E-mail é obrigatório';
    }
    if (!value.isValidEmail) {
      return 'Digite um e-mail válido';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value.isNullOrEmpty) {
      return 'Senha é obrigatória';
    }
    if (value!.length < 8) {
      return 'A senha deve ter pelo menos 8 caracteres';
    }
    return null;
  }

  void _handleSubmit() {
    if (form.valid) {
      final email = form.control('email').value as String;
      final password = form.control('password').value as String;
      final rememberMe = form.control('rememberMe').value as bool;
      
      widget.onSubmit(email, password, rememberMe);
    } else {
      form.markAllAsTouched();
      HapticFeedback.mediumImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ReactiveForm(
      formGroup: form,
      child: Column(
        children: [
          // Campo de E-mail
          ReactiveTextField<String>(
            formControlName: 'email',
            decoration: InputDecoration(
              labelText: 'E-mail',
              hintText: 'seu@email.com',
              prefixIcon: const Icon(Icons.mail_outline_rounded),
            ),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validationMessages: {
              ValidationMessage.required: (_) => 'E-mail é obrigatório',
              ValidationMessage.email: (_) => 'Digite um e-mail válido',
            },
          ),
          
          const SizedBox(height: 20),
          
          // Campo de Senha
          ReactiveTextField<String>(
            formControlName: 'password',
            decoration: InputDecoration(
              labelText: 'Senha',
              hintText: '••••••••',
              prefixIcon: const Icon(Icons.lock_outline_rounded),
            ),
            obscureText: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _handleSubmit(),
            validationMessages: {
              ValidationMessage.required: (_) => 'Senha é obrigatória',
              ValidationMessage.minLength: (_) => 'Mínimo de 8 caracteres',
            },
          ),
          
          const SizedBox(height: 20),
          
          // Remember me e Esqueci senha
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Remember me com checkbox customizado
              GestureDetector(
                onTap: () {
                  setState(() {
                    _rememberMe = !_rememberMe;
                    form.control('rememberMe').value = _rememberMe;
                  });
                  HapticFeedback.selectionClick();
                },
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: _rememberMe
                            ? AppColors.primaryGreen
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: _rememberMe
                              ? AppColors.primaryGreen
                              : (context.isDarkMode
                                  ? AppColors.lightGrey.withValues(alpha: 0.3)
                                  : AppColors.charcoalGrey.withValues(alpha: 0.3)),
                          width: 2,
                        ),
                      ),
                      child: _rememberMe
                          ? const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Lembrar-me',
                      style: TextStyle(
                        fontSize: 14,
                        color: context.isDarkMode
                            ? AppColors.secondaryText
                            : AppColors.charcoalGrey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Esqueci senha
              TextButton(
                onPressed: widget.onForgotPassword,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
                child: Text(
                  'Esqueci a senha',
                  style: TextStyle(
                    color: AppColors.primaryGreen,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}