# Documentação dos Logs de Debug - Pagamento com Cartão

## Logs Adicionados

Para debugar o problema de "payment failed" no pagamento com cartão de crédito, foram adicionados logs detalhados em vários pontos do fluxo:

### 1. cleaning_schedule_screen.dart - _confirmSchedule()

**Localização:** Linha ~2542-2652

**Logs adicionados:**
- Início do processo de pagamento com cartão
- Validação dos campos (tamanho de cada campo)
- Autenticação do usuário
- Dados do cartão (mascarados para segurança)
- Resposta da API (success, error, message, payment details)
- Tratamento de exceções com stack trace

### 2. payment_service.dart - processCardPayment()

**Localização:** Linha ~102-212

**Logs adicionados:**
- Dados recebidos (userId, amount, card info mascarado)
- Validação do cartão (erros específicos se houver)
- Detecção da bandeira do cartão
- Geração da badge criptografada
- URL da API e body da requisição
- Status code e body da resposta
- Detalhes do pagamento processado
- Exceções com stack trace completo

### 3. badge_generator.dart - generateCardBadge()

**Localização:** Linha ~40-64

**Logs adicionados:**
- Dados do payload antes da criptografia
- Tamanho da badge gerada
- Confirmação de criptografia bem-sucedida

### 4. card_validator.dart - validateCard()

**Localização:** Linha ~173-215

**Logs adicionados:**
- Dados do cartão recebidos para validação
- Resultado de cada validação (✅ ou ❌)
- Total de erros encontrados

## Como Usar os Logs

1. **Execute o aplicativo** com o console/terminal aberto
2. **Tente fazer um pagamento com cartão**
3. **Observe os logs** no console na seguinte ordem:

```
=== INICIANDO PAGAMENTO COM CARTÃO ===
=== CARD VALIDATOR ===
=== BADGE GENERATOR - CARD ===
=== DEBUG CARD PAYMENT SERVICE ===
=== RESPOSTA DA API ===
```

## O que Procurar nos Logs

### Possíveis Problemas:

1. **Validação do Cartão Falhou:**
   - Procure por "❌" no CARD VALIDATOR
   - Verifique qual campo específico está falhando

2. **Problema na Badge:**
   - Verifique se a badge está sendo gerada corretamente
   - Confirme o tamanho da badge (deve ser > 0)

3. **Erro na API:**
   - Verifique o "Response Status Code"
   - Se não for 200/201, veja o "Response Body" para detalhes do erro
   - Procure por mensagens de erro específicas

4. **Dados Incorretos:**
   - Verifique se o formato da data está correto (MM/YYYY)
   - Confirme que o número do cartão tem 16 dígitos
   - Verifique se o CVV tem 3-4 dígitos

## Exemplos de Logs de Sucesso

```
✅ Card number is valid
✅ Expiry date is valid
✅ CVV is valid
✅ Card holder name is valid
Total errors: 0
Response Status Code: 200
Is Approved: true
SUCESSO: Pagamento aprovado!
```

## Exemplos de Logs de Erro

```
❌ Card number validation failed
Response Status Code: 400
Error Data: {"error": "Invalid card data"}
ERRO: Dados do cartão inválidos
```

## Próximos Passos

Após identificar o problema através dos logs:

1. Se for **validação local**: Ajustar os campos do formulário
2. Se for **erro da API**: Verificar o formato dos dados enviados
3. Se for **problema de autenticação**: Verificar o userId e a badge
4. Se for **cartão recusado**: Verificar com a operadora do cartão

## Removendo os Logs

Após resolver o problema, remova os logs de produção procurando por:
- `print('===`
- `print('ERRO:`
- `print('SUCESSO:`
- `print('✅`
- `print('❌`