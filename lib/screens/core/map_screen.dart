import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/event_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
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
  String? _highlightedEventId;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..addListener(() {
        if (mounted) {
          setState(() {});
        }
      });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String _normalizedLocation(String value) {
    return normalizeCampusLocation(value);
  }

  void _highlightLocation(String location) {
    final normalized = _normalizedLocation(location);
    if (findCampusLocation(normalized) == null) {
      return;
    }
    setState(() => _highlightedLocation = normalized);
    _pulseController.forward(from: 0);
  }

  void _highlightEvent(Event event) {
    setState(() => _highlightedEventId = event.id);
    _highlightLocation(event.loc);
  }

  double _scaleFor(String location) {
    final normalized = _normalizedLocation(location);
    if (_highlightedLocation != normalized) {
      return 1;
    }
    final progress = _pulseController.value;
    if (progress <= 0.5) {
      return 1 + (0.3 * (progress / 0.5));
    }
    return 1.3 - (0.3 * ((progress - 0.5) / 0.5));
  }

  Color _markerColorFor(String location) {
    if (_highlightedLocation == _normalizedLocation(location)) {
      return AppColors.accent;
    }
    return const Color(0xFF6F87B2);
  }

  bool _isWithinNextSevenDays(Event event, DateTime referenceDate) {
    final eventDate = event.scheduledDate;
    if (eventDate == null) {
      return false;
    }
    final reference = DateTime(
      referenceDate.year,
      referenceDate.month,
      referenceDate.day,
    );
    final difference = eventDate.difference(reference).inDays;
    return difference >= 0 && difference <= 7;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final eventProvider = context.watch<EventProvider>();

    final role = authProvider.role;
    final referenceDate = eventProvider.referenceDate;
    final upcomingEvents = eventProvider.activeEvents
        .where((event) => _isWithinNextSevenDays(event, referenceDate))
        .toList()
      ..sort((a, b) {
        final firstDate = a.scheduledDate ?? DateTime(2100);
        final secondDate = b.scheduledDate ?? DateTime(2100);
        return firstDate.compareTo(secondDate);
      });

    final selectedEvent = eventProvider.selectedEvent;
    if (selectedEvent != null && _highlightedEventId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _highlightEvent(selectedEvent);
        }
      });
    }

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
                                    fit: BoxFit.fill,
                                  ),
                                ),
                                ...kCampusMapLocations.map((location) {
                                  return _MapLocationMarker(
                                    marker: _Marker(x: location.x, y: location.y),
                                    mapWidth: mapWidth,
                                    mapHeight: mapHeight,
                                    label: location.id.toString(),
                                    scale: _scaleFor(location.label),
                                    accent: _markerColorFor(location.label),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
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
                itemBuilder: (_, index) {
                  final event = upcomingEvents[index];
                  final colors = AppColors.postit[
                      event.colorSeed % AppColors.postit.length];
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
                              ? colors.pin.withOpacity(0.75)
                              : AppColors.border,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 3,
                            height: 28,
                            decoration: BoxDecoration(
                              color: colors.pin,
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
                                  findCampusLocation(event.loc)?.label ??
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
                                  color: colors.pin,
                                  weight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Icon(
                                Icons.place_rounded,
                                size: 16,
                                color: colors.pin,
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
  const _MapLocationMarker({
    required this.marker,
    required this.mapWidth,
    required this.mapHeight,
    required this.scale,
    required this.label,
    required this.accent,
  });

  final _Marker marker;
  final double mapWidth;
  final double mapHeight;
  final double scale;
  final String label;
  final Color accent;

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
                  color: accent.withOpacity(0.35),
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
  const _Marker({required this.x, required this.y});

  final double x;
  final double y;
}
