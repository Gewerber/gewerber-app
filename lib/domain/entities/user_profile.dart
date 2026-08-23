import 'package:equatable/equatable.dart';

/// Editable profile data of the signed-in user, backed by the server's
/// `userProfile` endpoint.
///
/// The e-mail address is part of the authentication identity ([User]) and
/// cannot be changed here.
class UserProfile extends Equatable {
  const UserProfile({required this.userId, this.displayName});

  /// Stable server-side identifier of the owning user account.
  final String userId;

  /// Optional display name shown instead of the e-mail address.
  final String? displayName;

  @override
  List<Object?> get props => [userId, displayName];
}
