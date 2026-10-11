import 'package:flutter/material.dart';
import '../providers/trip_state_provider.dart';

// Mock places for testing without Places API
final _mockPlaces = [
  PlaceResult(
    name: 'Luanda Shopping',
    address: 'Rua Companhia de Jesus, Luanda',
    latitude: -8.814562,
    longitude: 13.239987,
  ),
  PlaceResult(
    name: 'Talatona Convention Hotel',
    address: 'Talatona, Luanda Sul',
    latitude: -8.913247,
    longitude: 13.186745,
  ),
  PlaceResult(
    name: 'Aeroporto Internacional de Luanda',
    address: 'Aeroporto 4 de Fevereiro',
    latitude: -8.858372,
    longitude: 13.231236,
  ),
  PlaceResult(
    name: 'Miramar',
    address: 'Miramar, Luanda',
    latitude: -8.808912,
    longitude: 13.232456,
  ),
  PlaceResult(
    name: 'Bairro Azul',
    address: 'Bairro Azul, Luanda',
    latitude: -8.852341,
    longitude: 13.261123,
  ),
  PlaceResult(
    name: 'Sambizanga',
    address: 'Sambizanga, Luanda',
    latitude: -8.799012,
    longitude: 13.252398,
  ),
  PlaceResult(
    name: 'Viana',
    address: 'Viana, Luanda',
    latitude: -8.903567,
    longitude: 13.373289,
  ),
];

class DestinationSearchModal extends StatefulWidget {
  const DestinationSearchModal({super.key});

  @override
  State<DestinationSearchModal> createState() => _DestinationSearchModalState();
}

class _DestinationSearchModalState extends State<DestinationSearchModal> {
  final _searchController = TextEditingController();
  List<PlaceResult> _results = _mockPlaces;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _results = _mockPlaces;
      } else {
        _results = _mockPlaces
            .where((p) =>
                p.name.toLowerCase().contains(query.toLowerCase()) ||
                p.address.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 24),
                const Text('Escolher destino', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF101820))),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(Icons.close, size: 24, color: Color(0xFF344054)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // "De" Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  const Icon(Icons.my_location, color: Color(0xFF12A05C)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text('Partida', style: TextStyle(color: Color(0xFF667085), fontSize: 12)),
                        Text('Sua localização actual', style: TextStyle(color: Color(0xFF101820), fontSize: 14, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 12),

          // "Para" Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF101820), width: 1.5),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  const Icon(Icons.search, color: Color(0xFF344054)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      onChanged: _onSearch,
                      style: const TextStyle(fontSize: 15, color: Color(0xFF101820)),
                      decoration: const InputDecoration(
                        hintText: 'Para onde vai?',
                        hintStyle: TextStyle(color: Color(0xFF98A2B3)),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.place_outlined, color: Color(0xFF12A05C)),
                  const SizedBox(width: 16),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
          // Results
          Expanded(
            child: _results.isEmpty
                ? const Center(
                    child: Text('Nenhum destino encontrado', style: TextStyle(color: Color(0xFF667085))),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _results.length,
                    itemBuilder: (_, i) {
                      final place = _results[i];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const CircleAvatar(backgroundColor: Color(0xFFF2F4F7), child: Icon(Icons.location_on_outlined, color: Color(0xFF344054), size: 20)),
                        title: Text(place.name, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF101820))),
                        subtitle: Text(place.address, style: const TextStyle(fontSize: 12, color: Color(0xFF667085))),
                        onTap: () => Navigator.of(context).pop(place),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
