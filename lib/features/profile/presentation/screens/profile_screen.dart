import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:pharma_finder/core/theme/app_theme.dart';
import 'package:pharma_finder/screen/login_screen.dart';

/// Profile tab. Displays the signed-in user and their saved insurance scheme
/// (a Firestore **Read**), and owns **logout** — which the brief requires for
/// both authentication methods.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.primaryTint,
                    child: Text(
                      _initials(user),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.displayName?.isNotEmpty == true
                              ? user!.displayName!
                              : 'MediMatch user',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user?.email ?? user?.phoneNumber ?? 'Not signed in',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const _SectionLabel('My insurance policy'),
          _InsuranceCard(uid: user?.uid),
          const SizedBox(height: AppSpacing.md),
          const _SectionLabel('Account'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.logout, color: AppColors.danger),
                  title: const Text(
                    'Log out of MediMatch',
                    style: TextStyle(color: AppColors.danger),
                  ),
                  onTap: () => _signOut(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Center(
            child: Text(
              'MediMatch • Healthcare Access Companion • v1.0.0',
              style: TextStyle(fontSize: 11, color: AppColors.muted),
            ),
          ),
        ],
      ),
    );
  }

  static String _initials(User? user) {
    final name = user?.displayName?.trim();
    if (name != null && name.isNotEmpty) {
      final parts = name.split(RegExp(r'\s+'));
      if (parts.length >= 2) {
        return (parts.first[0] + parts[1][0]).toUpperCase();
      }
      return name[0].toUpperCase();
    }
    final email = user?.email;
    if (email != null && email.isNotEmpty) return email[0].toUpperCase();
    return 'M';
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          letterSpacing: 0.7,
          fontWeight: FontWeight.w700,
          color: AppColors.muted,
        ),
      ),
    );
  }
}

/// Firestore **Read**: the scheme saved by the insurance screen.
class _InsuranceCard extends StatelessWidget {
  final String? uid;

  const _InsuranceCard({required this.uid});

  @override
  Widget build(BuildContext context) {
    if (uid == null) {
      return const _InsurancePlaceholder('Sign in to see your policy.');
    }

    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        if (snapshot.hasError) {
          return _InsurancePlaceholder(
            'Could not load your policy: ${snapshot.error}',
          );
        }

        final data = snapshot.data?.data();
        final planName = data?['insurancePlanName'] as String?;
        if (planName == null) {
          return const _InsurancePlaceholder('No scheme selected yet.');
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    color: AppColors.lavender,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.shield_outlined,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        planName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Active coverage',
                        style: TextStyle(fontSize: 12, color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryTint,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Saved',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _InsurancePlaceholder extends StatelessWidget {
  final String message;

  const _InsurancePlaceholder(this.message);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Text(
          message,
          style: const TextStyle(fontSize: 13, color: AppColors.muted),
        ),
      ),
    );
  }
}
