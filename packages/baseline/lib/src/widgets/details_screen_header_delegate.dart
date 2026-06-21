import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../data.dart';
import 'gallery.dart';

class DetailsScreenHeaderDelegate extends SliverPersistentHeaderDelegate {
  const DetailsScreenHeaderDelegate({
    required this.tickerProvider,
    required this.gallery,
    required this.title,
    this.action,
    this.onHelpPressed,
  });

  final TickerProvider tickerProvider;
  final List<AssetModel> gallery;
  final String title;
  final Widget? action;
  final void Function()? onHelpPressed;

  @override
  double get maxExtent => 384;

  @override
  double get minExtent {
    final view = ui.PlatformDispatcher.instance.implicitView;
    final topPad =
        view != null ? MediaQueryData.fromView(view).padding.top : 0.0;
    return topPad + kToolbarHeight;
  }

  @override
  TickerProvider get vsync => tickerProvider;

  @override
  FloatingHeaderSnapConfiguration get snapConfiguration =>
      FloatingHeaderSnapConfiguration();

  @override
  PersistentHeaderShowOnScreenConfiguration get showOnScreenConfiguration =>
      const PersistentHeaderShowOnScreenConfiguration();

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final shrinkFactor =
        clampDouble(shrinkOffset / (maxExtent - minExtent), 0.0, 1.0);
    final topPad = MediaQuery.paddingOf(context).top;

    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
                color: Theme.of(context).appBarTheme.backgroundColor),
          ),
        ),
        Opacity(
          opacity:
              1.0 - pow(max(shrinkFactor - 0.8, 0.0), 2) / pow(1.0 - 0.8, 2),
          child: ClipRect(
            child: OverflowBox(
              maxHeight: maxExtent - 80,
              alignment: Alignment.topCenter,
              child: Gallery(
                images: gallery,
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        ),
        // Top scrim: keeps the status bar + circular controls legible over a
        // light photo. Fades out as the header collapses into a solid app bar.
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: Opacity(
              opacity: 1.0 - shrinkFactor,
              child: Container(
                height: topPad + 72,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x59000000), Color(0x00000000)],
                  ),
                ),
              ),
            ),
          ),
        ),
        // Help renders under the title bar so the action button wins when the
        // header is collapsed.
        if (onHelpPressed != null)
          Positioned(
            top: topPad,
            right: 4,
            child: _CircleIconButton(
              icon: Icons.question_mark,
              tooltip: "Help",
              onPressed: onHelpPressed!,
            ),
          ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _DetailsScreenHeader(
            shrinkFactor: shrinkFactor,
            title: title,
            action: action,
          ),
        ),
        // Back stays on top so it's always reachable.
        Positioned(
          top: topPad,
          left: 4,
          child: _CircleIconButton(
            icon: Icons.arrow_back,
            tooltip: "Back",
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ],
    );
  }
}

/// A translucent circular control that stays legible over photos and over the
/// collapsed app bar alike.
class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.onPressed,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        // ~55% black: keeps the white glyph and the circle edge above the 3:1
        // non-text contrast minimum over photos AND the collapsed light app bar.
        color: Colors.black.withAlpha(140),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: IconButton(
          tooltip: tooltip,
          onPressed: onPressed,
          iconSize: 22,
          color: Colors.white,
          icon: Icon(icon),
        ),
      ),
    );
  }
}

class _DetailsScreenHeader extends StatelessWidget {
  const _DetailsScreenHeader({
    required this.shrinkFactor,
    required this.title,
    this.action,
  });

  final double shrinkFactor;
  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final titleLeftPadding =
        20 + pow(max(shrinkFactor - 0.5, 0.0), 2) * (1 / 0.25) * 44;

    return Container(
      color: Theme.of(context).appBarTheme.backgroundColor,
      height: ui.lerpDouble(80, kToolbarHeight, shrinkFactor) ?? kToolbarHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: titleLeftPadding,
          ),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Theme.of(context).appBarTheme.foregroundColor),
              overflow: TextOverflow.ellipsis,
              maxLines: shrinkFactor < 0.45 ? 2 : 1,
            ),
          ),
          if (action != null) const SizedBox(width: 16),
          if (action != null) action!,
          if (action != null) const SizedBox(width: 16.0),
        ],
      ),
    );
  }
}
