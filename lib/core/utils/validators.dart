class Validators {
  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static final RegExp _phoneRegExp = RegExp(
    r'^\(?[1-9]{2}\)? ?(?:[2-8]|9[0-9])[0-9]{3}\-?[0-9]{4}$',
  );

  static final RegExp _cpfRegExp = RegExp(
    r'^\d{3}\.\d{3}\.\d{3}\-\d{2}$|^\d{11}$',
  );

  static final RegExp _cnpjRegExp = RegExp(
    r'^\d{2}\.\d{3}\.\d{3}\/\d{4}\-\d{2}$|^\d{14}$',
  );

  static final RegExp _cepRegExp = RegExp(
    r'^\d{5}\-?\d{3}$',
  );

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'E-mail é obrigatório';
    }
    if (!_emailRegExp.hasMatch(value)) {
      return 'E-mail inválido';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Senha é obrigatória';
    }
    if (value.length < 6) {
      return 'Senha deve ter pelo menos 6 caracteres';
    }
    return null;
  }

  static String? validateStrongPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Senha é obrigatória';
    }
    if (value.length < 8) {
      return 'Senha deve ter pelo menos 8 caracteres';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Senha deve conter pelo menos uma letra maiúscula';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Senha deve conter pelo menos uma letra minúscula';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Senha deve conter pelo menos um número';
    }
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Senha deve conter pelo menos um caractere especial';
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nome é obrigatório';
    }
    if (value.length < 3) {
      return 'Nome deve ter pelo menos 3 caracteres';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Telefone é obrigatório';
    }
    final cleaned = value.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.length < 10 || cleaned.length > 11) {
      return 'Telefone inválido';
    }
    return null;
  }

  static String? validateCPF(String? value) {
    if (value == null || value.isEmpty) {
      return 'CPF é obrigatório';
    }
    
    final cpf = value.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cpf.length != 11) {
      return 'CPF inválido';
    }
    
    if (RegExp(r'^(\d)\1{10}$').hasMatch(cpf)) {
      return 'CPF inválido';
    }
    
    if (!_isValidCPF(cpf)) {
      return 'CPF inválido';
    }
    
    return null;
  }

  static String? validateCNPJ(String? value) {
    if (value == null || value.isEmpty) {
      return 'CNPJ é obrigatório';
    }
    
    final cnpj = value.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cnpj.length != 14) {
      return 'CNPJ inválido';
    }
    
    if (RegExp(r'^(\d)\1{13}$').hasMatch(cnpj)) {
      return 'CNPJ inválido';
    }
    
    if (!_isValidCNPJ(cnpj)) {
      return 'CNPJ inválido';
    }
    
    return null;
  }

  static String? validateCEP(String? value) {
    if (value == null || value.isEmpty) {
      return 'CEP é obrigatório';
    }
    if (!_cepRegExp.hasMatch(value)) {
      return 'CEP inválido';
    }
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName é obrigatório';
    }
    return null;
  }

  static String? Function(String?) validateMinLength(int minLength, String fieldName) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return '$fieldName é obrigatório';
      }
      if (value.length < minLength) {
        return '$fieldName deve ter pelo menos $minLength caracteres';
      }
      return null;
    };
  }

  static String? Function(String?) validateMaxLength(int maxLength, String fieldName) {
    return (String? value) {
      if (value != null && value.length > maxLength) {
        return '$fieldName deve ter no máximo $maxLength caracteres';
      }
      return null;
    };
  }

  static bool _isValidCPF(String cpf) {
    List<int> numbers = cpf.split('').map((e) => int.parse(e)).toList();
    
    int sum = 0;
    for (int i = 0; i < 9; i++) {
      sum += numbers[i] * (10 - i);
    }
    
    int firstDigit = (sum * 10) % 11;
    if (firstDigit == 10) firstDigit = 0;
    
    if (firstDigit != numbers[9]) return false;
    
    sum = 0;
    for (int i = 0; i < 10; i++) {
      sum += numbers[i] * (11 - i);
    }
    
    int secondDigit = (sum * 10) % 11;
    if (secondDigit == 10) secondDigit = 0;
    
    return secondDigit == numbers[10];
  }

  static bool _isValidCNPJ(String cnpj) {
    List<int> numbers = cnpj.split('').map((e) => int.parse(e)).toList();
    
    const firstMultipliers = [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
    const secondMultipliers = [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
    
    int sum = 0;
    for (int i = 0; i < 12; i++) {
      sum += numbers[i] * firstMultipliers[i];
    }
    
    int firstDigit = sum % 11;
    firstDigit = firstDigit < 2 ? 0 : 11 - firstDigit;
    
    if (firstDigit != numbers[12]) return false;
    
    sum = 0;
    for (int i = 0; i < 13; i++) {
      sum += numbers[i] * secondMultipliers[i];
    }
    
    int secondDigit = sum % 11;
    secondDigit = secondDigit < 2 ? 0 : 11 - secondDigit;
    
    return secondDigit == numbers[13];
  }
}