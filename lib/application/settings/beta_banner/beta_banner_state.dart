import 'package:equatable/equatable.dart';

/// State of the public-beta banner.
class BetaBannerState extends Equatable {
  /// Creates a [BetaBannerState].
  const BetaBannerState({required this.isDismissed});

  /// Whether the user dismissed the banner.
  final bool isDismissed;

  /// Returns a copy with the given fields replaced.
  BetaBannerState copyWith({bool? isDismissed}) =>
      BetaBannerState(isDismissed: isDismissed ?? this.isDismissed);

  @override
  List<Object?> get props => [isDismissed];
}
