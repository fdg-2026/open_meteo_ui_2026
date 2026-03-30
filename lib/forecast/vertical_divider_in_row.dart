import 'package:flutter/material.dart';

// Small helper class for vertical diverders in rows, because a VerticalDivider is
// not displayed inside a Row unless it is wrapped in a Container or SizedBox
// (see https://chatgpt.com/share/69c98599-d3bc-8331-85b8-c83de3a70b84)

class VerticalDividerInRow extends StatelessWidget {
  const VerticalDividerInRow({super.key, this.height});

  final double? height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: VerticalDivider(width: 23, thickness: 1),
    );
  }
}
