import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data.dart';
import '../widgets/collapsible_section.dart';
import '../widgets/details_button.dart';
import '../widgets/details_description.dart';
import '../widgets/details_screen_header_delegate.dart';
import '../widgets/directions_button.dart';

class WaypointDetails extends StatefulWidget {
  const WaypointDetails(this.waypoint, {super.key});

  final WaypointModel waypoint;

  @override
  State<WaypointDetails> createState() => _WaypointDetailsState();
}

class _WaypointDetailsState extends State<WaypointDetails>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: DetailsScreenHeaderDelegate(
                tickerProvider: this,
                gallery: widget.waypoint.gallery,
                title: widget.waypoint.title,
                action: DirectionsButton(
                  lat: widget.waypoint.lat,
                  lng: widget.waypoint.lng,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: DetailsDescription(desc: widget.waypoint.desc),
            ),
            if (widget.waypoint.transcript != null)
              SliverPadding(
                padding: const EdgeInsets.only(top: 16.0),
                sliver: SliverToBoxAdapter(
                  child: CollapsibleSection(
                    title: "Transcript",
                    child: DetailsDescription(
                      header: null,
                      desc: widget.waypoint.transcript!,
                    ),
                  ),
                ),
              ),
            for (final entry in widget.waypoint.links.entries)
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
          ],
        ),
      ),
    );
  }
}
