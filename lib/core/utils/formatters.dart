import 'package:intl/intl.dart';

class Formatters {
  // Formatação de data
  static String formatDate(DateTime date, {String pattern = 'dd/MM/yyyy'}) {
    return DateFormat(pattern, 'pt_BR').format(date);
  }
  
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm', 'pt_BR').format(dateTime);
  }
  
  static String formatTime(DateTime time) {
    return DateFormat('HH:mm', 'pt_BR').format(time);
  }
  
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'ano' : 'anos'} atrás';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'mês' : 'meses'} atrás';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'dia' : 'dias'} atrás';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hora' : 'horas'} atrás';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minuto' : 'minutos'} atrás';
    } else {
      return 'Agora mesmo';
    }
  }
  
  // Formatação de moeda
  static String formatCurrency(double value) {
    final formatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );
    return formatter.format(value);
  }
  
  static String formatCompactCurrency(double value) {
    if (value >= 1000000) {
      return 'R\$ ${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return 'R\$ ${(value / 1000).toStringAsFixed(1)}K';
    } else {
      return formatCurrency(value);
    }
  }
  
  // Formatação de telefone
  static String formatPhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cleaned.length == 11) {
      return '(${cleaned.substring(0, 2)}) ${cleaned.substring(2, 7)}-${cleaned.substring(7)}';
    } else if (cleaned.length == 10) {
      return '(${cleaned.substring(0, 2)}) ${cleaned.substring(2, 6)}-${cleaned.substring(6)}';
    } else {
      return phone;
    }
  }
  
  // Formatação de CEP
  static String formatCep(String cep) {
    final cleaned = cep.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cleaned.length == 8) {
      return '${cleaned.substring(0, 5)}-${cleaned.substring(5)}';
    } else {
      return cep;
    }
  }
  
  // Formatação de CPF
  static String formatCpf(String cpf) {
    final cleaned = cpf.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cleaned.length == 11) {
      return '${cleaned.substring(0, 3)}.${cleaned.substring(3, 6)}.${cleaned.substring(6, 9)}-${cleaned.substring(9)}';
    } else {
      return cpf;
    }
  }
  
  // Formatação de CNPJ
  static String formatCnpj(String cnpj) {
    final cleaned = cnpj.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cleaned.length == 14) {
      return '${cleaned.substring(0, 2)}.${cleaned.substring(2, 5)}.${cleaned.substring(5, 8)}/${cleaned.substring(8, 12)}-${cleaned.substring(12)}';
    } else {
      return cnpj;
    }
  }
  
  // Formatação de porcentagem
  static String formatPercentage(double value, {int decimals = 0}) {
    return '${(value * 100).toStringAsFixed(decimals)}%';
  }
  
  // Formatação de número
  static String formatNumber(num value, {int decimals = 0}) {
    final formatter = NumberFormat.decimalPattern('pt_BR');
    formatter.minimumFractionDigits = decimals;
    formatter.maximumFractionDigits = decimals;
    return formatter.format(value);
  }
  
  // Formatação de tamanho de arquivo
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }
}