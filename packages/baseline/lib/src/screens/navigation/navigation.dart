import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'package:tourforge_baseline/src/help_viewed.dart';
import 'package:provider/provider.dart';

import '../../controllers/narration_playback.dart';
import '../../controllers/navigation.dart';
import '../../data.dart';
import '../../location.dart';
import '../../models/current_location.dart';
import '../../models/current_waypoint.dart';
import '../../models/fake_gps.dart';
import '../../models/map_controlledness.dart';
import '../../models/satellite_enabled.dart';
import '../../screens/navigation/drawer.dart';
import '../../screens/navigation/help.dart';
import '../../screens/navigation/map.dart';
import '../../screens/navigation/panel.dart';
import '../../screens/poi_details.dart';
import '../../screens/waypoint_details.dart';
import 'attribution.dart';

class NavigationRoute extends PopupRoute {
  NavigationRoute(this.tour);

  final TourModel tour;

  @override
  Color? get barrierColor => Colors.black54;

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => null;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 100);

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return FadeTransition(
      opacity: animation,
      child: DisclaimerScreen(tour),
    );
  }
}

class DisclaimerScreen extends StatelessWidget {
  const DisclaimerScreen(this.tour, {super.key});

  final TourModel tour;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'Remember to obey the law and pay attention to '
              'your surroundings while driving.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          Container(
            color: const Color(0xFFE8F7E1),
            child: LayoutBuilder(builder: (context, constraints) {
              // manual calculation of width and height required to avoid layout
              // shift. :)
              const aspect = 1285.0 / 1985.0;
              final width = constraints.maxWidth;
              final height = width * aspect;
              return Image.asset(
                "assets/traffic.png",
                package: "tourforge_baseline",
                width: width,
                height: height,
              );
            }),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 20.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('I understand'),
                  onPressed: () {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => NavigationScreen(tour)));
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class NavigationScreen extends StatefulWidget {
  const NavigationScreen(this.tour, {super.key});

  final TourModel tour;

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  final NavigationMapController _mapController = NavigationMapController();
  final StreamController<void> _userInteract = StreamController.broadcast();

  final FakeGpsModel _fakeGps = FakeGpsModel();
  final CurrentLocationModel _currentLocation = CurrentLocationModel();
  final CurrentWaypointModel _currentWaypoint = CurrentWaypointModel();
  final MapControllednessModel _mapControlledness = MapControllednessModel();
  final SatelliteEnabledModel _satelliteEnabled = SatelliteEnabledModel();

  final GlobalKey<TourNavigationDrawerState> _drawerKey = GlobalKey();

  late NavigationController _navController;
  StreamSubscription<LatLng> _locationStream =
      const Stream<LatLng>.empty().listen((_) {});
  LatLng _cameraLocation = LatLng(0, 0);

  @override
  void initState() {
    super.initState();

    _navController = NavigationController(
      path: widget.tour.path,
      waypoints: widget.tour.route
          .map((e) => NavigationWaypoint(
                position: LatLng(e.lat, e.lng),
                triggerRadius: e.triggerRadius,
              ))
          .toList(),
    );

    _fakeGps.addListener(_onFakeGpsChanged);
    _currentLocation.addListener(_onCurrentLocationChanged);
    _currentWaypoint.addListener(_onCurrentWaypointChanged);
    _mapControlledness.addListener(_onMapControllednessChanged);
    _satelliteEnabled.addListener(_onSatelliteEnabledChanged);

    NarrationPlaybackController.instance.tour = widget.tour;

    _startGpsListening();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    (() async {
      if (!await HelpViewed.viewed("navigation")) {
        _launchHelp();
      }
    })();
  }

  @override
  void dispose() {
    _fakeGps.removeListener(_onFakeGpsChanged);
    _currentLocation.removeListener(_onCurrentLocationChanged);
    _currentWaypoint.removeListener(_onCurrentWaypointChanged);
    _mapControlledness.removeListener(_onMapControllednessChanged);
    _satelliteEnabled.removeListener(_onSatelliteEnabledChanged);
    _locationStream.cancel();
    _currentLocation.dispose();

    NarrationPlaybackController.instance.reset();

    super.dispose();
  }

  void _startGpsListening() async {
    var stream = await getLocationStream(context);

    if (stream != null) {
      _locationStream.cancel();
      _locationStream = stream.listen((ll) {
        _currentLocation.value = ll;
      });
    }
  }

  void _stopGpsListening() => _locationStream.cancel();

  void _onFakeGpsChanged() {
    if (_fakeGps.value) {
      _stopGpsListening();
    } else {
      _startGpsListening();
    }
  }

  void _onCurrentLocationChanged() {
    _navController.tick(context, _currentLocation.value).then((waypoint) {
      if (_currentWaypoint.index != waypoint && waypoint != null) {
        _currentWaypoint.index = waypoint;
      }
    });
  }

  void _onCurrentWaypointChanged() {
    if (_currentWaypoint.index != null) {
      NarrationPlaybackController.instance
          .playWaypoint(_currentWaypoint.index!);
    }
  }

  void _onMapControllednessChanged() {
    if (_mapControlledness.value && _currentLocation.value != null) {
      _mapController.moveCamera(_currentLocation.value!);
    }
  }

  void _onSatelliteEnabledChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    const bottomHeight = 88.0;
    const drawerHandleHeight = 28.0;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _fakeGps),
        ChangeNotifierProvider.value(value: _currentLocation),
        ChangeNotifierProvider.value(value: _currentWaypoint),
        ChangeNotifierProvider.value(value: _mapControlledness),
        ChangeNotifierProvider.value(value: _satelliteEnabled),
      ],
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: _satelliteEnabled.value
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        child: Scaffold(
          body: Stack(
            children: [
              Positioned.fill(
                child: NavigationMap(
                  controller: _mapController,
                  tour: widget.tour,
                  onCameraMove: (cameraLocation) {
                    _cameraLocation = cameraLocation;
                  },
                  onMoveUpdate: () {
                    _userInteract.add(null);

                    if (_currentLocation.value == null) return;

                    var a = _mapController
                        .latLngToScreenPoint(_currentLocation.value!)!;
                    var b =
                        _mapController.latLngToScreenPoint(_cameraLocation)!;

                    if ((a - b).distance > 48) {
                      _mapControlledness.value = false;
                    }
                  },
                  onMoveBegin: () {},
                  onMoveEnd: () {
                    if (_mapControlledness.value &&
                        _currentLocation.value != null) {
                      _mapController.moveCamera(_currentLocation.value!);
                    }
                  },
                  onPointClick: (index) {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            WaypointDetails(widget.tour.route[index])));
                  },
                  onPoiClick: (index) {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            PoiDetails(widget.tour.pois[index])));
                  },
                ),
              ),
              Positioned(
                top: 0.0,
                left: 0.0,
                right: 0.0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    // Centered against the 56px control row so the status pill
                    // shares a clean centerline with the Back/Help buttons.
                    child: SizedBox(
                      height: 56,
                      child: Center(
                        // Flat (no elevation/shadow) + smaller so it reads as
                        // status, not a tappable control like the gold circles.
                        child: Semantics(
                          label: "Navigating",
                          button: false,
                          child: Material(
                            color: Theme.of(context).colorScheme.secondary,
                            elevation: 0,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(24)),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.near_me,
                                    size: 16,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "Navigating",
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge!
                                        .copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSecondary,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 0.0,
                left: 0.0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _MapCircleButton(
                      tooltip: "Back",
                      icon: Icons.arrow_back,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 0.0,
                right: 0.0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _HelpButton(
                      onPressed: _launchHelp,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: bottomHeight + drawerHandleHeight,
                left: 0.0,
                child: SafeArea(
                  child: AttributionInfo(
                    userInteract: _userInteract.stream,
                  ),
                ),
              ),
              if (kDebugMode)
                const Positioned(
                  bottom: bottomHeight + drawerHandleHeight + 72 * 2,
                  right: 0.0,
                  child: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: _FakeGpsButton(),
                    ),
                  ),
                ),
              const Positioned(
                bottom: bottomHeight + drawerHandleHeight + 72,
                right: 0.0,
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: _SatelliteEnabledButton(),
                  ),
                ),
              ),
              const Positioned(
                bottom: bottomHeight + drawerHandleHeight,
                right: 0.0,
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: _MapControllednessButton(),
                  ),
                ),
              ),
              Positioned(
                top: 0.0,
                left: 0.0,
                right: 0.0,
                bottom: bottomHeight,
                child: SafeArea(
                  child: TourNavigationDrawer(
                    key: _drawerKey,
                    handleHeight: drawerHandleHeight,
                    tour: widget.tour,
                    playWaypoint: (waypointIdx) {
                      _currentWaypoint.index = waypointIdx;
                    },
                  ),
                ),
              ),
              Positioned(
                left: 0.0,
                right: 0.0,
                bottom: 0.0,
                child: SafeArea(
                  child: SizedBox(
                    height: bottomHeight,
                    child: GestureDetector(
                      child: NavigationPanel(tour: widget.tour),
                      onVerticalDragStart: (details) =>
                          _drawerKey.currentState?.onVerticalDragStart(details),
                      onVerticalDragEnd: (details) =>
                          _drawerKey.currentState?.onVerticalDragEnd(details),
                      onVerticalDragUpdate: (details) => _drawerKey.currentState
                          ?.onVerticalDragUpdate(details),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _launchHelp() {
    HelpViewed.markViewed("navigation");
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const NavigationHelpScreen()));
  }
}

/// A floating gold map control. Gold (not frosted) is a deliberate choice for
/// outdoor sunlight readability on a walking tour; the soft shadow lifts it off
/// the map so it reads as a control, not a label.
class _MapCircleButton extends StatelessWidget {
  const _MapCircleButton({
    required this.icon,
    required this.onPressed,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      shape: const CircleBorder(),
      color: scheme.secondary,
      elevation: 3,
      shadowColor: Colors.black.withAlpha(80),
      child: SizedBox(
        width: 56,
        height: 56,
        child: IconButton(
          tooltip: tooltip,
          onPressed: onPressed,
          iconSize: 28,
          color: scheme.onSecondary,
          icon: Icon(icon),
        ),
      ),
    );
  }
}

class _SatelliteEnabledButton extends StatelessWidget {
  const _SatelliteEnabledButton();

  @override
  Widget build(BuildContext context) {
    var satelliteEnabled = context.watch<SatelliteEnabledModel>();
    return _MapCircleButton(
      tooltip: satelliteEnabled.value ? "Map view" : "Satellite view",
      icon: satelliteEnabled.value ? Icons.map_outlined : Icons.satellite_alt,
      onPressed: () => satelliteEnabled.value = !satelliteEnabled.value,
    );
  }
}

class _HelpButton extends StatelessWidget {
  const _HelpButton({required this.onPressed});

  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return _MapCircleButton(
      tooltip: "Help",
      icon: Icons.question_mark,
      onPressed: onPressed,
    );
  }
}

class _FakeGpsButton extends StatelessWidget {
  const _FakeGpsButton();

  @override
  Widget build(BuildContext context) {
    return _MapCircleButton(
      tooltip: "Simulate GPS",
      icon: Icons.bug_report,
      onPressed: () {
        var fakeGps = context.read<FakeGpsModel>();
        fakeGps.value = !fakeGps.value;
      },
    );
  }
}

class _MapControllednessButton extends StatelessWidget {
  const _MapControllednessButton();

  @override
  Widget build(BuildContext context) {
    var mapControlledness = context.watch<MapControllednessModel>();
    return _MapCircleButton(
      tooltip: "Recenter",
      icon: mapControlledness.value ? Icons.gps_fixed : Icons.gps_not_fixed,
      onPressed: () => mapControlledness.value = !mapControlledness.value,
    );
  }
}
