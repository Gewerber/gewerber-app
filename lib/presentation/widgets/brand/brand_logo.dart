import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:gewerber_app/core/utils/constants.dart';

/// Renders the official Gewerber symbol mark from the brand SVG asset.
///
/// Pass [color] (and use [monochrome]) to tint the mark into a single color —
/// e.g. `onPrimary` on the colored brand panel. Without [color] the original
/// brand colors (blue field + mint node) are kept.
class BrandLogo extends StatelessWidget {
  const BrandLogo({
    super.key,
    this.size = 32,
    this.color,
    this.monochrome = false,
  });

  /// Edge length of the square logo box.
  final double size;

  /// When set, the whole mark is recolored to [color].
  final Color? color;

  /// Whether to force the tint (ignored unless [color] is provided).
  final bool monochrome;

  @override
  Widget build(BuildContext context) {
    final svg = SvgPicture.asset(
      AppAssets.gewerberSymbol,
      width: size,
      height: size,
      semanticsLabel: 'Gewerber',
    );

    if (color == null) {
      return svg;
    }

    return ColorFiltered(
      colorFilter: ColorFilter.mode(color!, BlendMode.srcIn),
      child: svg,
    );
  }
}
