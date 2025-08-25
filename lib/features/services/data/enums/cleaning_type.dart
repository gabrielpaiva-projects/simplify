// Enum for cleaning service types
enum CleaningType {
  standard('limpeza_padrao'),   // Limpeza padrão
  heavy('limpeza_pesada');       // Limpeza pesada
  
  final String documentName;
  
  const CleaningType(this.documentName);
  
  // Get display name in Portuguese
  String get displayName {
    switch (this) {
      case CleaningType.standard:
        return 'Limpeza Padrão';
      case CleaningType.heavy:
        return 'Limpeza Pesada';
    }
  }
  
  // Get short name for UI
  String get shortName {
    switch (this) {
      case CleaningType.standard:
        return 'Padrão';
      case CleaningType.heavy:
        return 'Pesada';
    }
  }
  
  // Factory method to create from string
  static CleaningType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'standard':
      case 'padrao':
      case 'padrão':
      case 'limpeza_padrao':
        return CleaningType.standard;
      case 'heavy':
      case 'pesada':
      case 'limpeza_pesada':
        return CleaningType.heavy;
      default:
        return CleaningType.standard; // Default to standard
    }
  }
}