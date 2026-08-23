import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gewerber_app/application/auth/auth_cubit.dart';
import 'package:gewerber_app/application/user_profile/user_profile_cubit.dart';
import 'package:gewerber_app/application/user_profile/user_profile_state.dart';
import 'package:gewerber_app/core/theme/app_theme.dart';
import 'package:gewerber_app/l10n/generated/app_localizations.dart';

/// ProfileForm — editable personal profile (extracted for master-detail).
///
/// The e-mail address is part of the login identity and shown read-only; the
/// display name is stored on the server profile.
class ProfileForm extends StatefulWidget {
  const ProfileForm({super.key});

  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<UserProfileCubit>();
    if (cubit.state.status == UserProfileViewStatus.initial) {
      cubit.load();
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  void _initFrom(UserProfileViewStatus status, String? displayName) {
    if (_initialized || status != UserProfileViewStatus.loaded) return;
    _initialized = true;
    _displayNameController.text = displayName ?? '';
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final l10n = AppLocalizations.of(context);
    final saved = await context.read<UserProfileCubit>().saveDisplayName(
      _displayNameController.text,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(saved ? l10n.profileSaved : l10n.profileError)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = context.watch<UserProfileCubit>().state;
    _initFrom(state.status, state.profile?.displayName);

    final email = context.select<AuthCubit, String?>(
      (cubit) => cubit.state.user?.email,
    );

    switch (state.status) {
      case UserProfileViewStatus.initial:
      case UserProfileViewStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case UserProfileViewStatus.failure:
        return Center(child: Text(l10n.profileLoadError));
      case UserProfileViewStatus.loaded:
        break;
    }

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(GewerberTokens.space16),
        children: [
          TextFormField(
            initialValue: email,
            decoration: InputDecoration(
              labelText: l10n.emailLabel,
              prefixIcon: const Icon(Icons.alternate_email_outlined),
              helperText: l10n.profileEmailReadonlyHint,
            ),
            enabled: false,
          ),
          const SizedBox(height: GewerberTokens.space16),
          TextFormField(
            controller: _displayNameController,
            decoration: InputDecoration(
              labelText: l10n.profileDisplayName,
              helperText: l10n.profileDisplayNameHint,
              prefixIcon: const Icon(Icons.person_outline),
            ),
            textCapitalization: TextCapitalization.words,
            validator: (value) {
              // Optional field — only catch absurdly long names.
              if (value != null && value.trim().length > 80) {
                return l10n.authValidationError;
              }
              return null;
            },
          ),
          const SizedBox(height: GewerberTokens.space32),
          FilledButton(
            onPressed: state.isSaving ? null : _submit,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: GewerberTokens.space4,
              ),
              child: state.isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.profileSave),
            ),
          ),
        ],
      ),
    );
  }
}
