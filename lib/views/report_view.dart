import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../services/api_service.dart';

class ReportView extends StatefulWidget {
  const ReportView({super.key});

  @override
  State<ReportView> createState() => _ReportViewState();
}

class _ReportViewState extends State<ReportView> {
  static const String _mapTilerKey = 'vho6orZjGT63tDnxKRLq';

  /// Variables para mantener el estado de la selección de ubicación
  LatLng? _selectedLocation;
  String _selectedPlaceName = '';

  Future<void> _submitReport({
    required String location,
    required double lat,
    required double lng,
  }) async {
    await ApiService.createReport(
      title: 'Bache reportado',
      description: 'Reporte generado desde aplicación móvil',
      locationText: location,
      lat: lat,
      lng: lng,
      category: 'bache',
      userName: 'Ciudadano',
    );
  }

  /// Obtiene el nombre del lugar usando reverse geocoding de MapTiler
  Future<String> _getPlaceName(LatLng location) async {
    try {
      final url =
          'https://api.maptiler.com/geocoding/${location.longitude},${location.latitude}.json?key=$_mapTilerKey';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final features = json['features'] as List?;

        if (features != null && features.isNotEmpty) {
          final placeName = features[0]['place_name'] as String? ?? 'Ubicación desconocida';
          return placeName;
        }
      }
      return 'Ubicación no identificada';
    } catch (e) {
      return 'Error al obtener ubicación';
    }
  }

  /// Obtiene la ubicación GPS actual del dispositivo
  Future<LatLng?> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Por favor, activa los servicios de ubicación')),
          );
        }
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Permiso de ubicación denegado')),
            );
          }
          return null;
        }
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al obtener ubicación')),
        );
      }
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCFAF2),
        elevation: 0,
        leading: Icon(Icons.menu, color: Colors.grey[800]),
        title: const Text(
          'Oaxaca Reporta',
          style: TextStyle(color: Color(0xFF670024), fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.grey[300],
              child: const Icon(Icons.person, color: Colors.grey),
            ),
          ),
        ],
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color.fromRGBO(103, 0, 36, 0.3)),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const Text(
                  'Atención Ciudadana',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF670024),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'El municipio necesita saber qué baches son más urgentes',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[900],
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                'Envía la ubicación exacta para que el reporte no se pierda y pueda atenderse por prioridad vial.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Sugerencia: agrega una referencia cercana para mejorar la georreferenciación.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 40),
              GestureDetector(
                onTap: () => _showCurrentLocationSheet(context),
                child: Container(
                  width: 236,
                  height: 236,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF8A1538),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromRGBO(103, 0, 36, 0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.send,
                        size: 58,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Enviar ahora',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () => _showOtherLocationMapSheet(context),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 16,
                      color: Color(0xFF670024),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Reportar otra ubicación',
                      style: TextStyle(
                        color: Color(0xFF670024),
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  void _showCurrentLocationSheet(BuildContext context) {
    LatLng currentLocation = const LatLng(17.0732, -96.7266);
    String currentPlaceName = '';
    bool isLoading = true;
    bool hasRequestedLocation = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, localSetState) {
          Future<void> loadCurrentLocation() async {
            if (hasRequestedLocation) return;
            hasRequestedLocation = true;

            final location = await _getCurrentLocation();
            if (!mounted) return;

            if (location != null) {
              final placeName = await _getPlaceName(location);
              if (!mounted) return;
              localSetState(() {
                currentLocation = location;
                currentPlaceName = placeName;
                isLoading = false;
              });
            } else {
              localSetState(() {
                currentPlaceName = '';
                isLoading = false;
              });
            }
          }

          WidgetsBinding.instance.addPostFrameCallback((_) {
            loadCurrentLocation();
          });

          return Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Color(0xFF670024)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Ubicación actual',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF670024),
                            ),
                          ),
                          if (isLoading)
                            const Text(
                              'Obteniendo ubicación...',
                              style: TextStyle(fontSize: 12, color: Colors.orange),
                            )
                          else if (currentPlaceName.isNotEmpty)
                            Text(
                              currentPlaceName,
                              style: const TextStyle(fontSize: 12),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            )
                          else
                            const Text(
                              'No se obtuvo una ubicación GPS válida. Activa ubicación o intenta nuevamente.',
                              style: TextStyle(fontSize: 12, color: Colors.red),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(sheetContext),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  height: MediaQuery.of(sheetContext).size.height * 0.45,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: currentLocation,
                      initialZoom: 18,
                      maxZoom: 20,
                      minZoom: 3,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://api.maptiler.com/maps/streets/{z}/{x}/{y}.png?key=$_mapTilerKey',
                        userAgentPackageName: 'com.example.baches_app',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: currentLocation,
                            width: 48,
                            height: 48,
                            child: const Icon(
                              Icons.location_pin,
                              size: 40,
                              color: Color(0xFF670024),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Verifica que la dirección corresponda al punto de reporte antes de confirmar.',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (isLoading || currentPlaceName.isEmpty)
                        ? null
                        : () {
                            Navigator.pop(sheetContext);
                            _showConfirmationSheet(
                              context,
                              location: currentPlaceName.isEmpty
                                  ? 'Ubicación actual'
                                  : currentPlaceName,
                              lat: currentLocation.latitude,
                              lng: currentLocation.longitude,
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF670024),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      disabledBackgroundColor: Colors.grey[400],
                    ),
                    child: const Text(
                      'Confirmar y continuar',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showOtherLocationMapSheet(BuildContext context) {
    // Resetear variables de selección
    _selectedLocation = null;
    _selectedPlaceName = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, localSetState) {
          final MapController localController = MapController();
          double localZoom = 16.0;

          return Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.map, color: Color(0xFF670024)),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selecciona otra ubicación',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF670024),
                            ),
                          ),
                          Text(
                            'Coloca el puntero en el punto exacto del reporte.',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(sheetContext),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  height: 320,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: FlutterMap(
                    mapController: localController,
                    options: MapOptions(
                      initialCenter: const LatLng(17.0732, -96.7266),
                      initialZoom: localZoom,
                      maxZoom: 20,
                      minZoom: 3,
                      onTap: (tapPos, latLng) async {
                        // Actualizar ubicación seleccionada inmediatamente
                        _selectedLocation = latLng;
                        _selectedPlaceName = 'Cargando ubicación...'; // Mostrar estado de carga
                        setState(() {});
                        localSetState(() {});

                        // Obtener nombre del lugar en background
                        final placeName = await _getPlaceName(latLng);
                        if (mounted) {
                          setState(() {
                            _selectedPlaceName = placeName;
                          });
                          localSetState(() {});
                        }
                      },
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.all,
                        scrollWheelVelocity: 0.01,
                      ),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://api.maptiler.com/maps/streets/{z}/{x}/{y}.png?key=$_mapTilerKey',
                        userAgentPackageName: 'com.example.baches_app',
                      ),
                      MarkerLayer(
                        markers: _selectedLocation == null
                            ? <Marker>[]
                            : [
                                Marker(
                                  point: _selectedLocation!,
                                  width: 48,
                                  height: 48,
                                  child: const Icon(
                                    Icons.location_pin,
                                    size: 40,
                                    color: Color(0xFF670024),
                                  ),
                                )
                              ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Mostrar nombre del lugar si está disponible o si está cargando
                if (_selectedLocation != null && _selectedPlaceName.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _selectedPlaceName == 'Cargando ubicación...'
                          ? Colors.amber[50]
                          : Colors.blue[50],
                      border: Border.all(
                        color: _selectedPlaceName == 'Cargando ubicación...'
                            ? Colors.amber[300]!
                            : Colors.blue[300]!,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedPlaceName == 'Cargando ubicación...'
                              ? 'Detectando ubicación...'
                              : 'Ubicación detectada:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _selectedPlaceName == 'Cargando ubicación...'
                                ? Colors.amber[700]
                                : Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _selectedPlaceName,
                          style: const TextStyle(fontSize: 13),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                if (_selectedLocation == null)
                  Text(
                    'Toca en el mapa para seleccionar la ubicación exacta del bache.',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _selectedLocation == null
                        ? null
                        : () {
                            Navigator.pop(sheetContext);
                            _showConfirmationSheet(
                              context,
                              location: _selectedPlaceName.isEmpty
                                  ? 'Ubicación seleccionada'
                                  : _selectedPlaceName,
                              lat: _selectedLocation!.latitude,
                              lng: _selectedLocation!.longitude,
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF670024),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      disabledBackgroundColor: Colors.grey[400],
                    ),
                    child: const Text(
                      'Confirmar ubicación',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showConfirmationSheet(
    BuildContext context, {
    required String location,
    required double lat,
    required double lng,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on, color: Color(0xFF670024)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ubicación seleccionada',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF670024),
                        ),
                      ),
                      Text(
                        location,
                        style: const TextStyle(fontSize: 12),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Lat: ${lat.toStringAsFixed(6)}, Lng: ${lng.toStringAsFixed(6)}',
                        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(sheetContext),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(Icons.check_circle_outline, size: 52, color: Color(0xFF670024)),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final navigator = Navigator.of(sheetContext);
                  final messenger = ScaffoldMessenger.of(context);
                  try {
                    await _submitReport(location: location, lat: lat, lng: lng);
                    if (!mounted) return;
                    navigator.pop();
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Reporte enviado correctamente')),
                    );
                  } catch (_) {
                    if (!mounted) return;
                    messenger.showSnackBar(
                      const SnackBar(content: Text('No se pudo enviar el reporte al servidor')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF670024),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Confirmar y continuar',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
