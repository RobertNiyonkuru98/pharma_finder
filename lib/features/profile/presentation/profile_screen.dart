import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:pharma_finder/core/theme/app_colors.dart';
import 'package:pharma_finder/services/user_profile.dart';
import 'package:pharma_finder/screen/login_screen.dart';

// ---------------------------------------------------------------------------
// Demo data (hard-coded until the profile passport is backed by a repository).
// ---------------------------------------------------------------------------

class _SettingsItem {
  const _SettingsItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.isDanger = false,
    this.hasHealthDot = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool isDanger;
  final bool hasHealthDot;
}

const List<_SettingsItem> _settingsItems = <_SettingsItem>[
  _SettingsItem(
    title: 'Duty Roster Alerts',
    subtitle: 'Night pharmacy & urgent clinic schedules',
    icon: Icons.notifications_active_rounded,
  ),
  _SettingsItem(
    title: 'GPS & District Permissions',
    subtitle: 'Always while using app (Precise)',
    icon: Icons.gps_fixed_rounded,
  ),
  _SettingsItem(
    title: 'Health & Privacy Passport',
    subtitle: 'Yellow fever, allergies & blood group',
    icon: Icons.badge_rounded,
    hasHealthDot: true,
  ),
  _SettingsItem(
    title: 'SAMU Hotline & Help Desk',
    subtitle: 'Toll-free 112 ambulance guide & FAQs',
    icon: Icons.help_outline_rounded,
    isDanger: true,
  ),
  _SettingsItem(
    title: 'About MediMatch Rwanda',
    subtitle: 'v1.2.0 • Kigali Health Tech Initiative',
    icon: Icons.info_outline_rounded,
  ),
];

TextStyle _capsStyle({Color color = AppColors.textMuted}) => TextStyle(
  fontSize: 9.5,
  fontWeight: FontWeight.w800,
  letterSpacing: 0.5,
  color: color,
);

// ---------------------------------------------------------------------------
// Screen.
// ---------------------------------------------------------------------------

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.user});

  /// The signed-in account this passport belongs to.
  final UserProfile user;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const List<int> _radiusStops = <int>[1, 5, 10, 25];

  int _radiusIndex = 1;
  bool _showOpenFirst = true;
  bool _insuranceOnly = true;

  void _comingSoon(String label) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$label is coming soon.'),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log out of MediMatch?'),
        content: const Text(
          'You will need to sign in again to reach your emergency passport.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.emergencyRed,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await FirebaseAuth.instance.signOut();
    } catch (error) {
      debugPrint('Sign out failed: $error');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not sign out. Please try again.')),
      );
      return;
    }
    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _openPlaceholder(String title) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _ProfilePlaceholderPage(title: title),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pagePadding,
            12,
            AppSpacing.pagePadding,
            28,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _ProfileTopBar(
                onNotifications: () => _comingSoon('Notification center'),
              ),
              const SizedBox(height: 16),
              _IdentityCard(
                user: widget.user,
                onEdit: () => _openPlaceholder('Edit profile'),
              ),
              const SizedBox(height: 24),
              _InsurancePolicySection(
                onChangePolicy: () => _comingSoon('Changing insurance policy'),
                onViewCard: () => _openPlaceholder('Digital insurance card'),
              ),
              const SizedBox(height: 24),
              _LocationDiscoverySection(
                radiusStops: _radiusStops,
                radiusIndex: _radiusIndex,
                onRadiusChanged: (index) =>
                    setState(() => _radiusIndex = index),
                showOpenFirst: _showOpenFirst,
                onShowOpenFirstChanged: (value) =>
                    setState(() => _showOpenFirst = value),
                insuranceOnly: _insuranceOnly,
                onInsuranceOnlyChanged: (value) =>
                    setState(() => _insuranceOnly = value),
                onChangeBase: () => _comingSoon('Changing your base district'),
              ),
              const SizedBox(height: 24),
              _SettingsSupportSection(onOpenItem: _openPlaceholder),
              const SizedBox(height: 24),
              _BottomActions(
                onSwitchAccount: () => _comingSoon('Switching accounts'),
                onLogout: _confirmLogout,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header.
// ---------------------------------------------------------------------------

class _ProfileTopBar extends StatelessWidget {
  const _ProfileTopBar({required this.onNotifications});

  final VoidCallback onNotifications;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primaryGreen,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.location_on_rounded,
            size: 24,
            color: AppColors.white,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'MEDIMATCH',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.6,
                  color: AppColors.primaryGreen,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Profile Passport',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        _RoundIconButton(
          icon: Icons.notifications_none_rounded,
          onTap: onNotifications,
        ),
        const SizedBox(width: 8),
        Container(
          width: 42,
          height: 42,
          decoration: const BoxDecoration(
            color: AppColors.primaryGreen,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.person_rounded,
            size: 21,
            color: AppColors.white,
          ),
        ),
      ],
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
        boxShadow: AppShadows.soft,
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 42,
            height: 42,
            child: Icon(icon, size: 21, color: AppColors.textDark),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Identity card.
