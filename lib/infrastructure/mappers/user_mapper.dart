import 'package:injectable/injectable.dart';
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart';

import 'package:gewerber_app/domain/entities/user.dart';

/// Maps an authentication result into the domain [User] entity.
@injectable
class UserMapper {
  const UserMapper();

  /// Builds a [User] from a signed-in [AuthSuccess].
  ///
  /// The email is supplied by the caller — it is known locally at sign-in
  /// time but not carried inside [AuthSuccess].
  User fromAuthSuccess(AuthSuccess authSuccess, String email) {
    return User(
      id: authSuccess.authUserId.toString(),
      email: email,
      displayName: null,
    );
  }
}
