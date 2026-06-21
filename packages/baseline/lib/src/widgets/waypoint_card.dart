import 'package:flutter/material.dart';

import '../data.dart';
import '../screens/waypoint_details.dart';
import '../widgets/asset_image_builder.dart';

class WaypointCard extends StatelessWidget {
  const WaypointCard({
    Key? key,
    required this.waypoint,
    required this.index,
    this.onPlayed,
    this.currentlyPlaying = false,
  }) : super(key: key);

  final WaypointModel waypoint;
  final int index;
  final void Function()? onPlayed;
  final bool currentlyPlaying;

  @override
  Widget build(BuildContext context) {
    const borderRadius = Radius.circular(18);
    final scheme = Theme.of(context).colorScheme;
    final hasImage = waypoint.gallery.isNotEmpty;
    final showPlay = onPlayed != null && !currentlyPlaying;

    return Material(
      elevation: 2,
      borderRadius: const BorderRadius.all(borderRadius),
      type: MaterialType.card,
      color: scheme.surface,
      shadowColor: Colors.black.withAlpha(18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => WaypointDetails(waypoint)));
            },
            borderRadius: BorderRadius.only(
              topLeft: borderRadius,
              topRight: borderRadius,
              bottomLeft: currentlyPlaying ? Radius.zero : borderRadius,
              bottomRight: currentlyPlaying ? Radius.zero : borderRadius,
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  // Thumbnail (or brand placeholder) with a small numbered chip.
                  SizedBox(
                    width: 64,
                    height: 64,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(12)),
                            child: hasImage
                                ? AssetImageBuilder(
                                    waypoint.gallery.first,
                                    builder: (image) =>
                                        Image(image: image, fit: BoxFit.cover),
                                  )
                                : DecoratedBox(
                                    decoration: BoxDecoration(
                                        color: scheme.primaryContainer),
                                    child:
                                        Icon(Icons.place, color: scheme.primary),
                                  ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          left: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: scheme.primary,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                bottomRight: Radius.circular(10),
                              ),
                            ),
                            child: Text(
                              "${index + 1}",
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium!
                                  .copyWith(
                                    color: scheme.onPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          waypoint.title,
                          style: Theme.of(context).textTheme.titleSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          waypoint.desc,
                          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              color: scheme.onSurfaceVariant),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (showPlay)
                    IconButton(
                      onPressed: onPlayed,
                      iconSize: 30,
                      icon: Icon(Icons.play_circle_fill, color: scheme.primary),
                    )
                  else if (!currentlyPlaying)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Icon(Icons.chevron_right,
                          color: scheme.onSurfaceVariant),
                    ),
                ],
              ),
            ),
          ),
          if (currentlyPlaying)
            Material(
              color: scheme.primaryContainer,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  bottomLeft: borderRadius,
                  bottomRight: borderRadius,
                ),
              ),
              child: SizedBox(
                height: 34,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.graphic_eq, size: 16, color: scheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      "Now playing",
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge!
                          .copyWith(color: scheme.primary),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
