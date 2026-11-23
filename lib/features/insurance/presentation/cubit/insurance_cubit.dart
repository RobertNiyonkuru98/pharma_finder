import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'insurance_state.dart';

/// Owns selection + persistence of the user's insurance scheme.
///
/// This is the app's **Create/Update** operation: choosing a plan writes
/// `users/{uid}.insurancePlan` to Firestore, and choosing again updates it.
class InsuranceCubit extends Cubit<InsuranceState> {
  InsuranceCubit() : super(const InsuranceState());

  void select(String planId) {
    emit(state.copyWith(selectedId: planId, clearError: true));
  }

  void search(String query) {
    emit(state.copyWith(query: query));
  }

  void clearSearch() {
    emit(state.copyWith(query: ''));
  }

  /// Persists the selection, then returns true so the caller can navigate.
  ///
  /// Never throws: if Firebase is unreachable the user is still allowed through
  /// to the app, and the failure is reported in state. Blocking the whole app
  /// on a database write would make a network hiccup look like a broken build.
  Future<bool> saveSelection() async {
    final plan = state.selected;
    if (plan == null) {
      emit(state.copyWith(error: 'Choose an insurance scheme first.'));
      return false;
    }

    emit(state.copyWith(submitting: true, clearError: true));

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        emit(
          state.copyWith(
            submitting: false,
            error: 'Not signed in — selection saved on this device only.',
          ),
        );
        return true;
      }

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'insurancePlanId': plan.id,
        'insurancePlanName': plan.name,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      emit(state.copyWith(submitting: false));
      return true;
    } catch (e) {
      emit(
        state.copyWith(
          submitting: false,
          error: 'Could not save to Firestore: $e',
        ),
      );
      return true; // still let the user in
    }
  }
}
