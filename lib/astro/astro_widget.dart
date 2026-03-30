import 'package:flutter/material.dart';
import 'package:moon_phase/moon_widget.dart';
import 'astro_provider.dart';

class AstroWidget extends StatelessWidget {
  const AstroWidget({super.key, required this.astroProvider});

  final AstroProvider astroProvider;
  final double arrowSize = 20;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          children: [
            Icon(Icons.sunny, size: arrowSize + 4, color: Colors.grey.shade400),
            Icon(Icons.arrow_upward, size: arrowSize),
            Text(astroProvider.sunrise),
            Icon(Icons.arrow_downward, size: arrowSize),
            Text(astroProvider.sunset),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 3),
              child: MoonWidget(
                date: DateTime.now(),
                size: arrowSize - 2,
                moonColor: Colors.grey.shade400,
                earthshineColor: Colors.blueGrey.shade800,
              ),
            ),
            if ((astroProvider.moonrise).compareTo(astroProvider.moonset) <= 0)
              Row(
                children: [
                  Icon(Icons.arrow_upward, size: arrowSize),
                  Text(astroProvider.moonrise),
                  Icon(Icons.arrow_downward, size: arrowSize),
                  Text(astroProvider.moonset),
                ],
              ),
            if ((astroProvider.moonrise).compareTo(astroProvider.moonset) > 0)
              Row(
                children: [
                  Icon(Icons.arrow_downward, size: arrowSize),
                  Text(astroProvider.moonset),
                  Icon(Icons.arrow_upward, size: arrowSize),
                  Text(astroProvider.moonrise),
                ],
              ),
          ],
        ),
      ],
    );
  }
}
