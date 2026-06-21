import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens the platform maps app with directions to a coordinate. Shared by the
/// waypoint and POI detail screens (gold accent = an action that leaves the app).
class DirectionsButton extends StatelessWidget {
  const DirectionsButton({
    super.key,
    required this.lat,
    required this.lng,
  });

  final double lat;
  final double lng;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ElevatedButton.icon(
      onPressed: () {
        final url = Platform.isIOS
            ? "https://maps.apple.com/?daddr=$lat,$lng"
            : "https://www.google.com/maps/dir/?api=1&destination=$lat,$lng";
        launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: scheme.secondary,
        foregroundColor: scheme.onSecondary,
        minimumSize: const Size(0, 44),
        padding: const EdgeInsets.symmetric(horizontal: 16),
      ),
      icon: const Icon(Icons.directions, size: 20),
      label: const Text("Directions"),
    );
  }
}
