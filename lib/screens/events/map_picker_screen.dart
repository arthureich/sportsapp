import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  // Posição inicial do mapa (Ex: Cascavel, PR)
  static const LatLng _initialPosition = LatLng(-24.9555, -53.4552);
  
  LatLng? _pickedLocation;
  
  void _selectLocation(LatLng position) {
    setState(() {
      _pickedLocation = position;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecione o Local do Evento'),
        actions: [
          // Botão para confirmar a seleção
          if (_pickedLocation != null)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () {
                // Retorna a localização selecionada para a tela anterior
                Navigator.of(context).pop(
                  GeoPoint(_pickedLocation!.latitude, _pickedLocation!.longitude)
                );
              },
            ),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: _initialPosition,
          zoom: 13,
        ),
        onTap: _selectLocation, // Chama a função quando o utilizador toca no mapa
        markers: (_pickedLocation == null) 
          ? {} // Nenhum marcador se nenhum local foi escolhido
          : { // Mostra um marcador no local escolhido
              Marker(
                markerId: const MarkerId('m1'),
                position: _pickedLocation!,
              ),
            },
      ),
    );
  }
}
