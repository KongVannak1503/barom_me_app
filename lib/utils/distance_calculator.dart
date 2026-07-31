import 'dart:math';

class DistanceCalculator {
  static double haversine(double lat1, double lon1, double lat2, double lon2) {
    const earthRadius = 6371000;
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final sinDLat = sin(dLat / 2);
    final sinDLon = sin(dLon / 2);
    final a = sinDLat * sinDLat +
        cos(_deg2rad(lat1)) * cos(_deg2rad(lat2)) * sinDLon * sinDLon;
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  static double _deg2rad(double deg) => deg * (pi / 180);
}
