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
   - **Base para cálculo de porcentagem**: R$ 189,00

3. **Aplicar porcentagem por cômodo extra**:
   - 1 cômodo extra × 30% de R$ 189,00
   - 1 × (189 × 0.30) = R$ 56,70

4. **Aplicar porcentagem por banheiro extra**:
   - 1 banheiro extra × 25% de R$ 189,00 (usa a mesma base!)
   - 1 × (189 × 0.25) = R$ 47,25

5. **Total final**: 
   - R$ 189,00 + R$ 56,70 + R$ 47,25 = **R$ 292,95**

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
   - **Base para cálculo de porcentagem**: R$ 205,00

3. **Aplicar porcentagem por cômodos extras**:
   - 2 cômodos extras × 30% de R$ 205,00
   - 2 × (205 × 0.30) = R$ 123,00

4. **Aplicar porcentagem por banheiros extras**:
   - 2 banheiros extras × 25% de R$ 205,00 (usa a mesma base!)
   - 2 × (205 × 0.25) = R$ 102,50

5. **Total final**:
   - R$ 205,00 + R$ 123,00 + R$ 102,50 = **R$ 430,50**

## Importante:

⚠️ **Porcentagens são calculadas sobre o valor BASE, não acumuladas!**
- Base = Preço do imóvel + Serviços extras (valores fixos)
- Porcentagem dos cômodos: aplicada sobre a BASE
- Porcentagem dos banheiros: aplicada sobre a BASE (não sobre o total com cômodos)

## Cômodos Inclusos no Preço Base:
- **Studio**: 1 cômodo incluso
- **Apartamento**: 2 cômodos inclusos
- **Casa**: 2 cômodos inclusos

## Banheiros Inclusos no Preço Base:
- **Todos os tipos**: 1 banheiro incluso