import 'package:flutter/material.dart';

import 'package:pharma_finder/core/firestore/user_repository.dart';
import 'package:pharma_finder/core/theme/app_colors.dart';
import 'package:pharma_finder/features/insurance/domain/entities/insurance_plan.dart';
import 'package:pharma_finder/services/auth_helpers.dart';

/// Editable view of `users/{uid}`.
///
/// Pops with `true` when anything was saved so the caller can reload.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, this.initialProfile});

  /// Profile already loaded by the caller. When omitted the screen fetches
  /// `users/{uid}` itself.
  final Map<String, dynamic>? initialProfile;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  static const List<String> _bloodTypes = <String>[
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

  static const List<String> _districts = <String>[
    'Gasabo',
    'Kicukiro',
    'Nyarugenge',
    'Bugesera',
    'Gatsibo',
    'Kayonza',
    'Kirehe',
    'Ngoma',
    'Nyagatare',
    'Rwamagana',
    'Burera',
    'Gakenke',
    'Gicumbi',
    'Musanze',
    'Rulindo',
    'Gisagara',
    'Huye',
    'Kamonyi',
    'Muhanga',
    'Nyamagabe',
    'Nyanza',
    'Nyaruguru',
    'Ruhango',
    'Karongi',
    'Ngororero',
    'Nyabihu',
    'Nyamasheke',
    'Rubavu',
    'Rusizi',
    'Rutsiro',
  ];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _allergyCtrl = TextEditingController();
  final TextEditingController _coverageCtrl = TextEditingController();
  final TextEditingController _kinCtrl = TextEditingController();
  final TextEditingController _kinPhoneCtrl = TextEditingController();

  /// Last saved values, used to write only the fields the user changed.
  final Map<String, String> _initial = <String, String>{};

  String _email = '';
  String? _bloodType;
  String? _insurance;
  String? _district;

  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _allergyCtrl.dispose();
    _coverageCtrl.dispose();
    _kinCtrl.dispose();
    _kinPhoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    Map<String, dynamic>? data = widget.initialProfile;
    final uid = UserRepository.currentUid;

    if (data == null && uid != null) {
      data = await UserRepository.fetchProfile(uid);
    }
    if (!mounted) return;

    _apply(data ?? const <String, dynamic>{});
    setState(() => _loading = false);
  }

  void _apply(Map<String, dynamic> data) {
    final name = _read(data, 'fullName');
    final email = _read(data, 'email');
    final phone = _read(data, 'phone');

    _initial
      ..['fullName'] = name.isNotEmpty
          ? name
          : UserRepository.currentDisplayName
      ..['email'] = email.isNotEmpty ? email : UserRepository.currentEmail
      ..['phone'] = phone.isNotEmpty ? phone : UserRepository.currentPhone
      ..['bloodType'] = _read(data, 'bloodType')
      ..['allergy'] = _read(data, 'allergy')
      ..['coverage'] = _read(data, 'coverage')
      ..['coverageNumber'] = _read(data, 'coverageNumber')
      ..['nextOfKin'] = _read(data, 'nextOfKin')
      ..['nextOfKinPhone'] = _read(data, 'nextOfKinPhone')
      ..['district'] = _read(data, 'district');

    _nameCtrl.text = _initial['fullName']!;
    _phoneCtrl.text = _initial['phone']!;
    _allergyCtrl.text = _initial['allergy']!;
    _coverageCtrl.text = _initial['coverageNumber']!;
    _kinCtrl.text = _initial['nextOfKin']!;
    _kinPhoneCtrl.text = _initial['nextOfKinPhone']!;
    _email = _initial['email']!;

    final bloodType = _initial['bloodType']!;
    _bloodType = bloodType.isEmpty
        ? null
        : (_bloodTypes.contains(bloodType) ? bloodType : 'Unknown');

    final coverage = _initial['coverage']!;
    _insurance = coverage.isEmpty ? null : coverage;

    final district = _initial['district']!;
    _district = district.isEmpty ? null : district;
  }

  static String _read(Map<String, dynamic> data, String key) =>
      data[key]?.toString().trim() ?? '';

  Future<void> _save() async {
    setState(() => _error = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final uid = UserRepository.currentUid;
    if (uid == null) {
      setState(() {
        _error = 'You need to be signed in to update your profile.';
      });
      return;
    }

    final updates = <String, dynamic>{};
    void consider(String key, String? value, {bool phone = false}) {
      final trimmed = value?.trim() ?? '';
      if (trimmed.isEmpty || trimmed == _initial[key]) return;
      updates[key] = phone ? normalizeRwandanPhone(trimmed) : trimmed;
    }

    consider('fullName', _nameCtrl.text);
    consider('phone', _phoneCtrl.text, phone: true);
    consider('bloodType', _bloodType);
    consider('allergy', _allergyCtrl.text);
    consider('coverage', _insurance);
    consider('coverageNumber', _coverageCtrl.text);
    consider('nextOfKin', _kinCtrl.text);
    consider('nextOfKinPhone', _kinPhoneCtrl.text, phone: true);
    consider('district', _district);

    if (updates.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Nothing to update')));
      Navigator.of(context).pop(false);
      return;
    }

    setState(() => _saving = true);
    try {
      final name = updates['fullName'];
      if (name is String) {
        await UserRepository.updateDisplayName(name);
      }
      await UserRepository.saveProfile(uid, updates);
      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Profile updated')));
      Navigator.of(context).pop(true);
    } catch (error) {
      debugPrint('Profile update failed: $error');
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = 'Could not save your profile. Check your connection and try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        backgroundColor: AppColors.pageBackground,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.textDark,
        title: const Text(
          'Edit Profile',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
        ),
      ),
      body: _loading
          ? const Center(
              child: Text(
                'Loading your passport…',
                style: TextStyle(color: AppColors.textMuted),
              ),
            )
          : SafeArea(
              top: false,
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pagePadding,
                    8,
                    AppSpacing.pagePadding,
                    28,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      _SectionCard(
                        title: 'Identity',
                        icon: Icons.person_rounded,
                        children: <Widget>[
                          _Field(
                            label: 'Full name',
                            child: TextFormField(
                              controller: _nameCtrl,
                              textCapitalization: TextCapitalization.words,
                              decoration: _decoration('Your full name'),
                            ),
                          ),
                          _Field(
                            label: 'Email',
                            child: TextFormField(
                              initialValue: _email.isEmpty
                                  ? 'Not set'
                                  : _email,
                              readOnly: true,
                              enabled: false,
                              decoration: _decoration('Managed by your account'),
                            ),
                          ),
                          _Field(
                            label: 'Phone',
                            child: TextFormField(
                              controller: _phoneCtrl,
                              keyboardType: TextInputType.phone,
                              decoration: _decoration('e.g. 788 123 456'),
                              validator: (value) {
                                final text = value?.trim() ?? '';
                                if (text.isEmpty) return null;
                                return isValidRwandanPhone(text)
                                    ? null
                                    : 'Enter a valid Rwandan mobile number.';
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _SectionCard(
                        title: 'Medical',
                        icon: Icons.medical_information_rounded,
                        children: <Widget>[
                          _Field(
                            label: 'Blood type',
                            child: DropdownButtonFormField<String>(
                              initialValue: _bloodType,
                              decoration: _decoration('Select blood type'),
                              items: <DropdownMenuItem<String>>[
                                for (final type in _bloodTypes)
                                  DropdownMenuItem<String>(
                                    value: type,
                                    child: Text(type),
                                  ),
                              ],
                              onChanged: _saving
                                  ? null
                                  : (value) =>
                                        setState(() => _bloodType = value),
                            ),
                          ),
                          _Field(
                            label: 'Allergies',
                            child: TextFormField(
                              controller: _allergyCtrl,
                              minLines: 2,
                              maxLines: 4,
                              textCapitalization: TextCapitalization.sentences,
                              decoration: _decoration(
                                'e.g. Penicillin (Severe) — leave blank if none',
                              ),
                            ),
                          ),
                          _Field(
                            label: 'Insurance scheme',
                            child: DropdownButtonFormField<String>(
                              initialValue: _insurance,
                              isExpanded: true,
                              decoration: _decoration('Select your scheme'),
                              items: <DropdownMenuItem<String>>[
                                for (final name in _insuranceNames)
                                  DropdownMenuItem<String>(
                                    value: name,
                                    child: Text(
                                      name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                              ],
                              onChanged: _saving
                                  ? null
                                  : (value) =>
                                        setState(() => _insurance = value),
                            ),
                          ),
                          _Field(
                            label: 'Coverage number',
                            child: TextFormField(
                              controller: _coverageCtrl,
                              decoration: _decoration('e.g. RSSB-9842-RW'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _SectionCard(
                        title: 'Emergency contact',
                        icon: Icons.emergency_share_rounded,
                        children: <Widget>[
                          _Field(
                            label: 'Next of kin',
                            child: TextFormField(
                              controller: _kinCtrl,
                              textCapitalization: TextCapitalization.words,
                              decoration: _decoration('Name and relationship'),
                            ),
                          ),
                          _Field(
                            label: 'Next of kin phone',
                            child: TextFormField(
                              controller: _kinPhoneCtrl,
                              keyboardType: TextInputType.phone,
                              decoration: _decoration('e.g. 788 443 210'),
                              validator: (value) {
                                final text = value?.trim() ?? '';
                                if (text.isEmpty) return null;
                                final digits = normalizeRwandanPhone(
                                  text,
                                ).replaceAll(RegExp(r'\D'), '');
                                return digits.length >= 9
                                    ? null
                                    : 'Enter a valid phone number.';
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _SectionCard(
                        title: 'Location',
                        icon: Icons.location_on_rounded,
                        children: <Widget>[
                          _Field(
                            label: 'District',
                            child: DropdownButtonFormField<String>(
                              initialValue: _district,
                              isExpanded: true,
                              decoration: _decoration('Select your district'),
                              items: <DropdownMenuItem<String>>[
                                for (final name in _districtNames)
                                  DropdownMenuItem<String>(
                                    value: name,
                                    child: Text(name),
                                  ),
                              ],
                              onChanged: _saving
                                  ? null
                                  : (value) =>
                                        setState(() => _district = value),
                            ),
                          ),
                        ],
                      ),
                      if (_error != null) ...<Widget>[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.emergencyRedLight,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const Icon(
                                Icons.error_outline_rounded,
                                size: 18,
                                color: AppColors.emergencyRed,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _error!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    height: 1.35,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.emergencyRed,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 52,
                        child: FilledButton(
                          onPressed: _saving ? null : _save,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                            foregroundColor: AppColors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.pill),
                            ),
                          ),
                          child: _saving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.white,
                                  ),
                                )
                              : const Text(
                                  'Save Profile',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  /// Known schemes plus whatever the account already had, so an unrecognised
  /// stored value is never silently dropped from the dropdown.
  List<String> get _insuranceNames {
    final names = InsurancePlan.defaults
        .map((plan) => plan.name)
        .toList(growable: true);
    final current = _insurance;
    if (current != null && !names.contains(current)) names.add(current);
    return names;
  }

  List<String> get _districtNames {
    final names = List<String>.of(_districts);
    final current = _district;
    if (current != null && !names.contains(current)) names.add(current);
    return names;
  }

  static InputDecoration _decoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
    filled: true,
    fillColor: AppColors.grayTint,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    errorMaxLines: 2,
    errorStyle: const TextStyle(
      fontSize: 11.5,
      fontWeight: FontWeight.w600,
      color: AppColors.emergencyRed,
    ),
  );
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icon, size: 18, color: AppColors.primaryGreen),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}
