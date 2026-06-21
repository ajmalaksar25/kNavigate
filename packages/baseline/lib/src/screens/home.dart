import 'package:flutter/material.dart';
import 'package:tourforge_baseline/src/asset_garbage_collector.dart';
import 'package:tourforge_baseline/src/config.dart';

import '/src/data.dart';
import '/src/screens/tour_details.dart';
import '/src/widgets/asset_image_builder.dart';
import 'about.dart';

/// The root entry point of the TourForge UI catalog.
///
/// This screen acts as the primary interface for users to browse available tours.
/// It uses a [FutureBuilder] to asynchronously parse the `tourforge.json`
/// manifest (via [Project.load]) and renders the decoded [TourModel]s into
/// a scrollable list.
class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Future<Project> tourIndex;

  @override
  void initState() {
    super.initState();

    tourIndex = Project.load();

    // Optional app-level startup hook (e.g. in-app update check). Runs once the
    // first frame is on screen so a valid context/navigator is available.
    final onStartup = tourForgeConfig.onStartup;
    if (onStartup != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) onStartup(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tourForgeConfig.appName),
        actions: [
          PopupMenuButton(
            icon: Icon(
              Icons.more_vert,
              color: Theme.of(context).appBarTheme.foregroundColor,
            ),
            tooltip: 'More',
            elevation: 1.0,
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: "About",
                child: Text("About"),
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case "About":
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const About()));
                  break;
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 20.0),
        children: [
          const _WelcomeCard(),
          const SizedBox(height: 16.0),
          FutureBuilder<Project>(
            future: tourIndex,
            builder: (context, snapshot) {
              var tours = snapshot.data?.tours;

              if (tours != null) {
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: tours.length,
                  itemBuilder: (BuildContext context, int index) =>
                      _TourListItem(tours[index]),
                );
              } else {
                return const Padding(
                  padding: EdgeInsets.only(top: 64.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

/// A warm, on-brand greeting that orients first-time visitors without a wall
/// of text (Miller's Law: say one thing well).
class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: const BorderRadius.all(Radius.circular(18.0)),
      ),
      padding: const EdgeInsets.all(18.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.explore_outlined, size: 30, color: scheme.primary),
          const SizedBox(width: 14.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Explore the campus",
                  style: text.titleLarge!
                      .copyWith(color: scheme.onPrimaryContainer),
                ),
                const SizedBox(height: 4.0),
                Text(
                  "Pick a tour to preview its stops, then download once to "
                  "explore offline — audio, map and all.",
                  style: text.bodyMedium!
                      .copyWith(color: scheme.onPrimaryContainer),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TourListItem extends StatelessWidget {
  const _TourListItem(this.tour);

  final TourModel tour;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final isDriving = tour.type == "driving";

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Material(
        type: MaterialType.card,
        color: scheme.surface,
        borderRadius: const BorderRadius.all(Radius.circular(18)),
        elevation: 2,
        shadowColor: Colors.black.withAlpha(22),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => TourDetails(tour)));
          },
          onLongPress: () => _confirmDelete(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (tour.gallery.isNotEmpty)
                SizedBox(
                  height: 184,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      AssetImageBuilder(
                        tour.gallery[0],
                        builder: (image) =>
                            Image(image: image, fit: BoxFit.cover),
                      ),
                      // Subtle bottom fade so the image settles into the card.
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.center,
                            end: Alignment.bottomCenter,
                            colors: [Color(0x00000000), Color(0x33000000)],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tour.title,
                      style: text.titleLarge!.copyWith(fontSize: 19),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      children: [
                        _Meta(
                          icon: isDriving
                              ? Icons.directions_car_outlined
                              : Icons.directions_walk,
                          label: isDriving ? "Driving tour" : "Walking tour",
                        ),
                        const SizedBox(width: 16.0),
                        _Meta(
                          icon: Icons.place_outlined,
                          label: "${tour.route.length} stops",
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog<bool>(
      context: context,
      builder: (BuildContext context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 24.0),
              const Text(
                "Would you like to delete the locally-downloaded content of this tour?\n\n"
                "You will still be able to redownload this tour in the future if desired.",
                softWrap: true,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () async {
                      await AssetGarbageCollector.run(ignoredTours: {tour.id});
                      if (!context.mounted) return;
                      Navigator.pop(context);
                    },
                    child: const Text('Delete'),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
            ],
          ),
        ),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: scheme.onSurfaceVariant),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .labelMedium!
              .copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
