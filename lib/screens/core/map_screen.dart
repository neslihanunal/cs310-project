import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../models/event_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/dummy_data.dart';
import '../../utils/routes.dart';
import '../../utils/text_styles.dart';
import '../../widgets/bottom_nav.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  String? _highlightedLocation;
  int? _highlightedEventId;

  final Map<String, _Marker> _buildingMarkers = const {
    '1 · Administration Building': _Marker(x: 0.276, y: 0.549),
    '2 · School of Languages': _Marker(x: 0.323, y: 0.546),
    '3 · Sabancı Business School': _Marker(x: 0.374, y: 0.525),
    '4 · Faculty of Engineering and Natural Sciences':
        _Marker(x: 0.397, y: 0.622),
    '5 · Faculty of Arts and Social Sciences': _Marker(x: 0.345, y: 0.645),
    '6 · Art Studios': _Marker(x: 0.367, y: 0.728),
    '7 · Information Center': _Marker(x: 0.309, y: 0.659),
    '8 · SUNUM': _Marker(x: 0.423, y: 0.788),
    '9 · Main Gate and Security': _Marker(x: 0.164, y: 0.745),
    '10 · University Center - Cafeteria': _Marker(x: 0.427, y: 0.579),
    '11 · Cinema Hall': _Marker(x: 0.392, y: 0.528),
    '12 · Central Plant': _Marker(x: 0.469, y: 0.869),
    '13 · Performing Arts Center (SGM)': _Marker(x: 0.212, y: 0.482),
    '14 · Amphitheater': _Marker(x: 0.392, y: 0.457),
    '15 · President\'s House': _Marker(x: 0.537, y: 0.513),
    '16 · Health Center and Social Services': _Marker(x: 0.507, y: 0.550),
    '17 · Nursery School': _Marker(x: 0.482, y: 0.714),
    '18 · Student Clubs Buildings': _Marker(x: 0.454, y: 0.814),
    '19 · Entrepreneurship and Incubation Center': _Marker(x: 0.228, y: 0.313),
    '20 · Treatment Plant': _Marker(x: 0.179, y: 0.288),
    '21 · Sports Center': _Marker(x: 0.212, y: 0.419),
    '22 · Tennis Court': _Marker(x: 0.198, y: 0.240),
    '23 · Football Field': _Marker(x: 0.364, y: 0.360),
    '24 · Faculty Housing': _Marker(x: 0.414, y: 0.705),
    '25 · Student Dormitories': _Marker(x: 0.462, y: 0.497),
  };

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..addListener(() {
        if (mounted) setState(() {});
      });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String _normalizedLocation(String value) {
    return kLegacyLocationAliases[value] ?? value;
  }

  String _locationNumber(String value) {
    final normalized = _normalizedLocation(value);
    final parts = normalized.split('·');
    return parts.isNotEmpty ? parts.first.trim() : normalized;
  }

  void _highlightLocation(String location) {
    final normalized = _normalizedLocation(location);
    if (_buildingMarkers[normalized] == null) return;
    setState(() => _highlightedLocation = normalized);
    _pulseController.forward(from: 0);
  }

  void _highlightEvent(Event event) {
    setState(() => _highlightedEventId = event.id);
    _highlightLocation(event.loc);
  }

  double _scaleFor(String location) {
    final normalized = _normalizedLocation(location);
    if (_highlightedLocation != normalized) return 1;
    final t = _pulseController.value;
    if (t <= 0.5) {
      return 1 + (0.3 * (t / 0.5));
    }
    return 1.3 - (0.3 * ((t - 0.5) / 0.5));
  }

  Color _markerColorFor(String location) {
    if (_highlightedLocation == _normalizedLocation(location)) {
      return AppColors.accent;
    }
    return const Color(0xFF6F87B2);
  }

  DateTime? _eventDate(String label) {
    final parts = label.split(' ');
    if (parts.length != 2) return null;
    const months = {
      'Jan': 1,
      'Feb': 2,
      'Mar': 3,
      'Apr': 4,
      'May': 5,
      'Jun': 6,
      'Jul': 7,
      'Aug': 8,
      'Sep': 9,
      'Oct': 10,
      'Nov': 11,
      'Dec': 12,
    };
    final month = months[parts[0]];
    final day = int.tryParse(parts[1]);
    if (month == null || day == null) return null;
    return DateTime(DateTime.now().year, month, day);
  }

  bool _isWithinNextSevenDays(Event event, DateTime referenceDate) {
    final eventDate = _eventDate(event.date);
    if (eventDate == null) return false;
    final reference =
        DateTime(referenceDate.year, referenceDate.month, referenceDate.day);
    final diff = eventDate.difference(reference).inDays;
    return diff >= 0 && diff <= 7;
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final role = state.role;
    final referenceDate = state.referenceDate;
    final upcomingEvents = state
        .eventsForRole(state.role)
        .where((event) => _isWithinNextSevenDays(event, referenceDate))
        .toList()
      ..sort((a, b) => (_eventDate(a.date) ?? DateTime(2100))
          .compareTo(_eventDate(b.date) ?? DateTime(2100)));

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 2, 20, 14),
              child: Text('Campus Map', style: AppTextStyles.screenTitle()),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceAlt,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        const mapAspectRatio = 2048 / 1472;
                        final mapWidth = constraints.maxWidth;
                        final mapHeight = mapWidth / mapAspectRatio;

                        return InteractiveViewer(
                          minScale: 1,
                          maxScale: 5,
                          boundaryMargin: const EdgeInsets.all(48),
                          constrained: false,
                          child: SizedBox(
                            width: mapWidth,
                            height: mapHeight,
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: Image.asset(
                                    'assets/images/campus_map.jpg',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                ..._buildingMarkers.entries.map((entry) {
                                  return _MapLocationMarker(
                                    marker: entry.value,
                                    mapWidth: mapWidth,
                                    mapHeight: mapHeight,
                                    label: _locationNumber(entry.key),
                                    scale: _scaleFor(entry.key),
                                    accent: _markerColorFor(entry.key),
                                  );
                                }),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pinch to zoom • Drag to pan',
                      style: AppTextStyles.body(
                        11,
                        color: Colors.white,
                        weight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'All campus locations are shown on the map. Tap an upcoming event to pulse its marker',
                      style: AppTextStyles.caption(
                        size: 9,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Text('UPCOMING EVENTS', style: AppTextStyles.label()),
            ),
            const SizedBox(height: 8),
            Expanded(
              flex: 2,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: upcomingEvents.length,
                itemBuilder: (_, i) {
                  final event = upcomingEvents[i];
                  final c =
                      AppColors.postit[event.id % AppColors.postit.length];
                  return GestureDetector(
                    onTap: () => _highlightEvent(event),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _highlightedEventId == event.id
                              ? c.pin.withValues(alpha: 0.75)
                              : AppColors.border,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 3,
                            height: 28,
                            decoration: BoxDecoration(
                              color: c.pin,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event.title,
                                  style: AppTextStyles.body(
                                    12,
                                    weight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  _normalizedLocation(event.loc),
                                  style: AppTextStyles.caption(size: 10),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                event.date,
                                style: AppTextStyles.body(
                                  10,
                                  color: c.pin,
                                  weight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Icon(
                                Icons.place_rounded,
                                size: 16,
                                color: c.pin,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            BottomNav(
              active: AppRoutes.map,
              role: role,
              onNav: (route) => Navigator.pushReplacementNamed(context, route),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapLocationMarker extends StatelessWidget {
  final _Marker marker;
  final double mapWidth;
  final double mapHeight;
  final double scale;
  final String label;
  final Color accent;

  const _MapLocationMarker({
    required this.marker,
    required this.mapWidth,
    required this.mapHeight,
    required this.scale,
    required this.label,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: marker.x * mapWidth,
      top: marker.y * mapHeight,
      child: FractionalTranslation(
        translation: const Offset(-0.5, -0.5),
        child: Transform.scale(
          scale: scale,
          child: Container(
            constraints: const BoxConstraints(minWidth: 16),
            height: 16,
            padding: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.35),
                  blurRadius: 6,
                  spreadRadius: 0.2,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 6.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Marker {
  final double x;
  final double y;

  const _Marker({required this.x, required this.y});
}
