import 'package:equatable/equatable.dart';

/// Entity representing the beta banner user preferences.
class BetaBannerPreferences extends Equatable {
  /// Creates a beta banner preferences entity.
  const BetaBannerPreferences({required this.isDismissed});

  /// Whether the beta banner has been dismissed by the user.
  final bool isDismissed;

  /// Creates a new instance with updated dismissal state.
  BetaBannerPreferences copyWith({bool? isDismissed}) {
    return BetaBannerPreferences(isDismissed: isDismissed ?? this.isDismissed);
  }

  @override
  List<Object?> get props => [isDismissed];
}
