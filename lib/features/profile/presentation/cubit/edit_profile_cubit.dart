import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:pharma_finder/core/firestore/user_repository.dart';

/// Values currently held by the edit form, normalised for display.
class EditProfileForm extends Equatable {
  const EditProfileForm({
    this.fullName = '',
    this.email = '',
    this.phone = '',
    this.bloodType = '',
    this.allergy = '',
    this.coverage = '',
    this.coverageNumber = '',
    this.nextOfKin = '',
    this.nextOfKinPhone = '',
    this.district = '',
  });

  final String fullName;
  final String email;
  final String phone;
  final String bloodType;
  final String allergy;
  final String coverage;
  final String coverageNumber;
  final String nextOfKin;
  final String nextOfKinPhone;
  final String district;

  @override
  List<Object?> get props => <Object?>[
    fullName,
    email,
    phone,
    bloodType,
    allergy,
    coverage,
    coverageNumber,
    nextOfKin,
    nextOfKinPhone,
    district,
  ];
}

class EditProfileState extends Equatable {
  const EditProfileState({
    this.loading = true,
    this.saving = false,
    this.error,
    this.form = const EditProfileForm(),
    this.bloodType,
    this.insurance,
    this.district,
    this.revision = 0,
  });

  final bool loading;
  final bool saving;
  final String? error;
  final EditProfileForm form;
  final String? bloodType;
  final String? insurance;
  final String? district;

  /// Increments on every successful load so the view can refresh controllers.
  final int revision;

  EditProfileState copyWith({
    bool? loading,
    bool? saving,
    String? error,
    bool clearError = false,
    EditProfileForm? form,
    String? bloodType,
    String? insurance,
    String? district,
    int? revision,
  }) {
    return EditProfileState(
      loading: loading ?? this.loading,
      saving: saving ?? this.saving,
      error: clearError ? null : (error ?? this.error),
      form: form ?? this.form,
      bloodType: bloodType ?? this.bloodType,
      insurance: insurance ?? this.insurance,
      district: district ?? this.district,
      revision: revision ?? this.revision,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    loading,
    saving,
    error,
    form,
    bloodType,
    insurance,
    district,
    revision,
  ];
}

/// Loads and edits `users/{uid}`. Saving stays in the screen because it owns
/// the text controllers; this cubit owns everything rendered by the widgets.
class EditProfileCubit extends Cubit<EditProfileState> {
  EditProfileCubit() : super(const EditProfileState());

  static const List<String> bloodTypes = <String>[
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
    'Unknown',
  ];

  Future<void> load({Map<String, dynamic>? initialProfile}) async {
    emit(state.copyWith(loading: true, clearError: true));

    Map<String, dynamic>? data = initialProfile;
    final uid = UserRepository.currentUid;
    if (data == null && uid != null) {
      data = await UserRepository.fetchProfile(uid);
    }

    final form = _formFrom(data ?? const <String, dynamic>{});
    if (isClosed) return;
    emit(
      EditProfileState(
        loading: false,
        form: form,
        bloodType: form.bloodType.isEmpty ? null : form.bloodType,
        insurance: form.coverage.isEmpty ? null : form.coverage,
        district: form.district.isEmpty ? null : form.district,
        revision: state.revision + 1,
      ),
    );
  }

  void selectBloodType(String? value) =>
      emit(state.copyWith(bloodType: value));

  void selectInsurance(String? value) =>
      emit(state.copyWith(insurance: value));

  void selectDistrict(String? value) => emit(state.copyWith(district: value));

  void clearError() => emit(state.copyWith(clearError: true));

  void startSaving() => emit(state.copyWith(saving: true, clearError: true));

  void fail(String message) =>
      emit(state.copyWith(saving: false, error: message));

  static EditProfileForm _formFrom(Map<String, dynamic> data) {
    String read(String key) => data[key]?.toString().trim() ?? '';

    final name = read('fullName');
    final email = read('email');
    final phone = read('phone');
    final bloodType = read('bloodType');
    final coverage = read('coverage');
    final district = read('district');

    return EditProfileForm(
      fullName: name.isEmpty ? UserRepository.currentDisplayName : name,
      email: email.isEmpty ? UserRepository.currentEmail : email,
      phone: phone.isEmpty ? UserRepository.currentPhone : phone,
      bloodType: bloodType.isEmpty
          ? ''
          : (bloodTypes.contains(bloodType) ? bloodType : 'Unknown'),
      allergy: read('allergy'),
      coverage: coverage,
      coverageNumber: read('coverageNumber'),
      nextOfKin: read('nextOfKin'),
      nextOfKinPhone: read('nextOfKinPhone'),
      district: district,
    );
  }
}
