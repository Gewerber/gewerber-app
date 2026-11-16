import 'package:equatable/equatable.dart';

import 'package:gewerber_app/domain/value_objects/social_auth_provider.dart';

/// Global platform admin role (from the `admin_user` allowlist).
///
/// Mirrors the server-side `AdminRole` enum — values are lowercase names
/// serialised via `serialized: byName`.
enum AdminRole {
  moderator,
  admin;

  /// Resolves a [name] to the corresponding enum value.
  ///
  /// Falls back to [moderator] for unknown names, matching the server
  /// behaviour of the generated `fromJson` factory.
  factory AdminRole.fromName(String name) {
    return switch (name) {
      'moderator' => AdminRole.moderator,
      'admin' => AdminRole.admin,
      _ => AdminRole.moderator,
    };
  }

  String get toJson => name;
}

/// Membership role within a single business.
///
/// Mirrors the server-side `MembershipRole` enum.
enum MembershipRole {
  owner,
  admin,
  member;

  /// Resolves a [name] to the corresponding enum value.
  ///
  /// Falls back to [member] for unknown names, matching the server behaviour.
  factory MembershipRole.fromName(String name) {
    return switch (name) {
      'owner' => MembershipRole.owner,
      'admin' => MembershipRole.admin,
      'member' => MembershipRole.member,
      _ => MembershipRole.member,
    };
  }

  String get toJson => name;
}

/// Describes one business the authenticated user belongs to.
class MyMembershipInfo extends Equatable {
  const MyMembershipInfo({
    required this.businessId,
    required this.businessName,
    required this.role,
  });

  final int businessId;
  final String businessName;
  final MembershipRole role;

  @override
  List<Object?> get props => [businessId, businessName, role];
}

/// Full identity of the authenticated user: optional global admin role, all
/// business memberships and the profile attributes the backend derives from the
/// connected identity providers.
///
/// Mirrors the server-side `MyIdentity` model returned by `userProfile.me()`.
class MyIdentity extends Equatable {
  const MyIdentity({
    required this.userId,
    this.globalRole,
    required this.memberships,
    this.primaryEmail,
    this.connectedProviders = const [],
  });

  /// Stable server-side identifier.
  final String userId;

  /// Optional global platform admin role (`null` for regular users).
  final AdminRole? globalRole;

  /// All business memberships, ordered by ascending `businessId`.
  final List<MyMembershipInfo> memberships;

  /// Address the user should be shown, taken from a connected identity
  /// provider. `null` when no provider supplied one (e.g. a phone-only
  /// account); it is not necessarily unique to one human.
  final String? primaryEmail;

  /// Social providers that hold an account row for this auth user, in the
  /// backend's declaration order. Empty for email accounts.
  final List<SocialAuthProvider> connectedProviders;

  @override
  List<Object?> get props => [
    userId,
    globalRole,
    memberships,
    primaryEmail,
    connectedProviders,
  ];
}
