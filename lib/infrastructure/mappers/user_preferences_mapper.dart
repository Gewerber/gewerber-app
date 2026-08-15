import 'package:gewerber_backend_client/gewerber_backend_client.dart' as sdk;
import 'package:injectable/injectable.dart';

import 'package:gewerber_app/domain/entities/user_preferences.dart';

/// Maps between the domain [UserPreferences] and the protocol profile types.
@injectable
class UserPreferencesMapper {
  const UserPreferencesMapper();

  UserPreferences fromProfile(sdk.UserProfile profile) {
    return UserPreferences(
      locale: _toAppLocale(profile.locale),
      theme: _toThemePreference(profile.themeMode),
    );
  }

  sdk.Locale toProtocolLocale(AppLocale locale) {
    return sdk.Locale.values.byName(locale.name);
  }

  sdk.AppTheme toProtocolTheme(ThemePreference theme) {
    return sdk.AppTheme.values.byName(theme.name);
  }

  AppLocale _toAppLocale(sdk.Locale locale) => AppLocale.fromName(locale.name);

  ThemePreference _toThemePreference(sdk.AppTheme theme) =>
      ThemePreference.fromName(theme.name);
}
