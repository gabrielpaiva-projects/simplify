class AppointmentModel {
  final String id;
  final String createdAt;
  final String data;
  final AddressModel endereco;
  final String horario;
  final String idCliente;
  final String idServico;
  final double paymentAmount;
  final String paymentId;
  final String paymentStatus;
  final String paymentType;
  final String? profissionalId;
  final int quantidadeBanheiros;
  final int quantidadeComodos;
  final ServicosExtrasModel servicosExtras;
  final String tipoImovel;
  final String tipoLimpeza;
  final String updatedAt;
  final String userEmail;
  final String userId;
  final String userName;

  AppointmentModel({
    required this.id,
    required this.createdAt,
    required this.data,
    required this.endereco,
    required this.horario,
    required this.idCliente,
    required this.idServico,
    required this.paymentAmount,
    required this.paymentId,
    required this.paymentStatus,
    required this.paymentType,
    this.profissionalId,
    required this.quantidadeBanheiros,
    required this.quantidadeComodos,
    required this.servicosExtras,
    required this.tipoImovel,
    required this.tipoLimpeza,
    required this.updatedAt,
    required this.userEmail,
    required this.userId,
    required this.userName,
  });

  factory AppointmentModel.fromFirestore(Map<String, dynamic> data, String documentId) {
    return AppointmentModel(
      id: documentId,
      createdAt: data['createdAt'] ?? '',
      data: data['data'] ?? '',
      endereco: AddressModel.fromMap(data['endereco'] ?? {}),
      horario: data['horario'] ?? '',
      idCliente: data['idCliente'] ?? '',
      idServico: data['idServico'] ?? '',
      paymentAmount: (data['paymentAmount'] ?? 0).toDouble(),
      paymentId: data['paymentId'] ?? '',
      paymentStatus: data['paymentStatus'] ?? '',
      paymentType: data['paymentType'] ?? '',
      profissionalId: data['profissionalId']?.toString(),
      quantidadeBanheiros: data['quantidadeBanheiros'] ?? 0,
      quantidadeComodos: data['quantidadeComodos'] ?? 0,
      servicosExtras: ServicosExtrasModel.fromMap(data['servicosExtras'] ?? {}),
      tipoImovel: data['tipoImovel'] ?? '',
      tipoLimpeza: data['tipoLimpeza'] ?? '',
      updatedAt: data['updatedAt'] ?? '',
      userEmail: data['userEmail'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'createdAt': createdAt,
      'data': data,
      'endereco': endereco.toMap(),
      'horario': horario,
      'idCliente': idCliente,
      'idServico': idServico,
      'paymentAmount': paymentAmount,
      'paymentId': paymentId,
      'paymentStatus': paymentStatus,
      'paymentType': paymentType,
      'profissionalId': profissionalId,
      'quantidadeBanheiros': quantidadeBanheiros,
      'quantidadeComodos': quantidadeComodos,
      'servicosExtras': servicosExtras.toMap(),
      'tipoImovel': tipoImovel,
      'tipoLimpeza': tipoLimpeza,
      'updatedAt': updatedAt,
      'userEmail': userEmail,
      'userId': userId,
      'userName': userName,
    };
  }

  String get formattedDate {
    try {
      final DateTime dateTime = DateTime.parse(data);
      return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
    } catch (e) {
      return data;
    }
  }

  String get formattedTime {
    return horario;
  }

  String get serviceTypeDisplayName {
    switch (tipoLimpeza.toLowerCase()) {
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

  String get propertyTypeDisplayName {
    switch (tipoImovel.toLowerCase()) {
      case 'apartamento':
        return 'Apartamento';
      case 'casa':
        return 'Casa';
      case 'comercial':
        return 'Comercial';
      default:
        return tipoImovel;
    }
  }

  String get paymentStatusDisplayName {
    switch (paymentStatus.toUpperCase()) {
      case 'CONFIRMED':
        return 'Confirmado';
      case 'PENDING':
        return 'Pendente';
      case 'CANCELLED':
        return 'Cancelado';
      case 'REFUNDED':
        return 'Reembolsado';
      default:
        return paymentStatus;
    }
  }

  String get paymentTypeDisplayName {
    switch (paymentType.toLowerCase()) {
      case 'card':
        return 'Cartão';
      case 'pix':
        return 'PIX';
      case 'cash':
        return 'Dinheiro';
      default:
        return paymentType;
    }
  }

  bool get isUpcoming {
    try {
      final DateTime appointmentDate = DateTime.parse(data);
      final DateTime now = DateTime.now();
      return appointmentDate.isAfter(now);
    } catch (e) {
      return false;
    }
  }

  bool get isPaid {
    return paymentStatus.toUpperCase() == 'CONFIRMED';
  }

  String get displayName {
    return serviceTypeDisplayName;
  }

  String get shortAddress {
    return endereco.shortAddress;
  }

  String get status {
    return paymentStatusDisplayName;
  }

  String get formattedAmount {
    return 'R\$ ${paymentAmount.toStringAsFixed(2)}';
  }
}

class AddressModel {
  final String cep;
  final String cidade;
  final String estado;
  final String numero;
  final String rua;

  AddressModel({
    required this.cep,
    required this.cidade,
    required this.estado,
    required this.numero,
    required this.rua,
  });

  factory AddressModel.fromMap(Map<String, dynamic> map) {
    return AddressModel(
      cep: map['cep'] ?? '',
      cidade: map['cidade'] ?? '',
      estado: map['estado'] ?? '',
      numero: map['numero'] ?? '',
      rua: map['rua'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cep': cep,
      'cidade': cidade,
      'estado': estado,
      'numero': numero,
      'rua': rua,
    };
  }

  String get fullAddress {
    return '$rua, $numero - $cidade, $estado - CEP: $cep';
  }

  String get shortAddress {
    return '$rua, $numero';
  }
}

class ServicosExtrasModel {
  final double petsValor;
  final bool produtosInclusos;
  final double produtosValor;
  final bool temPets;

  ServicosExtrasModel({
    required this.petsValor,
    required this.produtosInclusos,
    required this.produtosValor,
    required this.temPets,
  });

  factory ServicosExtrasModel.fromMap(Map<String, dynamic> map) {
    return ServicosExtrasModel(
      petsValor: (map['petsValor'] ?? 0).toDouble(),
      produtosInclusos: map['produtosInclusos'] ?? false,
      produtosValor: (map['produtosValor'] ?? 0).toDouble(),
      temPets: map['temPets'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'petsValor': petsValor,
      'produtosInclusos': produtosInclusos,
      'produtosValor': produtosValor,
      'temPets': temPets,
    };
  }

  double get totalExtrasValue {
    return petsValor + (produtosInclusos ? produtosValor : 0);
  }
}
