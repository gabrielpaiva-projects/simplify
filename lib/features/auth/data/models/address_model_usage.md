# AddressModel - Guia de Uso

## Estrutura do Modelo

O `AddressModel` segue o padrão da API ViaCEP brasileira, usando nomes de campos em português:

```dart
class AddressModel {
  final String cep;          // CEP formatado
  final String logradouro;   // Nome da rua/avenida
  final String? complemento; // Complemento do endereço
  final String bairro;       // Nome do bairro
  final String localidade;   // Nome da cidade
  final String uf;           // Sigla do estado (2 letras)
  final String? ibge;        // Código IBGE
  final String? gia;         // Código GIA
  final String? ddd;         // Código DDD da região
  final String? siafi;       // Código SIAFI
}
```

## Uso Correto

### ✅ CORRETO:
```dart
if (address != null) {
  setState(() {
    _streetController.text = address.logradouro;
    _neighborhoodController.text = address.bairro;
    _cityController.text = address.localidade;
    _stateController.text = address.uf;
  });
}
```

### ❌ INCORRETO:
```dart
// Estes campos não existem no modelo
_streetController.text = address.street;        // ❌
_neighborhoodController.text = address.neighborhood; // ❌
_cityController.text = address.city;            // ❌
_stateController.text = address.state;          // ❌
```

## Mapeamento de Campos

| Campo do Formulário | Campo do AddressModel |
|-------------------|---------------------|
| Rua/Logradouro    | `logradouro`       |
| Bairro            | `bairro`           |
| Cidade            | `localidade`       |
| Estado/UF         | `uf`               |
| CEP               | `cep`              |
| Complemento       | `complemento`      |

## Validação

Use o getter `isValid` para verificar se o endereço é válido:

```dart
if (address != null && address.isValid) {
  // Endereço válido com CEP e logradouro preenchidos
}
```

## Integração com ViaCEP

O modelo é compatível com a resposta da API ViaCEP:

```dart
final response = await http.get(
  Uri.parse('https://viacep.com.br/ws/$cep/json/')
);

final address = AddressModel.fromJson(json.decode(response.body));
```

## Observações

- Os campos seguem a nomenclatura oficial brasileira
- O campo `uf` sempre retorna a sigla do estado (ex: "SP", "RJ")
- O campo `localidade` retorna o nome completo da cidade
- Campos opcionais podem ser `null` dependendo do CEP