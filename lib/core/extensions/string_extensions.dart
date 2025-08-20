extension StringExtensions on String? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;
  bool get isNotNullOrEmpty => !isNullOrEmpty;
  
  String get orEmpty => this ?? '';
  
  // Validações
  bool get isValidEmail {
    if (isNullOrEmpty) return false;
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(this!);
  }
  
  bool get isValidPassword {
    if (isNullOrEmpty) return false;
    // Mínimo 8 caracteres, pelo menos uma letra e um número
    final passwordRegex = RegExp(
      r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d@$!%*#?&]{8,}$',
    );
    return passwordRegex.hasMatch(this!);
  }
  
  bool get isValidPhone {
    if (isNullOrEmpty) return false;
    final phoneRegex = RegExp(
      r'^\+?[1-9]\d{1,14}$',
    );
    return phoneRegex.hasMatch(this!.replaceAll(RegExp(r'[\s\-\(\)]'), ''));
  }
  
  // Formatação
  String get capitalize {
    if (isNullOrEmpty) return '';
    return '${this![0].toUpperCase()}${this!.substring(1).toLowerCase()}';
  }
  
  String get capitalizeWords {
    if (isNullOrEmpty) return '';
    return this!.split(' ').map((word) => word.capitalize).join(' ');
  }
  
  String truncate(int maxLength, {String suffix = '...'}) {
    if (isNullOrEmpty) return '';
    if (this!.length <= maxLength) return this!;
    return '${this!.substring(0, maxLength)}$suffix';
  }
  
  // Máscaras
  String get maskEmail {
    if (!isValidEmail) return orEmpty;
    final parts = this!.split('@');
    final username = parts[0];
    final domain = parts[1];
    
    if (username.length <= 2) {
      return '$username@$domain';
    }
    
    final masked = username[0] +
        '*' * (username.length - 2) +
        username[username.length - 1];
    return '$masked@$domain';
  }
  
  String get maskPhone {
    if (isNullOrEmpty) return '';
    final cleaned = this!.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (cleaned.length < 8) return this!;
    
    final start = cleaned.substring(0, 3);
    final end = cleaned.substring(cleaned.length - 2);
    final middle = '*' * (cleaned.length - 5);
    
    return '$start$middle$end';
  }
}