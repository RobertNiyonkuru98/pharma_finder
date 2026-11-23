import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:pharma_finder/core/firestore/user_repository.dart';
import 'package:pharma_finder/services/user_profile.dart';

/// Firestore profile plus the optional `app_config/about` document.
class ProfileBundle extends Equatable {
  const ProfileBundle({required this.profile, this.about});

  factory ProfileBundle.fromUser(UserProfile user) {
    return ProfileBundle(
      profile: <String, dynamic>{
        'fullName': user.fullName,
        'email': user.email,
        'phone': user.phone,
        'photoUrl': user.photoUrl,
      },
    );
  }

  final Map<String, dynamic> profile;
  final Map<String, dynamic>? about;

  @override
  List<Object?> get props => <Object?>[profile, about];
}

class ProfileState extends Equatable {
  const ProfileState({required this.loading, required this.bundle});

  final bool loading;
  final ProfileBundle bundle;

  ProfileState copyWith({bool? loading, ProfileBundle? bundle}) {
    return ProfileState(
      loading: loading ?? this.loading,
      bundle: bundle ?? this.bundle,
    );
  }

  @override
  List<Object?> get props => <Object?>[loading, bundle];
}

/// Loads the signed-in account's profile and the About document.
///
/// Firestore values win, the signed-in account fills the gaps, and a failed
/// read falls back to the account-only snapshot instead of blocking the screen.
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this.user)
    : super(ProfileState(loading: true, bundle: ProfileBundle.fromUser(user)));

  final UserProfile user;

  Future<void> load() async {
    emit(state.copyWith(loading: true));

    final bundle = await _fetch();
    if (isClosed) return;
    emit(ProfileState(loading: false, bundle: bundle));
  }

  Future<void> reload() => load();

  Future<ProfileBundle> _fetch() async {
    final profile = ProfileBundle.fromUser(user).profile;

    final uid = UserRepository.currentUid;
    if (uid != null) {
      final remote = await UserRepository.fetchProfile(uid);
      if (remote != null) {
        for (final entry in remote.entries) {
          final value = entry.value;
          if (value == null) continue;
          if (value is String && value.trim().isEmpty) continue;
          profile[entry.key] = value;
        }
      }
    }

    final about = await UserRepository.fetchAbout();
    return ProfileBundle(profile: profile, about: about);
  }
}
