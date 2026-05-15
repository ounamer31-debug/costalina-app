import 'dart:async';

import 'package:costalina_app/screens/map_screen.dart';
import 'package:costalina_app/services/location_service.dart';
import 'package:costalina_app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';

class _FakeLocationService implements LocationService {
  final LocationResult result;
  final Stream<Position> stream;
  int getCurrentCalls = 0;
  int watchCalls = 0;

  _FakeLocationService(this.result, this.stream);

  @override
  Future<LocationResult> getCurrent() async {
    getCurrentCalls++;
    return result;
  }

  @override
  Stream<Position> watch() {
    watchCalls++;
    return stream;
  }
}

Position _pos(double lat, double lng) => Position(
      latitude: lat,
      longitude: lng,
      timestamp: DateTime.fromMillisecondsSinceEpoch(0),
      accuracy: 5,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0,
      altitudeAccuracy: 0,
      headingAccuracy: 0,
    );

Widget _wrap(Widget child) => MaterialApp(
      theme: buildCostalinaTheme(Brightness.light),
      home: child,
    );

void main() {
  tearDown(() {
    LocationService.instance = _FakeLocationService(
      const LocationResult(LocationStatus.denied),
      const Stream.empty(),
    );
  });

  testWidgets('locate FAB triggers getCurrent on map open', (tester) async {
    final fake = _FakeLocationService(
      LocationResult(LocationStatus.ok, _pos(35.78, 10.83)),
      Stream<Position>.fromIterable([]),
    );
    LocationService.instance = fake;

    await tester.pumpWidget(_wrap(const MapScreen()));
    // Let postFrameCallback fire + the async getCurrent resolve.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(fake.getCurrentCalls, greaterThanOrEqualTo(1),
        reason: 'MapScreen should auto-request a fix on open');
  });

  testWidgets('denied permission shows snackbar, no watch stream', (tester) async {
    final fake = _FakeLocationService(
      const LocationResult(LocationStatus.denied),
      const Stream.empty(),
    );
    LocationService.instance = fake;

    await tester.pumpWidget(_wrap(const MapScreen()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(fake.getCurrentCalls, 1);
    expect(fake.watchCalls, 0,
        reason: 'Live updates must not start when permission was denied');
    expect(find.text('Permission de localisation refusée.'), findsOneWidget);
  });

  testWidgets('successful fix starts the watch stream', (tester) async {
    final streamCtrl = StreamController<Position>.broadcast();
    final fake = _FakeLocationService(
      LocationResult(LocationStatus.ok, _pos(35.78, 10.83)),
      streamCtrl.stream,
    );
    LocationService.instance = fake;

    await tester.pumpWidget(_wrap(const MapScreen()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(fake.watchCalls, 1,
        reason: 'After OK fix, MapScreen must subscribe to live updates');
    await streamCtrl.close();
  });

  testWidgets('service disabled status shows correct message', (tester) async {
    LocationService.instance = _FakeLocationService(
      const LocationResult(LocationStatus.serviceDisabled),
      const Stream.empty(),
    );

    await tester.pumpWidget(_wrap(const MapScreen()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Activez la localisation dans les réglages.'),
        findsOneWidget);
  });
}
