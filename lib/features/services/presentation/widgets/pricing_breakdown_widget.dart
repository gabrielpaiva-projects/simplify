import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cleaning_config_provider.dart';

class PricingBreakdownWidget extends StatelessWidget {
  final String residenceType;
  final int rooms;
  final int bathrooms;
  final bool includeProducts;
  final bool includePets;

  const PricingBreakdownWidget({
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
        if (configProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final basePrice = configProvider.getBasePrice(residenceType);
        final baseTime = configProvider.getBaseTime(residenceType);
        
        // Calculate extra rooms cost
        final baseRooms = residenceType == 'studio' ? 1 : 2;
        final extraRooms = rooms > baseRooms ? rooms - baseRooms : 0;
        final extraRoomsCost = extraRooms * (configProvider.config?.getRoomPriceMultiplier() ?? 30);
        
        // Calculate extra bathrooms cost
        final extraBathrooms = bathrooms > 1 ? bathrooms - 1 : 0;
        final extraBathroomsCost = extraBathrooms * (configProvider.config?.getBathroomPriceMultiplier() ?? 25);
        
        // Calculate extras
        final productsCost = includeProducts ? configProvider.getProductsIncludedPrice() : 0;
        final petsCost = includePets ? configProvider.getPetsExtraPrice() : 0;
        
        // Total
        final totalPrice = basePrice + extraRoomsCost + extraBathroomsCost + productsCost + petsCost;
        
        // Calculate time
        final totalTime = configProvider.calculateEstimatedTime(
          residenceType: residenceType,
          rooms: rooms,
          bathrooms: bathrooms,
          includePets: includePets,
        );
        
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Detalhamento do Preço',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 12),
              
              // Base price
              _buildPriceRow(
                'Preço base (${_getResidenceLabel(residenceType)})',
                basePrice,
              ),
              
              // Extra rooms
              if (extraRooms > 0)
                _buildPriceRow(
                  '+$extraRooms cômodo${extraRooms > 1 ? 's' : ''} extra${extraRooms > 1 ? 's' : ''}',
                  extraRoomsCost,
                ),
              
              // Extra bathrooms
              if (extraBathrooms > 0)
                _buildPriceRow(
                  '+$extraBathrooms banheiro${extraBathrooms > 1 ? 's' : ''} extra${extraBathrooms > 1 ? 's' : ''}',
                  extraBathroomsCost,
                ),
              
              // Products
              if (includeProducts)
                _buildPriceRow(
                  'Produtos inclusos',
                  productsCost,
                ),
              
              // Pets
              if (includePets)
                _buildPriceRow(
                  'Limpeza com pets',
                  petsCost,
                ),
              
              const Divider(height: 20),
              
              // Total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade900,
                    ),
                  ),
                  Text(
                    'R\$ ${totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Estimated time
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tempo estimado',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    _formatTime(totalTime),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPriceRow(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
          Text(
            'R\$ ${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade800,
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