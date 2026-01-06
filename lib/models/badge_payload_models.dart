
import 'dart:convert';

class BadgePayload {
  final String userId;
  final double amount;
  final int? timestamp;
  final ServiceSchedulingData? serviceData;

  BadgePayload({
    required this.userId,
    required this.amount,
    this.timestamp,
    this.serviceData,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'userId': userId,
      'amount': amount,
    };

    if (timestamp != null) {
      json['timestamp'] = timestamp;
    }

    if (serviceData != null) {
      json['serviceData'] = serviceData!.toJson();
    }

    return json;
  }

  factory BadgePayload.fromJson(Map<String, dynamic> json) {
    return BadgePayload(
      userId: json['userId'] as String,
      amount: (json['amount'] as num).toDouble(),
      timestamp: json['timestamp'] as int?,
      serviceData: json['serviceData'] != null
          ? ServiceSchedulingData.fromJson(json['serviceData'] as Map<String, dynamic>)
          : null,
    );
  }

  String toJsonString() => jsonEncode(toJson());
}

class CardBadgePayload extends BadgePayload {
  final String cardNumber;
  final String expirationYear;
  final String expirationMonth;
  final String securityCode;
  final int installments;

  CardBadgePayload({
    required super.userId,
    required super.amount,
    super.timestamp,
    super.serviceData,
    required this.cardNumber,
    required this.expirationYear,
    required this.expirationMonth,
    required this.securityCode,
    this.installments = 1,
  });

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({
      'cardNumber': cardNumber,
      'expirationYear': expirationYear,
      'expirationMonth': expirationMonth,
      'securityCode': securityCode,
      'installments': installments,
    });
    return json;
  }

  factory CardBadgePayload.fromJson(Map<String, dynamic> json) {
    return CardBadgePayload(
      userId: json['userId'] as String,
      amount: (json['amount'] as num).toDouble(),
      timestamp: json['timestamp'] as int?,
      serviceData: json['serviceData'] != null
          ? ServiceSchedulingData.fromJson(json['serviceData'] as Map<String, dynamic>)
          : null,
      cardNumber: json['cardNumber'] as String,
      expirationYear: json['expirationYear'] as String,
      expirationMonth: json['expirationMonth'] as String,
      securityCode: json['securityCode'] as String,
      installments: (json['installments'] as int?) ?? 1,
    );
  }
}

class ServiceSchedulingData {
  final String idCliente;
  final TipoLimpeza tipoLimpeza;
  final int quantidadeComodos;
  final int quantidadeBanheiros;
  final ServicosExtras servicosExtras;
  final TipoImovel tipoImovel;
  final String data; // ISO date string
  final String horario;
  final Endereco endereco;

  ServiceSchedulingData({
    required this.idCliente,
    required this.tipoLimpeza,
    required this.quantidadeComodos,
    required this.quantidadeBanheiros,
    required this.servicosExtras,
    required this.tipoImovel,
    required this.data,
    required this.horario,
    required this.endereco,
  });

  Map<String, dynamic> toJson() {
    return {
      'idCliente': idCliente,
      'tipoLimpeza': tipoLimpeza.value,
      'quantidadeComodos': quantidadeComodos,
      'quantidadeBanheiros': quantidadeBanheiros,
      'servicosExtras': servicosExtras.toJson(),
      'tipoImovel': tipoImovel.value,
      'data': data,
      'horario': horario,
      'endereco': endereco.toJson(),
    };
  }

  factory ServiceSchedulingData.fromJson(Map<String, dynamic> json) {
    return ServiceSchedulingData(
      idCliente: json['idCliente'] as String,
      tipoLimpeza: TipoLimpeza.fromString(json['tipoLimpeza'] as String),
      quantidadeComodos: json['quantidadeComodos'] as int,
      quantidadeBanheiros: json['quantidadeBanheiros'] as int,
      servicosExtras: ServicosExtras.fromJson(json['servicosExtras'] as Map<String, dynamic>),
      tipoImovel: TipoImovel.fromString(json['tipoImovel'] as String),
      data: json['data'] as String,
      horario: json['horario'] as String,
      endereco: Endereco.fromJson(json['endereco'] as Map<String, dynamic>),
    );
  }
}

