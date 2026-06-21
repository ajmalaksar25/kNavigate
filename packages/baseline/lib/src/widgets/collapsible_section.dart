import 'package:flutter/material.dart';

class CollapsibleSection extends StatefulWidget {
  const CollapsibleSection({
    super.key,
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  State<StatefulWidget> createState() => CollapsibleSectionState();
}

class CollapsibleSectionState extends State<CollapsibleSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 64,
          child: Material(
            type: MaterialType.card,
            color: scheme.surface,
            child: InkWell(
              onTap: () {
                setState(() => _expanded = !_expanded);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    AnimatedRotation(
                      turns: _expanded ? -0.5 : 0,
                      duration: const Duration(milliseconds: 192),
                      child: Icon(
                        size: 28,
                        Icons.expand_more,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Only lay out the body while open — laying it out at height 0 forces a
        // RenderFlex overflow. AnimatedSize keeps the reveal in step with the
        // chevron and clips during the transition.
        AnimatedSize(
          duration: const Duration(milliseconds: 192),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: _expanded
              ? widget.child
              : const SizedBox(width: double.infinity, height: 0),
        ),
      ],
    );
  }
}
