
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/api_service.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final LatLng _center = const LatLng(17.0732, -96.7266);
  final MapController _mapController = MapController();
  double _zoom = 16.0;

  List<_IncidentZone> _zones = const [
    _IncidentZone(
      label: 'Alta incidencia',
      color: Color(0xFFC62828),
      point: LatLng(17.0708, -96.7228),
      reports: 14,
      area: 'Av. Independencia & Morelos',
      radius: 120,
    ),
    _IncidentZone(
      label: 'Incidencia media',
      color: Color(0xFFF9A825),
      point: LatLng(17.0743, -96.7301),
      reports: 7,
      area: 'Centro Histórico',
      radius: 90,
    ),
    _IncidentZone(
      label: 'Baja incidencia',
      color: Color(0xFF2E7D32),
      point: LatLng(17.0791, -96.7246),
      reports: 2,
      area: 'Colonia Reforma',
      radius: 50,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadRiskZones();
  }

  Future<void> _loadRiskZones() async {
    try {
      final zones = await ApiService.getRiskZones();
      if (!mounted) return;

      setState(() {
        _zones = zones
            .map(
              (zone) => _IncidentZone(
                label: (zone['label'] as String?) ?? 'Zona',
                color: _colorFromHex((zone['color'] as String?) ?? '#2E7D32'),
                point: LatLng(
                  ((zone['point'] as Map<String, dynamic>)['lat'] as num).toDouble(),
                  ((zone['point'] as Map<String, dynamic>)['lng'] as num).toDouble(),
                ),
                reports: (zone['reports'] as num?)?.toInt() ?? 0,
                area: 'Zona dinámica',
                radius: (zone['radius'] as num?)?.toInt() ?? math.min(150, (((zone['reports'] as num?)?.toInt() ?? 0) * 12 + 30)),
              ),
            )
            .toList();
      });
    } catch (_) {
      // Conserva zonas por defecto si backend no está disponible.
    }
  }

  Color _colorFromHex(String hex) {
    final value = hex.replaceAll('#', '');
    return Color(int.parse('FF$value', radix: 16));
  }

  void _zoomIn() {
    setState(() {
      _zoom += 1;
      _mapController.move(_center, _zoom);
    });
  }

  void _zoomOut() {
    setState(() {
      _zoom = _zoom - 1 < 3 ? 3 : _zoom - 1;
      _mapController.move(_center, _zoom);
    });
  }

  void _recenter() {
    setState(() {
      _mapController.move(_center, _zoom);
    });
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
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: _zoom,
              maxZoom: 20,
              minZoom: 3,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
                scrollWheelVelocity: 0.01,
              ),
              onPositionChanged: (mapPosition, _) {
                final z = mapPosition.zoom;
                if (z != _zoom) {
                  setState(() {
                    _zoom = z;
                  });
                }
              },
            ),
            children: [
              TileLayer(
                // MapTiler streets tiles using provided API key
                urlTemplate: 'https://api.maptiler.com/maps/streets/{z}/{x}/{y}.png?key=vho6orZjGT63tDnxKRLq',
                userAgentPackageName: 'com.example.baches_app',
              ),
              CircleLayer(
                circles: _zones
                    .map(
                      (zone) {
                        final pixelRadius = _metersToPixels(
                          zone.radius.toDouble(),
                          zone.point.latitude,
                          _zoom,
                        );
                        final capped = pixelRadius.clamp(8.0, 400.0).toDouble();
                        return CircleMarker(
                          point: zone.point,
                          radius: capped,
                          color: zone.color.withAlpha(48),
                          borderColor: zone.color,
                          borderStrokeWidth: 2,
                        );
                      },
                    )
                    .toList(),
              ),
              MarkerLayer(
                markers: _zones
                    .map(
                      (zone) => Marker(
                        point: zone.point,
                        width: 60,
                        height: 60,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(999),
                                boxShadow: [
                                  BoxShadow(color: const Color.fromRGBO(0, 0, 0, 0.15), blurRadius: 8),
                                ],
                              ),
                              child: Text(
                                '${zone.reports}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: zone.color,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Icon(Icons.location_pin, color: zone.color, size: 36),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: const Color.fromRGBO(0, 0, 0, 0.1), blurRadius: 8)
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Referencia de incidencia',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildLegendItem(const Color(0xFFC62828), 'Rojo · Alta incidencia'),
                  _buildLegendItem(const Color(0xFFF9A825), 'Amarillo · Incidencia media'),
                  _buildLegendItem(const Color(0xFF2E7D32), 'Verde · Baja incidencia'),
                ],
              ),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 100,
            child: Column(
              children: [
                FloatingActionButton(
                  mini: true,
                  onPressed: _zoomIn,
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.add, color: Color(0xFF670024)),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  mini: true,
                  onPressed: _zoomOut,
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.remove, color: Color(0xFF670024)),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  mini: true,
                  onPressed: _recenter,
                  backgroundColor: const Color(0xFF670024),
                  child: const Icon(Icons.my_location, color: Colors.white),
                ),
              ],
            ),
          ),
          // Removed bottom info window so map shows full screen per user request.
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

  double _metersToPixels(double meters, double lat, double zoom) {
    // Web Mercator approximate meters per pixel at latitude
    final metersPerPixel = 156543.03392 * math.cos(lat * math.pi / 180) / math.pow(2, zoom);
    if (metersPerPixel <= 0) return meters; // fallback
    return meters / metersPerPixel;
  }

class _IncidentZone {
  const _IncidentZone({
    required this.label,
    required this.color,
    required this.point,
    required this.reports,
    required this.area,
    required this.radius,
  });

  final String label;
  final Color color;
  final LatLng point;
  final int reports;
  final String area;
  final int radius;
}