class ServicosExtras {
  final bool produtosInclusos;
  final double produtosValor; // 0 se não tiver
  final bool temPets;
  final double petsValor; // 0 se não tiver

  ServicosExtras({
    required this.produtosInclusos,
    required this.produtosValor,
    required this.temPets,
    required this.petsValor,
  });

  Map<String, dynamic> toJson() {
    return {
      'produtosInclusos': produtosInclusos,
      'produtosValor': produtosValor,
      'temPets': temPets,
      'petsValor': petsValor,
    };
  }

  factory ServicosExtras.fromJson(Map<String, dynamic> json) {
    return ServicosExtras(
      produtosInclusos: json['produtosInclusos'] as bool,
      produtosValor: (json['produtosValor'] as num).toDouble(),
      temPets: json['temPets'] as bool,
      petsValor: (json['petsValor'] as num).toDouble(),
    );
  }
}

class Endereco {
  final String rua;
  final String numero;
  final String? complemento;
  final String cidade;
  final String estado;
  final String cep;

  Endereco({
    required this.rua,
    required this.numero,
    this.complemento,
    required this.cidade,
    required this.estado,
    required this.cep,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'rua': rua,
      'numero': numero,
      'cidade': cidade,
      'estado': estado,
      'cep': cep,
    };

    if (complemento != null && complemento!.isNotEmpty) {
      json['complemento'] = complemento;
    }

    return json;
  }

  factory Endereco.fromJson(Map<String, dynamic> json) {
    return Endereco(
      rua: json['rua'] as String,
      numero: json['numero'] as String,
      complemento: json['complemento'] as String?,
      cidade: json['cidade'] as String,
      estado: json['estado'] as String,
      cep: json['cep'] as String,
    );
  }
}

enum TipoLimpeza {
  pesada('pesada'),
  padrao('padrao'),
  passadoria('passadoria');

  const TipoLimpeza(this.value);
  final String value;

  static TipoLimpeza fromString(String value) {
    switch (value) {
      case 'pesada':
        return TipoLimpeza.pesada;
      case 'padrao':
        return TipoLimpeza.padrao;
      case 'passadoria':
        return TipoLimpeza.passadoria;
      default:
        throw ArgumentError('Invalid TipoLimpeza: $value');
    }
  }
}

enum TipoImovel {
  studio('studio'),
  apartamento('apartamento'),
  casa('casa');

  const TipoImovel(this.value);
  final String value;

  static TipoImovel fromString(String value) {
    switch (value) {
      case 'studio':
        return TipoImovel.studio;
      case 'apartamento':
        return TipoImovel.apartamento;
      case 'casa':
        return TipoImovel.casa;
      default:
        throw ArgumentError('Invalid TipoImovel: $value');
    }
  }
}

class BadgeBuilder {
  String? _userId;
  double? _amount;
  int? _timestamp;
  ServiceSchedulingData? _serviceData;

  String? _cardNumber;
  String? _expirationYear;
  String? _expirationMonth;
  String? _securityCode;
  int? _installments;

  BadgeBuilder();

  BadgeBuilder setUserId(String userId) {
    _userId = userId;
    return this;
  }

  BadgeBuilder setAmount(double amount) {
    _amount = amount;
    return this;
  }

  BadgeBuilder setTimestamp([int? timestamp]) {
    _timestamp = timestamp ?? DateTime.now().millisecondsSinceEpoch;
    return this;
  }

  BadgeBuilder setServiceData(ServiceSchedulingData serviceData) {
    _serviceData = serviceData;
    return this;
  }

  BadgeBuilder setCardData({
    required String cardNumber,
    required String expirationYear,
    required String expirationMonth,
    required String securityCode,
    int installments = 1,
  }) {
    _cardNumber = cardNumber;
    _expirationYear = expirationYear;
    _expirationMonth = expirationMonth;
    _securityCode = securityCode;
    _installments = installments;
    return this;
  }

