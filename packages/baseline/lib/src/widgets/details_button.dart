import 'package:flutter/material.dart';

class DetailsButton extends StatelessWidget {
  const DetailsButton({
    super.key,
    required this.icon,
    required this.title,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // Inset, rounded list row (iOS settings style): leading glyph, label,
    // trailing chevron to signal "opens elsewhere".
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Material(
        type: MaterialType.card,
        color: scheme.surface,
        borderRadius: const BorderRadius.all(Radius.circular(14.0)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Row(
              children: [
                Icon(icon, size: 22, color: scheme.primary),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Icon(Icons.chevron_right,
                    size: 22, color: scheme.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
