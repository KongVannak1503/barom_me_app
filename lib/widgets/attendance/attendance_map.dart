import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../models/employee.dart';
import '../../themes/app_colors.dart';

class AttendanceMap extends StatefulWidget {
  final Branch? branch;
  final double? userLatitude;
  final double? userLongitude;

  const AttendanceMap({
    super.key,
    this.branch,
    this.userLatitude,
    this.userLongitude,
  });

  @override
  State<AttendanceMap> createState() => _AttendanceMapState();
}

class _AttendanceMapState extends State<AttendanceMap> {
  Position? _position;
  bool _loadingLocation = true;
  StreamSubscription<Position>? _positionStream;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  Future<void> _initLocation() async {
    try {
      final permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) setState(() => _loadingLocation = false);
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      if (mounted) {
        setState(() {
          _position = pos;
          _loadingLocation = false;
        });
      }
      _positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      ).listen((pos) {
        if (mounted) setState(() => _position = pos);
      });
    } catch (_) {
      if (mounted) setState(() => _loadingLocation = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingLocation) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final userLat = widget.userLatitude ?? _position?.latitude;
    final userLng = widget.userLongitude ?? _position?.longitude;

    final center = userLat != null && userLng != null
        ? LatLng(userLat, userLng)
        : widget.branch?.latitude != null && widget.branch?.longitude != null
            ? LatLng(widget.branch!.latitude!, widget.branch!.longitude!)
            : const LatLng(11.5564, 104.9282);

    return SizedBox(
      height: 200,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: FlutterMap(
          options: MapOptions(
            initialCenter: center,
            initialZoom: 16,
            interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.barom.barom_me_app',
            ),
            if (widget.branch?.latitude != null && widget.branch?.longitude != null)
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: LatLng(widget.branch!.latitude!, widget.branch!.longitude!),
                    radius: widget.branch?.radiusMeters?.toDouble() ?? 100,
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderColor: AppColors.primary,
                    borderStrokeWidth: 2,
                  ),
                ],
              ),
            MarkerLayer(
              markers: [
                if (widget.branch?.latitude != null && widget.branch?.longitude != null)
                  Marker(
                    point: LatLng(widget.branch!.latitude!, widget.branch!.longitude!),
                    width: 30,
                    height: 30,
                    child: const Icon(Icons.business, color: AppColors.primary, size: 28),
                  ),
                if (userLat != null && userLng != null)
                  Marker(
                    point: LatLng(userLat, userLng),
                    width: 30,
                    height: 30,
                    child: const Icon(Icons.my_location, color: AppColors.danger, size: 28),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