  BadgePayload buildPixBadge() {
    if (_userId == null || _amount == null) {
      throw ArgumentError('userId and amount are required');
    }

    return BadgePayload(
      userId: _userId!,
      amount: _amount!,
      timestamp: _timestamp,
      serviceData: _serviceData,
    );
  }

  CardBadgePayload buildCardBadge() {
    if (_userId == null || _amount == null) {
      throw ArgumentError('userId and amount are required');
    }

    if (_cardNumber == null || _expirationYear == null || 
        _expirationMonth == null || _securityCode == null) {
      throw ArgumentError('Card data is required for card badge');
    }

    return CardBadgePayload(
      userId: _userId!,
      amount: _amount!,
      timestamp: _timestamp,
      serviceData: _serviceData,
      cardNumber: _cardNumber!,
      expirationYear: _expirationYear!,
      expirationMonth: _expirationMonth!,
      securityCode: _securityCode!,
      installments: _installments ?? 1,
    );
  }
}

class ServiceDataBuilder {
  String? _idCliente;
  TipoLimpeza? _tipoLimpeza;
  int? _quantidadeComodos;
  int? _quantidadeBanheiros;
  ServicosExtras? _servicosExtras;
  TipoImovel? _tipoImovel;
  String? _data;
  String? _horario;
  Endereco? _endereco;

  ServiceDataBuilder();

  ServiceDataBuilder setIdCliente(String idCliente) {
    _idCliente = idCliente;
    return this;
  }

  ServiceDataBuilder setTipoLimpeza(TipoLimpeza tipoLimpeza) {
    _tipoLimpeza = tipoLimpeza;
    return this;
  }

  ServiceDataBuilder setQuantidades({
    required int comodos,
    required int banheiros,
  }) {
    _quantidadeComodos = comodos;
    _quantidadeBanheiros = banheiros;
    return this;
  }

  ServiceDataBuilder setServicosExtras({
    bool produtosInclusos = false,
    double produtosValor = 0,
    bool temPets = false,
    double petsValor = 0,
  }) {
    _servicosExtras = ServicosExtras(
      produtosInclusos: produtosInclusos,
      produtosValor: produtosInclusos ? produtosValor : 0,
      temPets: temPets,
      petsValor: temPets ? petsValor : 0,
    );
    return this;
  }

  ServiceDataBuilder setTipoImovel(TipoImovel tipoImovel) {
    _tipoImovel = tipoImovel;
    return this;
  }

  ServiceDataBuilder setDataHorario({
    required DateTime data,
    required String horario,
  }) {
    _data = data.toIso8601String();
    _horario = horario;
    return this;
  }

  ServiceDataBuilder setEndereco({
    required String rua,
    required String numero,
    String? complemento,
    required String cidade,
    required String estado,
    required String cep,
  }) {
    _endereco = Endereco(
      rua: rua,
      numero: numero,
      complemento: complemento,
      cidade: cidade,
      estado: estado,
      cep: cep,
    );
    return this;
  }

  ServiceSchedulingData build() {
    if (_idCliente == null || _tipoLimpeza == null || _quantidadeComodos == null ||
        _quantidadeBanheiros == null || _tipoImovel == null || 
        _data == null || _horario == null || _endereco == null) {
      throw ArgumentError('All required fields must be set');
    }

    return ServiceSchedulingData(
      idCliente: _idCliente!,
      tipoLimpeza: _tipoLimpeza!,
      quantidadeComodos: _quantidadeComodos!,
      quantidadeBanheiros: _quantidadeBanheiros!,
      servicosExtras: _servicosExtras ?? ServicosExtras(
        produtosInclusos: false,
        produtosValor: 0,
        temPets: false,
        petsValor: 0,
      ),
      tipoImovel: _tipoImovel!,
      data: _data!,
      horario: _horario!,
      endereco: _endereco!,
    );
  }
}
