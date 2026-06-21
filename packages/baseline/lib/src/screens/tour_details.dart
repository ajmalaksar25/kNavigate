import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tourforge_baseline/src/help_viewed.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data.dart';
import '../download_manager.dart';
import '../widgets/details_button.dart';
import '../widgets/details_description.dart';
import '../widgets/details_header.dart';
import '../widgets/details_screen_header_delegate.dart';
import '../widgets/waypoint_card.dart';
import 'help_slides.dart';
import 'navigation/navigation.dart';

/// The preview screen for a specific tour and gateway to navigation mode.
///
/// This screen displays the tour's description, gallery, and POI waypoints.
/// Crucially, it acts as a gatekeeper: it queries the [DownloadManager] to
/// determine if all required assets (audio, tiles, images) are cached locally.
/// If not, it presents a [MultiDownload] progress UI. It only permits navigation
/// to the [NavigationScreen] once offline capability is guaranteed.
class TourDetails extends StatefulWidget {
  const TourDetails(this.tour, {super.key});

  final TourModel tour;

  @override
  State<TourDetails> createState() => _TourDetailsState();
}

class _TourDetailsState extends State<TourDetails>
    with SingleTickerProviderStateMixin {
  bool _isLoaded = false;
  bool _isFullyDownloaded = false;

  @override
  void initState() {
    super.initState();

    widget.tour.isFullyDownloaded().then((value) => setState(() {
          _isLoaded = true;
          _isFullyDownloaded = value;
        }));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    (() async {
      if (!await HelpViewed.viewed("tour_details")) {
        _launchHelp();
      }
    })();
  }

  @override
  Widget build(BuildContext context) {
    Widget? action;
    if (!_isLoaded) {
      action = null;
    } else if (_isFullyDownloaded) {
      action = ElevatedButton.icon(
        onPressed: () {
          Navigator.of(context).push(NavigationRoute(widget.tour));
        },
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(0, 44),
          padding: const EdgeInsets.symmetric(horizontal: 18),
        ),
        icon: const Icon(Icons.navigation_rounded, size: 20),
        label: const Text("Start"),
      );
    } else {
      action = _DownloadButton(
        tour: widget.tour,
        onDownloaded: () {
          if (!mounted) return;
          setState(() => _isFullyDownloaded = true);
        },
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: DetailsScreenHeaderDelegate(
                tickerProvider: this,
                gallery: widget.tour.gallery,
                title: widget.tour.title,
                action: action,
                onHelpPressed: _launchHelp,
              ),
            ),
            if (_isLoaded && !_isFullyDownloaded)
              const SliverToBoxAdapter(child: TourNotDownloadedWarning()),
            SliverToBoxAdapter(
                child: DetailsDescription(desc: widget.tour.desc)),
            const SliverToBoxAdapter(
              child: DetailsHeader(
                title: "Tour Stops",
              ),
            ),
            _WaypointList(tour: widget.tour),
            for (final entry in widget.tour.links.entries)
              SliverPadding(
                padding: const EdgeInsets.only(top: 8.0),
                sliver: SliverToBoxAdapter(
                  child: DetailsButton(
                    icon: Icons.link,
                    title: entry.key,
                    onPressed: () {
                      launchUrl(Uri.parse(entry.value.href),
                          mode: LaunchMode.externalApplication);
                    },
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 6)),
          ],
        ),
      ),
    );
  }

  void _launchHelp() {
    HelpViewed.markViewed("tour_details");
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const _TourHelpScreen()));
  }
}

class _TourHelpScreen extends StatefulWidget {
  const _TourHelpScreen();

  @override
  State<_TourHelpScreen> createState() => _TourHelpScreenState();
}

class _TourHelpScreenState extends State<_TourHelpScreen> {
  final HelpSlidesController _controller = HelpSlidesController();

