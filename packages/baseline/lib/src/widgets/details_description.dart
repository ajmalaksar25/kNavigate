import 'package:flutter/material.dart';

class DetailsDescription extends StatelessWidget {
  const DetailsDescription({
    super.key,
    this.header = "Description",
    required this.desc,
  });

  final String? header;
  final String desc;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: 16.0, right: 16.0, top: 20.0, bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (header != null)
            Text(
              header!.toUpperCase(),
              style: Theme.of(context).textTheme.labelMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    letterSpacing: 0.6,
                  ),
            ),
          if (header != null) const SizedBox(height: 8),
          Text(
            desc,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