// ---------------------------------------------------------------------------

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({required this.user, required this.onEdit});

  final UserProfile user;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Stack(
            children: <Widget>[
              Positioned(
                top: -55,
                right: -55,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: <Color>[
                        AppColors.mintBadge.withValues(alpha: 0.65),
                        AppColors.mintBadge.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.cardPadding),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _ProfileAvatar(user: user),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Flexible(
                                child: Text(
                                  user.fullName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textDark,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 5),
                              const Icon(
                                Icons.verified_rounded,
                                size: 16,
                                color: AppColors.primaryGreen,
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            user.accountLine,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11.5,
                              height: 1.3,
                              color: AppColors.textMuted,
                            ),
                          ),
                          if (user.hasPhone) ...<Widget>[
                            const SizedBox(height: 8),
                            Row(
                              children: <Widget>[
                                const Icon(
                                  Icons.phone_rounded,
                                  size: 12,
                                  color: AppColors.primaryGreen,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    user.formattedPhone,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Container(height: 1, color: const Color(0x0F1B1F2A)),
          Material(
            color: AppColors.pageBackground,
            child: InkWell(
              onTap: onEdit,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.cardPadding,
                  vertical: 14,
                ),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 7),
                    const Expanded(
                      child: Text(
                        'Verified Profile Passport',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Edit Profile ›',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.user});

  final UserProfile user;

  @override
  Widget build(BuildContext context) {
    final photoUrl = user.photoUrl;
    return SizedBox(
      width: 96,
      height: 96,
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: ClipOval(
              child: photoUrl == null
                  ? _AvatarFallback(initials: user.initials)
                  : Image.network(
                      photoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _AvatarFallback(initials: user.initials),
                      loadingBuilder: (context, child, progress) =>
                          progress == null
                          ? child
                          : _AvatarFallback(initials: user.initials),
                    ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.white, width: 2.5),
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 14,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.mintTint,
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w800,
          color: AppColors.primaryGreen,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section header.
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(icon, size: 20, color: AppColors.primaryGreen),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
        ),
        if (trailing != null) ...<Widget>[const SizedBox(width: 8), trailing!],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Insurance policy.
// ---------------------------------------------------------------------------

class _InsurancePolicySection extends StatelessWidget {
  const _InsurancePolicySection({
    required this.onChangePolicy,
    required this.onViewCard,
  });

  final VoidCallback onChangePolicy;
  final VoidCallback onViewCard;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _SectionHeader(
          icon: Icons.shield_rounded,
          title: 'My Insurance Policy',
          trailing: TextButton(
            onPressed: onChangePolicy,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryGreen,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Change',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surfaceTint,
            borderRadius: BorderRadius.circular(AppRadius.card),
            boxShadow: AppShadows.soft,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.mintTint,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.verified_user_rounded,
                      size: 21,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            const Flexible(
                              child: Text(
                                'RSSB (RAMA)',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.mintBadge,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.pill,
                                ),
                              ),
                              child: const Text(
                                'Primary',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.deepGreen,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          'Rwanda Social Security Board',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    size: 22,
                    color: AppColors.primaryGreen,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'MEMBER POLICY ID',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: _capsStyle(),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'RSSB-9842-RW',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          'VALID THROUGH',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: _capsStyle(),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '12 / 2026',
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: <Widget>[
                  const Icon(
                    Icons.add_box_rounded,
                    size: 16,
                    color: AppColors.primaryGreen,
                  ),
                  const SizedBox(width: 6),
                  const Expanded(
                    child: Text(
                      'Direct Billing at 84+ Kigali clinics',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: onViewCard,
                    borderRadius: BorderRadius.circular(8),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            'View Digital Card',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                          SizedBox(width: 3),
                          Icon(
                            Icons.open_in_new_rounded,
                            size: 13,
                            color: AppColors.primaryGreen,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Location & discovery.
// ---------------------------------------------------------------------------

class _LocationDiscoverySection extends StatelessWidget {
  const _LocationDiscoverySection({
    required this.radiusStops,
    required this.radiusIndex,
    required this.onRadiusChanged,
    required this.showOpenFirst,
    required this.onShowOpenFirstChanged,
    required this.insuranceOnly,
    required this.onInsuranceOnlyChanged,
    required this.onChangeBase,
  });

  final List<int> radiusStops;
  final int radiusIndex;
  final ValueChanged<int> onRadiusChanged;
  final bool showOpenFirst;
  final ValueChanged<bool> onShowOpenFirstChanged;
  final bool insuranceOnly;
  final ValueChanged<bool> onInsuranceOnlyChanged;
  final VoidCallback onChangeBase;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const _SectionHeader(
          icon: Icons.navigation_rounded,
          title: 'Location & Discovery',
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(18),
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
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: AppColors.mintTint,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.location_on_rounded,
                      size: 20,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Current Base',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMuted,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Kigali • Nyarugenge / Gasabo',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Material(
                    color: AppColors.lavenderTint,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    child: InkWell(
                      onTap: onChangeBase,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        child: Text(
                          'Change',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.lavenderIcon,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
                decoration: BoxDecoration(
                  color: AppColors.lavenderTint,
                  borderRadius: BorderRadius.circular(AppRadius.tile),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        const Expanded(
                          child: Text(
                            'Default Search Radius',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                          child: Text(
                            '${radiusStops[radiusIndex]} km',
                            maxLines: 1,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 6,
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 18,
                        ),
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 10,
                        ),
                      ),
                      child: Slider(
                        value: radiusIndex.toDouble(),
                        min: 0,
                        max: (radiusStops.length - 1).toDouble(),
                        divisions: radiusStops.length - 1,
                        activeColor: AppColors.primaryGreen,
                        inactiveColor: const Color(0xFFD5D9E8),
                        label: '${radiusStops[radiusIndex]} km',
                        onChanged: (value) => onRadiusChanged(value.round()),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          for (final stop in radiusStops)
                            Text(
                              '$stop km',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: stop == radiusStops[radiusIndex]
                                    ? AppColors.primaryGreen
                                    : AppColors.textMuted,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              _PreferenceToggle(
                title: 'Show open providers first',
                subtitle: 'Prioritize facilities on active duty right now',
                value: showOpenFirst,
                onChanged: onShowOpenFirstChanged,
              ),
              const SizedBox(height: 6),
              _PreferenceToggle(
                title: 'Insurance match only',
                subtitle: 'Filter clinics contracted with RSSB (RAMA)',
                value: insuranceOnly,
                onChanged: onInsuranceOnlyChanged,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PreferenceToggle extends StatelessWidget {
  const _PreferenceToggle({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      height: 1.3,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: AppColors.white,
              activeTrackColor: AppColors.primaryGreen,
              inactiveThumbColor: AppColors.white,
              inactiveTrackColor: const Color(0xFFCBD2D9),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Settings & support.
// ---------------------------------------------------------------------------

class _SettingsSupportSection extends StatelessWidget {
  const _SettingsSupportSection({required this.onOpenItem});

  final ValueChanged<String> onOpenItem;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const _SectionHeader(
          icon: Icons.tune_rounded,
          title: 'Settings & Support',
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppRadius.card),
            boxShadow: AppShadows.soft,
          ),
          child: Column(
            children: <Widget>[
              for (final item in _settingsItems)
                _SettingsRow(item: item, onTap: () => onOpenItem(item.title)),
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({required this.item, required this.onTap});

  final _SettingsItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tileColor = item.isDanger
        ? AppColors.emergencyRedLight
        : AppColors.lavenderTint;
    final iconColor = item.isDanger
        ? AppColors.emergencyRed
        : AppColors.lavenderIcon;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
        child: Row(
          children: <Widget>[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: tileColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(item.icon, size: 19, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Flexible(
                        child: Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                      if (item.hasHealthDot) ...<Widget>[
                        const SizedBox(width: 6),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bottom actions.
// ---------------------------------------------------------------------------

class _BottomActions extends StatelessWidget {
  const _BottomActions({required this.onSwitchAccount, required this.onLogout});

  final VoidCallback onSwitchAccount;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SizedBox(
          height: 56,
          child: Material(
            color: AppColors.lavenderTint,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: InkWell(
              onTap: onSwitchAccount,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.switch_account_rounded,
                      size: 20,
                      color: AppColors.lavenderIcon,
                    ),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Switch or Add Another Account',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.lavenderIcon,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Center(
          child: TextButton.icon(
            onPressed: onLogout,
            icon: const Icon(
              Icons.logout_rounded,
              size: 18,
              color: AppColors.emergencyRed,
            ),
            label: const Text(
              'Log Out of MediMatch',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.emergencyRed,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfilePlaceholderPage extends StatelessWidget {
  const _ProfilePlaceholderPage({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        backgroundColor: AppColors.pageBackground,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.textDark,
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            '$title will be available soon.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}
