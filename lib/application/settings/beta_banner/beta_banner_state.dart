import 'package:equatable/equatable.dart';

/// State representing the beta banner's dismissal state.
class BetaBannerState extends Equatable {
  /// Creates a [BetaBannerState].
  ///
  /// [isDismissed] indicates whether the beta banner has been dismissed by the user.
  /// When true, the banner should not be shown in future app sessions.
  const BetaBannerState({required this.isDismissed});

  /// Whether the beta banner has been dismissed by the user.
  ///
  /// When this is true, the beta banner will not be shown in the app.
  final bool isDismissed;

  /// Creates a new instance with updated fields.
  BetaBannerState copyWith({bool? isDismissed}) {
    return BetaBannerState(isDismissed: isDismissed ?? this.isDismissed);
  }

  @override
  List<Object?> get props => [isDismissed];
}
