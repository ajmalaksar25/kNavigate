import 'package:flutter/material.dart';
import 'package:tourforge_baseline/tourforge.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key, required this.finish});

  final void Function() finish;

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  final _controller = HelpSlidesController();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return HelpSlidesScreen(
      controller: _controller,
      onDone: widget.finish,
      slides: [
        HelpSlide(
          image: Image.asset("assets/karunya1.jpg", fit: BoxFit.cover),
          children: [
            Text(
              "Welcome to\nKarunya Navigator",
              style: text.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12.0),
            Text(
              "Explore Karunya Institute of Technology and Sciences with a "
              "guided campus tour — at your own pace.",
              style: text.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 32.0),
              child: ElevatedButton(
                onPressed: _controller.nextSlide,
                child: const Text("Get started"),
              ),
            ),
          ],
        ),
        HelpSlide(
          // Contextual permission: only ask for GPS here, with a clear reason.
          onSlideLeave: () {
            requestGpsPermissions(context);
          },
          image: Image.asset("assets/karunya2.jpg", fit: BoxFit.cover),
          children: [
            Text("How it works", style: text.headlineSmall, textAlign: TextAlign.center),
            const SizedBox(height: 12.0),
            Text(
              "As you walk the campus, the app uses your location to play a short "
              "narration when you reach each stop. We only use location while the "
              "tour is open.",
              style: text.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 32.0),
              child: ElevatedButton(
                onPressed: _controller.nextSlide,
                style: ElevatedButton.styleFrom(
                  backgroundColor: scheme.secondary,
                  foregroundColor: scheme.onSecondary,
                ),
                child: const Text("Enable location"),
              ),
            ),
          ],
        ),
        HelpSlide(
          image: Image.asset("assets/karunya3.jpg", fit: BoxFit.cover),
          children: [
            Text("You're all set", style: text.headlineSmall, textAlign: TextAlign.center),
            const SizedBox(height: 12.0),
            Text(
              "Pick the Karunya tour to see a preview. Download it once over Wi-Fi, "
              "then everything works offline — even the map.",
              style: text.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 32.0),
              child: ElevatedButton(
                onPressed: _controller.finish,
                child: const Text("View the tour"),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
