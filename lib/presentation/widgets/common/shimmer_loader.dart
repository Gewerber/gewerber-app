import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'package:gewerber_app/core/theme/gewerber_tokens.dart';

/// A shimmer skeleton placeholder used while content is loading.
///
/// Shows animated gradient bars that mimic the shape of the content that
/// will replace them, giving users a visual sense of what's coming.
class ShimmerLoader extends StatelessWidget {
  const ShimmerLoader({
    super.key,
    this.lines = 3,
    this.height = 14,
    this.lastLineWidth,
  });

  /// Number of skeleton lines to render.
  final int lines;

  /// Height of each skeleton line in logical pixels.
  final double height;

  /// Optional width for the last line (as a fraction of max width, 0.0–1.0).
  /// When null, all lines use full width.
  final double? lastLineWidth;

  @override
  Widget build(BuildContext context) {
    final baseColor = Theme.of(context).colorScheme.surfaceContainerHighest;
    final highlightColor = Theme.of(context).colorScheme.surface;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < lines; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: GewerberTokens.space8),
              child: Container(
                height: height,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(
                    GewerberTokens.radiusField,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
