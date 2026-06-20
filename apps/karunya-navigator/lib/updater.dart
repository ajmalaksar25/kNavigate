import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

/// In-app updater for sideloaded builds (v2+).
///
/// On launch the app fetches a small manifest from R2 and, if a newer build
/// exists, offers to download and install it. This lets every version from v2
/// onward update over-the-air without the Play Store.
///
/// Manifest format (hosted at [_manifestUrl]):
/// ```json
/// {
///   "versionCode": 12,
///   "versionName": "2.1.0",
///   "url": "https://knavigator.ajmalaksar.com/app/Karunya-Navigator-2.1.0.apk",
///   "notes": "What's new in this build"
/// }
/// ```
const _manifestUrl = "https://knavigator.ajmalaksar.com/app/version.json";

/// Checks for a newer build and, with the user's consent, downloads + installs
/// it. Fails silently — an update problem must never block using the app
/// (Apple "Agency & Forgiveness": the user's goal is never blocked).
Future<void> checkForUpdate(BuildContext context) async {
  try {
    final info = await PackageInfo.fromPlatform();
    final current = int.tryParse(info.buildNumber) ?? 0;

    final resp = await http
        .get(Uri.parse(_manifestUrl))
        .timeout(const Duration(seconds: 8));
    if (resp.statusCode != 200) return;

    final m = jsonDecode(resp.body) as Map<String, dynamic>;
    final latest = (m['versionCode'] as num?)?.toInt() ?? 0;
    final url = m['url'] as String?;
    if (url == null || latest <= current) return;

    if (!context.mounted) return;
    final accepted = await _prompt(
      context,
      m['versionName']?.toString() ?? '',
      m['notes']?.toString() ?? '',
    );
    if (accepted != true || !context.mounted) return;

    await _downloadAndInstall(context, url, latest);
  } catch (_) {
    // Silent by design.
  }
}

Future<bool?> _prompt(BuildContext context, String versionName, String notes) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Update available'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(versionName.isEmpty
              ? 'A newer version of Karunya Navigator is ready to install.'
              : 'Karunya Navigator $versionName is ready to install.'),
          if (notes.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(notes, style: Theme.of(ctx).textTheme.bodySmall),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Later'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Update'),
        ),
      ],
    ),
  );
}

Future<void> _downloadAndInstall(
    BuildContext context, String url, int versionCode) async {
  final progress = ValueNotifier<double>(0);
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      title: const Text('Downloading update'),
      content: ValueListenableBuilder<double>(
        valueListenable: progress,
        builder: (_, p, __) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LinearProgressIndicator(value: p > 0 ? p : null),
            const SizedBox(height: 12),
            Text(p > 0 ? '${(p * 100).toStringAsFixed(0)}%' : 'Starting…'),
          ],
        ),
      ),
    ),
  );

  try {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/karunya-navigator-$versionCode.apk');

    final resp = await http.Client().send(http.Request('GET', Uri.parse(url)));
    final total = resp.contentLength ?? 0;
    final sink = file.openWrite();
    var received = 0;
    await for (final chunk in resp.stream) {
      sink.add(chunk);
      received += chunk.length;
      if (total > 0) progress.value = received / total;
    }
    await sink.close();

    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }
    // Launches the system package installer (needs REQUEST_INSTALL_PACKAGES).
    await OpenFilex.open(file.path);
  } catch (_) {
    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }
}
