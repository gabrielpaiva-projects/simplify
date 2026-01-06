class PaymentPixModel {
  final String id;
  final double amount;
  final String asaasCustomerId;
  final String asaasId;
  final String createdAt;
  final String description;
  final String expirationDate;
  final String lastWebhookDate;
  final String lastWebhookEvent;
  final String qrCode;
  final ServiceDataModel serviceData;
  final String status;
  final String statusDetail;
  final String type;
  final String updatedAt;
  final String userEmail;
  final String userId;
  final String userName;

  PaymentPixModel({
    required this.id,
    required this.amount,
    required this.asaasCustomerId,
    required this.asaasId,
    required this.createdAt,
    required this.description,
    required this.expirationDate,
    required this.lastWebhookDate,
    required this.lastWebhookEvent,
    required this.qrCode,
    required this.serviceData,
    required this.status,
    required this.statusDetail,
    required this.type,
    required this.updatedAt,
    required this.userEmail,
    required this.userId,
    required this.userName,
  });

  factory PaymentPixModel.fromFirestore(Map<String, dynamic> data, String documentId) {
    final serviceDataMap = data['serviceData'];
    
    final amount = (data['amount'] is num) ? (data['amount'] as num).toDouble() : 0.0;
    final status = (data['status'] ?? '').toString();
    final lastWebhookEvent = (data['lastWebhookEvent'] ?? '').toString();
    final qrCode = (data['qrCode'] ?? '').toString();
    
    final model = PaymentPixModel(
      id: documentId ?? '',
      amount: amount,
      asaasCustomerId: (data['asaasCustomerId'] ?? '').toString(),
      asaasId: (data['asaasId'] ?? '').toString(),
      createdAt: (data['createdAt'] ?? '').toString(),
      description: (data['description'] ?? '').toString(),
      expirationDate: (data['expirationDate'] ?? '').toString(),
      lastWebhookDate: (data['lastWebhookDate'] ?? '').toString(),
      lastWebhookEvent: lastWebhookEvent,
      qrCode: qrCode,
      serviceData: serviceDataMap != null && serviceDataMap is Map<String, dynamic> 
          ? ServiceDataModel.fromMap(serviceDataMap) 
          : ServiceDataModel.empty(),
      status: status,
      statusDetail: (data['statusDetail'] ?? '').toString(),
      type: (data['type'] ?? '').toString(),
      updatedAt: (data['updatedAt'] ?? '').toString(),
      userEmail: (data['userEmail'] ?? '').toString(),
      userId: (data['userId'] ?? '').toString(),
      userName: (data['userName'] ?? '').toString(),
    );
    
    
    return model;
  }

  String get formattedAmount {
    return 'R\$ ${amount.toStringAsFixed(2)}';
  }

  String get formattedDate {
    try {
      if (serviceData.data.isEmpty) return 'Data não informada';
      final DateTime dateTime = DateTime.parse(serviceData.data);
      return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
    } catch (e) {
      return serviceData.data.isNotEmpty ? serviceData.data : 'Data não informada';
    }
  }

  String get serviceTypeDisplayName {
    switch (serviceData.tipoLimpeza.toLowerCase()) {
      case 'padrao':
        return 'Limpeza Padrão';
      case 'pesada':
        return 'Limpeza Pesada';
      case 'passadoria':
        return 'Passadoria';
      default:
        return 'Serviço';
    }
  }

  bool get isPending {
    return status == 'PENDING';
  }

  bool get isExpired {
    try {
      if (expirationDate.isEmpty) return false;
      final DateTime expiration = DateTime.parse(expirationDate.replaceAll(' ', 'T'));
      return DateTime.now().isAfter(expiration);
    } catch (e) {
      return false;
    }
  }

  Duration get timeUntilExpiration {
    try {
      if (expirationDate.isEmpty) return Duration.zero;
      final DateTime expiration = DateTime.parse(expirationDate.replaceAll(' ', 'T'));
      final Duration diff = expiration.difference(DateTime.now());
      return diff.isNegative ? Duration.zero : diff;
    } catch (e) {
      return Duration.zero;
    }
  }

  String get shortAddress {
    try {
      if (serviceData.endereco.rua.isEmpty) return 'Endereço não informado';
      return '${serviceData.endereco.rua}, ${serviceData.endereco.numero}';
    } catch (e) {
      return 'Endereço não informado';
    }
  }

  String get fullAddress {
    try {
      return serviceData.endereco.fullAddress;
    } catch (e) {
      return 'Endereço não informado';
    }
  }
}

