import 'package:equatable/equatable.dart';

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

/// Full identity of the authenticated user: optional global admin role and all
/// business memberships.
///
/// Mirrors the server-side `MyIdentity` model returned by `userProfile.me()`.
class MyIdentity extends Equatable {
  const MyIdentity({
    required this.userId,
    this.globalRole,
    required this.memberships,
  });

  /// Stable server-side identifier.
  final String userId;

  /// Optional global platform admin role (`null` for regular users).
  final AdminRole? globalRole;

  /// All business memberships, ordered by ascending `businessId`.
  final List<MyMembershipInfo> memberships;

  @override
  List<Object?> get props => [userId, globalRole, memberships];
}
