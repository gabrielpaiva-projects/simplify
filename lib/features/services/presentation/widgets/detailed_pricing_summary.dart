import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cleaning_config_provider.dart';

class DetailedPricingSummary extends StatelessWidget {
  final String residenceType;
  final int rooms;
  final int bathrooms;
  final bool includeProducts;
  final bool includePets;

  const DetailedPricingSummary({
    Key? key,
    required this.residenceType,
    required this.rooms,
    required this.bathrooms,
    required this.includeProducts,
    required this.includePets,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CleaningConfigProvider>(
      builder: (context, configProvider, child) {
        if (!configProvider.hasConfig) {
          return const SizedBox.shrink();
        }

        final config = configProvider.config!;
        
        // Get all values from Firestore
        final basePrice = config.getBasePrice(residenceType);
        final baseTime = config.getBaseTime(residenceType);
        
        // Calculate base total (base price + extras)
        double baseTotal = basePrice;
        final productsCost = includeProducts ? config.getProductsIncludedPrice() : 0;
        final petsCost = includePets ? config.getPetsExtraPrice() : 0;
        baseTotal += productsCost + petsCost;
        
        // Calculate extra rooms percentage
        final baseRooms = residenceType == 'studio' ? 1 : 2;
        final extraRooms = rooms > baseRooms ? rooms - baseRooms : 0;
        final roomPricePercentage = config.getRoomPriceMultiplier(); // This is a percentage
        final roomTimeMultiplier = config.getRoomTimeMultiplier();
        final extraRoomsCost = extraRooms > 0 ? baseTotal * (roomPricePercentage / 100) * extraRooms : 0;
        final extraRoomsTime = (extraRooms * roomTimeMultiplier).toInt();
        
        // Update total after rooms
        double totalAfterRooms = baseTotal + extraRoomsCost;
        
        // Calculate extra bathrooms percentage
        final extraBathrooms = bathrooms > 1 ? bathrooms - 1 : 0;
        final bathroomPricePercentage = config.getBathroomPriceMultiplier(); // This is a percentage
        final bathroomTimeMultiplier = config.getBathroomTimeMultiplier();
        final extraBathroomsCost = extraBathrooms > 0 ? totalAfterRooms * (bathroomPricePercentage / 100) * extraBathrooms : 0;
        final extraBathroomsTime = (extraBathrooms * bathroomTimeMultiplier).toInt();
        
        // Extra time for pets
        final petsExtraTime = includePets ? config.getPetsExtraTime().toInt() : 0;
        
        // Final totals
        final totalPrice = totalAfterRooms + extraBathroomsCost;
        final totalTime = baseTime + extraRoomsTime + extraBathroomsTime + petsExtraTime;
        
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.receipt_long, color: Colors.indigo.shade600, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Resumo Detalhado (Dados do Firestore)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              
              // Base values section
              _buildSectionTitle('📊 Valores Base'),
              _buildDetailRow(
                '${_getResidenceLabel(residenceType)} - Preço base',
                'R\$ ${basePrice.toStringAsFixed(2)}',
                subtitle: 'base_prices.$residenceType',
              ),
              _buildDetailRow(
                '${_getResidenceLabel(residenceType)} - Tempo base',
                '${_formatTime(baseTime)}',
                subtitle: 'base_times.$residenceType',
              ),
              
              if (extraRooms > 0) ...[
                const SizedBox(height: 16),
                _buildSectionTitle('🏠 Cômodos Extras'),
                _buildDetailRow(
                  '$extraRooms cômodo(s) extra(s)',
                  'R\$ ${extraRoomsCost.toStringAsFixed(2)}',
                  subtitle: '${roomPricePercentage.toStringAsFixed(0)}% sobre R\$ ${baseTotal.toStringAsFixed(2)} × $extraRooms (multipliers.room_price)',
                ),
                _buildDetailRow(
                  'Tempo adicional por cômodos',
                  '${_formatTime(extraRoomsTime)}',
                  subtitle: '$extraRooms × ${roomTimeMultiplier}min (multipliers.room_time)',
                ),
              ],
              
              if (extraBathrooms > 0) ...[
                const SizedBox(height: 16),
                _buildSectionTitle('🚿 Banheiros Extras'),
                _buildDetailRow(
                  '$extraBathrooms banheiro(s) extra(s)',
                  'R\$ ${extraBathroomsCost.toStringAsFixed(2)}',
                  subtitle: '${bathroomPricePercentage.toStringAsFixed(0)}% sobre R\$ ${totalAfterRooms.toStringAsFixed(2)} × $extraBathrooms (multipliers.bathroom_price)',
                ),
                _buildDetailRow(
                  'Tempo adicional por banheiros',
                  '${_formatTime(extraBathroomsTime)}',
                  subtitle: '$extraBathrooms × ${bathroomTimeMultiplier}min (multipliers.bathroom_time)',
                ),
              ],
              
              if (includeProducts || includePets) ...[
                const SizedBox(height: 16),
                _buildSectionTitle('➕ Serviços Extras'),
                if (includeProducts)
                  _buildDetailRow(
                    'Produtos inclusos',
                    'R\$ ${productsCost.toStringAsFixed(2)}',
                    subtitle: 'extra_services.products_included',
                  ),
                if (includePets) ...[
                  _buildDetailRow(
                    'Limpeza com pets',
                    'R\$ ${petsCost.toStringAsFixed(2)}',
                    subtitle: 'extra_services.pets',
                  ),
                  _buildDetailRow(
                    'Tempo adicional (pets)',
                    '${_formatTime(petsExtraTime)}',
                    subtitle: 'pets_extra_time',
                  ),
                ],
              ],
              
              const SizedBox(height: 16),
              _buildSectionTitle('🔢 Limites Configurados'),
              Row(
                children: [
                  Expanded(
                    child: _buildLimitInfo(
                      'Cômodos',
                      '${config.getMinRooms()} - ${config.getMaxRooms()}',
                      'limits.min_rooms / max_rooms',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildLimitInfo(
                      'Banheiros',
                      '${config.getMinBathrooms()} - ${config.getMaxBathrooms()}',
                      'limits.min_bathrooms / max_bathrooms',
                    ),
                  ),
                ],
              ),
              
              const Divider(height: 24),
              
              // Totals
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'TOTAL',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo.shade800,
                          ),
                        ),
                        Text(
                          'R\$ ${totalPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo.shade800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tempo estimado',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.indigo.shade700,
                          ),
                        ),
                        Text(
                          _formatTime(totalTime),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.indigo.shade700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 12),
              Text(
                '* Todos os valores acima são obtidos diretamente do Firestore',
                style: TextStyle(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade900,
                ),
              ),
            ],
          ),
          if (subtitle != null)
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade500,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLimitInfo(String label, String range, String field) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            range,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          Text(
            field,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade500,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  String _getResidenceLabel(String type) {
    switch (type) {
      case 'studio':
        return 'Studio';
      case 'apartment':
        return 'Apartamento';
      case 'house':
        return 'Casa';
      default:
        return type;
    }
  }

  String _formatTime(int minutes) {
    if (minutes == 0) return '0min';
    
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    
    if (hours > 0 && mins > 0) {
      return '${hours}h ${mins}min';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${mins}min';
    }
  }
}