class ServiceDataModel {
  final String data;
  final EnderecoPixModel endereco;
  final String horario;
  final String idCliente;
  final int quantidadeBanheiros;
  final int quantidadeComodos;
  final ServicosExtrasPixModel servicosExtras;
  final String tipoImovel;
  final String tipoLimpeza;

  ServiceDataModel({
    required this.data,
    required this.endereco,
    required this.horario,
    required this.idCliente,
    required this.quantidadeBanheiros,
    required this.quantidadeComodos,
    required this.servicosExtras,
    required this.tipoImovel,
    required this.tipoLimpeza,
  });

  factory ServiceDataModel.fromMap(Map<String, dynamic> map) {
    final enderecoMap = map['endereco'];
    final servicosExtrasMap = map['servicosExtras'];
    
    return ServiceDataModel(
      data: (map['data'] ?? '').toString(),
      endereco: enderecoMap != null && enderecoMap is Map<String, dynamic>
          ? EnderecoPixModel.fromMap(enderecoMap)
          : EnderecoPixModel.empty(),
      horario: (map['horario'] ?? '').toString(),
      idCliente: (map['idCliente'] ?? '').toString(),
      quantidadeBanheiros: (map['quantidadeBanheiros'] is num) ? (map['quantidadeBanheiros'] as num).toInt() : 0,
      quantidadeComodos: (map['quantidadeComodos'] is num) ? (map['quantidadeComodos'] as num).toInt() : 0,
      servicosExtras: servicosExtrasMap != null && servicosExtrasMap is Map<String, dynamic>
          ? ServicosExtrasPixModel.fromMap(servicosExtrasMap)
          : ServicosExtrasPixModel.empty(),
      tipoImovel: (map['tipoImovel'] ?? '').toString(),
      tipoLimpeza: (map['tipoLimpeza'] ?? '').toString(),
    );
  }

  factory ServiceDataModel.empty() {
    return ServiceDataModel(
      data: '',
      endereco: EnderecoPixModel.empty(),
      horario: '',
      idCliente: '',
      quantidadeBanheiros: 0,
      quantidadeComodos: 0,
      servicosExtras: ServicosExtrasPixModel.empty(),
      tipoImovel: '',
      tipoLimpeza: '',
    );
  }
}

class EnderecoPixModel {
  final String cep;
  final String cidade;
  final String estado;
  final String numero;
  final String rua;

  EnderecoPixModel({
    required this.cep,
    required this.cidade,
    required this.estado,
    required this.numero,
    required this.rua,
  });

  factory EnderecoPixModel.fromMap(Map<String, dynamic> map) {
    return EnderecoPixModel(
      cep: (map['cep'] ?? '').toString(),
      cidade: (map['cidade'] ?? '').toString(),
      estado: (map['estado'] ?? '').toString(),
      numero: (map['numero'] ?? '').toString(),
      rua: (map['rua'] ?? '').toString(),
    );
  }

  factory EnderecoPixModel.empty() {
    return EnderecoPixModel(
      cep: '',
      cidade: '',
      estado: '',
      numero: '',
      rua: '',
    );
  }

  String get shortAddress {
    if (rua.isEmpty && numero.isEmpty) return 'Endereço não informado';
    if (rua.isEmpty) return numero;
    if (numero.isEmpty) return rua;
    return '$rua, $numero';
  }

  String get fullAddress {
    if (rua.isEmpty && numero.isEmpty) return 'Endereço não informado';
    return '$rua, $numero - $cidade, $estado - CEP: $cep';
  }
}

class ServicosExtrasPixModel {
  final double petsValor;
  final bool produtosInclusos;
  final double produtosValor;
  final bool temPets;

  ServicosExtrasPixModel({
    required this.petsValor,
    required this.produtosInclusos,
    required this.produtosValor,
    required this.temPets,
  });

  factory ServicosExtrasPixModel.fromMap(Map<String, dynamic> map) {
    return ServicosExtrasPixModel(
      petsValor: (map['petsValor'] is num) ? (map['petsValor'] as num).toDouble() : 0.0,
      produtosInclusos: (map['produtosInclusos'] is bool) ? map['produtosInclusos'] as bool : false,
      produtosValor: (map['produtosValor'] is num) ? (map['produtosValor'] as num).toDouble() : 0.0,
      temPets: (map['temPets'] is bool) ? map['temPets'] as bool : false,
    );
  }

  factory ServicosExtrasPixModel.empty() {
    return ServicosExtrasPixModel(
      petsValor: 0.0,
      produtosInclusos: false,
      produtosValor: 0.0,
      temPets: false,
    );
  }
}
