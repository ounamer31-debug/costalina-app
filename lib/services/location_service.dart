import 'dart:async';

import 'package:geolocator/geolocator.dart';

enum LocationStatus { ok, denied, deniedForever, serviceDisabled, error }

class LocationResult {
  final LocationStatus status;
  final Position? position;
  const LocationResult(this.status, [this.position]);
}

// Interface so tests can swap in a fake. Production uses `_RealLocationService`.
abstract class LocationService {
  Future<LocationResult> getCurrent();
  Stream<Position> watch();

  static LocationService instance = _RealLocationService();
}

class _RealLocationService implements LocationService {
  @override
  Future<LocationResult> getCurrent() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return const LocationResult(LocationStatus.serviceDisabled);
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return const LocationResult(LocationStatus.denied);
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return const LocationResult(LocationStatus.deniedForever);
    }

    try {
      final last = await Geolocator.getLastKnownPosition();
      if (last != null) {
        // Kick off a fresh fix in the background, but return last-known fast.
        unawaited(Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 20),
          ),
        ).catchError((_) => last));
        return LocationResult(LocationStatus.ok, last);
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 20),
        ),
      );
      return LocationResult(LocationStatus.ok, pos);
    } catch (_) {
      return const LocationResult(LocationStatus.error);
    }
  }

  @override
  Stream<Position> watch() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );
  }
}
