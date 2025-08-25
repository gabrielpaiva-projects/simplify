# Exemplo de Cálculo de Preço com Porcentagem

## Configuração do Firestore
```javascript
{
  "base_prices": {
    "apartment": 149,
    "house": 180,
    "studio": 90
  },
  "multipliers": {
    "room_price": 30,      // 30% do valor total
    "bathroom_price": 25   // 25% do valor total
  },
  "extra_services": {
    "pets": 25,
    "products_included": 40
  }
}
```

## Exemplo 1: Apartamento com 3 cômodos e 2 banheiros

### Dados:
- Tipo: Apartamento
- Cômodos: 3 (1 extra, pois apartamento inclui 2 no preço base)
- Banheiros: 2 (1 extra, pois já inclui 1 no preço base)
- Produtos inclusos: Sim
- Pets: Não

### Cálculo Passo a Passo:

1. **Preço base**: R$ 149,00

2. **Adicionar serviços extras**:
   - Produtos inclusos: + R$ 40,00
   - **Subtotal**: R$ 189,00

3. **Aplicar porcentagem por cômodo extra**:
   - 1 cômodo extra × 30% de R$ 189,00
   - 1 × (189 × 0.30) = R$ 56,70
   - **Novo subtotal**: R$ 189,00 + R$ 56,70 = R$ 245,70

4. **Aplicar porcentagem por banheiro extra**:
   - 1 banheiro extra × 25% de R$ 245,70
   - 1 × (245,70 × 0.25) = R$ 61,43
   - **Total final**: R$ 245,70 + R$ 61,43 = **R$ 307,13**

## Exemplo 2: Casa com 4 cômodos e 3 banheiros + pets

### Dados:
- Tipo: Casa
- Cômodos: 4 (2 extras, pois casa inclui 2 no preço base)
- Banheiros: 3 (2 extras, pois já inclui 1 no preço base)
- Produtos inclusos: Não
- Pets: Sim

### Cálculo Passo a Passo:

1. **Preço base**: R$ 180,00

2. **Adicionar serviços extras**:
   - Pets: + R$ 25,00
   - **Subtotal**: R$ 205,00

3. **Aplicar porcentagem por cômodos extras**:
   - 2 cômodos extras × 30% de R$ 205,00
   - 2 × (205 × 0.30) = R$ 123,00
   - **Novo subtotal**: R$ 205,00 + R$ 123,00 = R$ 328,00

4. **Aplicar porcentagem por banheiros extras**:
   - 2 banheiros extras × 25% de R$ 328,00
   - 2 × (328 × 0.25) = R$ 164,00
   - **Total final**: R$ 328,00 + R$ 164,00 = **R$ 492,00**

## Importante:

⚠️ **A ordem importa!**
- Primeiro adiciona os serviços extras (valores fixos)
- Depois aplica a porcentagem dos cômodos sobre o total
- Por último aplica a porcentagem dos banheiros sobre o novo total

Isso significa que quanto mais serviços extras, maior será o impacto das porcentagens!