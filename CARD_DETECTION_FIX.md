# Correção da Detecção de Bandeira de Cartão

## Problema Identificado

O cartão **5031 4332 1540 6351** não estava sendo reconhecido como Mastercard, resultando em:
- Bandeira detectada: **unknown**
- Erro da API: **"bin_not_found"**
- Status HTTP: **500**

## Causa do Problema

O regex para detecção de Mastercard estava incompleto:
- **Regex antigo:** `^5[1-5]` - detectava apenas 51, 52, 53, 54, 55
- **Cartão 5031:** Não era detectado pois começa com 50

## Solução Aplicada

### Arquivo: `/lib/utils/card_validator.dart`

Reorganizamos a ordem de detecção e ajustamos os regexes:

1. **Elo primeiro** - Para evitar conflitos com Visa e Mastercard
2. **Visa** - Verifica 4XXX exceto ranges Elo
3. **Mastercard** - Agora detecta:
   - 51-55 (range tradicional)
   - 50XX (exceto ranges Elo: 5041, 5066, 5067, 5090)
   - 2221-2720 (novo range Mastercard)

### Código Atualizado:

```dart
// Elo: verificar primeiro para evitar conflitos
if (RegExp(r'^(4011|4312|4389|4514|4576|5041|5066|5067|5090|...)').hasMatch(cleaned)) {
  return CardBrand.elo;
}

// Visa: 4XXX exceto Elo
if (cleaned.startsWith('4') && !RegExp(r'^(4011|4312|4389|4514|4576)').hasMatch(cleaned)) {
  return CardBrand.visa;
}

// Mastercard: 51-55, 50XX (exceto Elo), 2221-2720
if (RegExp(r'^5[1-5]').hasMatch(cleaned) ||
    RegExp(r'^50[0-9]{2}').hasMatch(cleaned) && !RegExp(r'^(5041|5066|5067|5090)').hasMatch(cleaned) ||
    RegExp(r'^2(22[1-9]|2[3-9][0-9]|[3-6][0-9]{2}|7[0-1][0-9]|720)').hasMatch(cleaned)) {
  return CardBrand.mastercard;
}
```

## Ranges de Cartões Suportados

### Mastercard
- **51-55**: Range tradicional
- **50**: Incluindo 5031-5059 (exceto Elo)
- **2221-2720**: Novo range

### Visa
- **4**: Todos começando com 4 (exceto Elo)

### Elo
- **4011, 4312, 4389, 4514, 4576**: Ranges começando com 4
- **5041, 5066, 5067, 5090**: Ranges começando com 50
- **6277, 6362, 6363, 6504-6507, 6509, 6516, 6550**: Outros ranges

### American Express
- **34, 37**: Ranges tradicionais

### Hipercard
- **6062**: Range específico

## Resultado Esperado

Agora o cartão **5031 4332 1540 6351** deve ser:
- ✅ Detectado como **Mastercard**
- ✅ PaymentMethodId: **"master"**
- ✅ API deve processar corretamente

## Logs de Debug

Adicionamos logs temporários para debug:
```
DEBUG: Detectando cartão 5031...
  - É Elo 5041/5066/5067/5090? false
  - Matches 50XX? true
  - Matches 51-55? false
```

## Próximos Passos

1. **Testar novamente** o pagamento com cartão
2. **Verificar logs** para confirmar detecção como Mastercard
3. **Remover logs de debug** após confirmação
4. **Considerar adicionar mais BINs** brasileiros se necessário