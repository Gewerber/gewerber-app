import 'package:equatable/equatable.dart';

/// An authenticated Gewerber user.
///
/// Immutable domain entity; extended (profile, business memberships) as the
/// corresponding backend models are introduced.
class User extends Equatable {
  const User({required this.id, required this.email, this.displayName});

  /// Stable server-side identifier.
  final String id;

  /// Verified primary e-mail address.
  final String email;

  /// Optional display name.
  final String? displayName;

  @override
  List<Object?> get props => [id, email, displayName];
}