  @override
  Widget build(BuildContext context) {
    return HelpSlidesScreen(
      dismissible: true,
      title: "Help",
      controller: _controller,
      onDone: () {
        Navigator.of(context).pop();
      },
      slides: [
        HelpSlide(
          children: [
            Text(
              "Viewing a Tour",
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24.0),
            Text(
              "Before downloading a tour, you can read its description "
              "and view each of its stops on the tour details page.",
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: 16.0),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24.0),
            Text(
              "Once you've downloaded a tour by tapping the Download button, "
              "the Start button can be used to enter navigation mode, which "
              "includes a map of the tour.",
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: 16.0),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24.0),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 12.0,
                horizontal: 48.0,
              ),
              child: ElevatedButton(
                onPressed: _controller.finish,
                child: Text(
                  "Got it",
                  style: Theme.of(context).textTheme.labelLarge!.copyWith(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class TourNotDownloadedWarning extends StatelessWidget {
  const TourNotDownloadedWarning();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 0),
      child: Container(
        padding: const EdgeInsets.all(14.0),
        decoration: BoxDecoration(
          color: scheme.secondaryContainer,
          borderRadius: const BorderRadius.all(Radius.circular(14)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline,
                size: 20, color: scheme.onSecondaryContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "Download this tour once to use it offline — the map, photos and "
                "audio all keep working without a signal.",
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(color: scheme.onSecondaryContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DownloadButton extends StatefulWidget {
  const _DownloadButton({
    required this.tour,
    required this.onDownloaded,
  });

  final TourModel tour;
  final void Function() onDownloaded;

  @override
  State<_DownloadButton> createState() => _DownloadButtonState();
}

class _DownloadButtonState extends State<_DownloadButton> {
  final ValueNotifier<double> _downloadProgress = ValueNotifier(0.0);
  MultiDownload? _tourDownload;

  @override
  void initState() {
    super.initState();

    (() async {
      var allDownloaded = true;
      var inProgress = true;
      var downloadsInProgress = <Download>[];
      for (final asset in widget.tour.allAssets) {
        var isDownloaded = await asset.isDownloaded;

        if (!isDownloaded && asset.required) {
          allDownloaded = false;

          var downloadInProgress =
              DownloadManager.instance.downloadInProgress(asset.id);

          if (downloadInProgress == null) {
            inProgress = false;
          } else {
            downloadsInProgress.add(downloadInProgress);
          }
        }
      }

      if (allDownloaded) {
        widget.onDownloaded();
      } else if (inProgress) {
        var download = MultiDownload.of(downloadsInProgress);

        download.downloadProgress.listen((progress) {
          _downloadProgress.value =
              progress.downloadedSize / (progress.totalDownloadSize ?? 0);
        });

        download.completed.then((_) {
          widget.onDownloaded();
        }).onError((error, stackTrace) {
          if (kDebugMode) {
            print("Fatal error while downloading: $error");
            print("Stack trace: $stackTrace");
          }
        });

        setState(() {
          _tourDownload = download;
        });
      }
    })();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: _downloadProgress,
      builder: (context, progress, _) {
        final downloading = _tourDownload != null;
        final pct = (progress.clamp(0.0, 1.0) * 100).round();
        return ElevatedButton.icon(
          onPressed: _download,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(0, 44),
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          icon: const Icon(Icons.download, size: 20),
          label: Text(downloading ? "Downloading $pct%" : "Download"),
        );
      },
    );
  }

  Future<void> _download() async {
    if (_tourDownload == null) {
      bool shouldDownload = await Navigator.push(
          context,
          DialogRoute(
              context: context, builder: (context) => _DownloadDialog()));

      if (!shouldDownload || !mounted) return;

      var download = DownloadManager.instance.downloadAll(
        widget.tour.allAssets,
        _CallbackSink((progress) {
          _downloadProgress.value = progress.downloadedSize.toDouble() /
              (progress.totalDownloadSize ?? 0).toDouble();
        }),
      );

      download.downloadProgress.listen((progress) {
        _downloadProgress.value =
            progress.downloadedSize / (progress.totalDownloadSize ?? 0);
      });

      download.completed.then((_) {
        widget.onDownloaded();
      }).onError((error, stackTrace) {
        if (kDebugMode) {
          print("Fatal error while downloading: $error");
          print("Stack trace: $stackTrace");
        }
      });

      setState(() {
        _tourDownload = download;
      });
    } else {}
  }
}

class _WaypointList extends StatelessWidget {
  const _WaypointList({
    Key? key,
    required this.tour,
  }) : super(key: key);

  final TourModel? tour;

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        childCount: tour?.route.length ?? 0,
        (context, index) {
          return Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: WaypointCard(
              waypoint: tour!.route[index],
              index: index,
            ),
          );
        },
      ),
    );
  }
}

class _DownloadDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Download Tour'),
      content: const SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text(
              'Downloading this tour may incur data charges. '
              'It is recommended to connect to WiFi before proceeding.',
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop(false);
          },
        ),
        TextButton(
          child: const Text('Download'),
          onPressed: () {
            Navigator.of(context).pop(true);
          },
        ),
      ],
    );
  }
}

class _CallbackSink<T> implements Sink<T> {
  const _CallbackSink(this.callback);

  final void Function(T) callback;

  @override
  void add(T data) {
    callback(data);
  }

  @override
  void close() {}
}
