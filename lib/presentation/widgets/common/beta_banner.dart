import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:gewerber_app/l10n/generated/app_localizations.dart';
import 'package:gewerber_app/application/settings/beta_banner/beta_banner_cubit.dart';

/// Persistent strip shown above the home shell while the product is in a
/// public beta: sets honest expectations and points to the feedback channel.
///
/// This widget is dismissible by the user and will not reappear if the
/// dismissal state is persisted. It follows the same pattern as [AuthErrorBanner]
/// with close button functionality and smooth animations.
class BetaBanner extends StatefulWidget {
  const BetaBanner({super.key});

  @override
  State<BetaBanner> createState() => _BetaBannerState();
}

class _BetaBannerState extends State<BetaBanner> with TickerProviderStateMixin {
  late final BetaBannerCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = BlocProvider.of<BetaBannerCubit>(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final foreground = theme.colorScheme.onSecondaryContainer;

    return StreamBuilder<BetaBannerState>(
      stream: _cubit.stream,
      initialData: _cubit.state,
      builder: (context, snapshot) {
        final isDismissed = snapshot.data?.isDismissed ?? false;

        if (isDismissed) return const SizedBox.shrink();

        return Semantics(
          liveRegion: true,
          child: Material(
            color: theme.colorScheme.secondaryContainer,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child:
                    Row(
                      children: [
                        Icon(
                          Icons.science_outlined,
                          size: 20,
                          color: foreground,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              text: '${l10n.betaBannerTitle} · ',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: foreground,
                              ),
                              children: [
                                TextSpan(
                                  text: l10n.betaBannerText,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: foreground,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        _DismissButton(
                          onDismiss: () {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            _cubit.dismiss();
                          },
                          foreground: foreground,
                        ),
                      ],
                    ).animate().fadeIn().slide(
                      begin: const Offset(0, -0.05),
                      end: Offset.zero,
                      duration: 200.ms,
                      curve: Curves.easeOutCubic,
                    ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DismissButton extends StatelessWidget {
  final VoidCallback onDismiss;
  final Color foreground;

  const _DismissButton({required this.onDismiss, required this.foreground});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return IconButton(
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      icon: Icon(Icons.close_rounded, size: 18, color: foreground),
      onPressed: onDismiss,
      tooltip: l10n.commonDismiss,
    );
  }
}
