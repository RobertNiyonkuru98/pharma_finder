import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'insurance_state.dart';

/// What happened when the user pressed Continue.
enum SaveOutcome {
  /// No scheme chosen yet — stay on the screen.
  noChoice,

  /// Written to Firestore.
  saved,

  /// Browsing without an account, so there is nowhere to save it.
  guest,

  /// The Firestore write failed. The user can retry or continue anyway.
  failed,
}

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

  /// Persists the selection and reports the outcome so the screen can tell
  /// the user what happened instead of silently moving on.
  ///
  /// Never throws: a failed write is returned as [SaveOutcome.failed] with a
  /// readable message in `state.error`.
  Future<SaveOutcome> saveSelection() async {
    final plan = state.selected;
    if (plan == null) {
      emit(state.copyWith(error: 'Choose an insurance scheme first.'));
      return SaveOutcome.noChoice;
    }

    emit(state.copyWith(submitting: true, clearError: true));

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        emit(
          state.copyWith(
            submitting: false,
            error: "You're browsing as a guest, so your scheme isn't saved.",
          ),
        );
        return SaveOutcome.guest;
      }

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'insurancePlanId': plan.id,
        'insurancePlanName': plan.name,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      emit(state.copyWith(submitting: false));
      return SaveOutcome.saved;
    } catch (e) {
      debugPrint('Saving insurance plan failed: $e');
      emit(
        state.copyWith(
          submitting: false,
          error:
              "Couldn't save your scheme. Check your connection and try again.",
        ),
      );
      return SaveOutcome.failed;
    }
  }
}
