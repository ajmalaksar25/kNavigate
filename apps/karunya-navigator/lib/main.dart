import 'package:flutter/material.dart';
import 'package:tourforge_baseline/tourforge.dart';

import 'onboarding.dart';
import 'theme.dart';
import 'updater.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runTourForge(
    config: TourForgeConfig(
      appName: "Karunya Navigator",
      appDesc:
          '''Karunya Navigator is a GPS-based campus tour guide for Karunya Institute of Technology and Sciences. It walks you around campus with audio narration at each stop.''',
      // Tour content (tourforge.json + media) is hosted on Cloudflare R2.
      // The base map is bundled offline in the app (assets/tiles.mbtiles).
      baseUrl: "https://knavigator.ajmalaksar.com/v2",
      lightThemeData: lightThemeData,
      darkThemeData: darkThemeData,
      onStartup: checkForUpdate,
    ),
    onboarding: (context, finish) {
      return Onboarding(finish: finish);
    },
  );
}
