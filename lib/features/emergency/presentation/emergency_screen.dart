import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pharma_finder/core/firestore/user_repository.dart';
import 'package:pharma_finder/core/location/location_store.dart';
import 'package:pharma_finder/features/location/live_location.dart';
import 'package:pharma_finder/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:pharma_finder/services/auth_helpers.dart';
import 'package:pharma_finder/services/user_profile.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pharma_finder/core/theme/app_colors.dart';

// ---------------------------------------------------------------------------
// Emergency directories (static until the directory is served from Firestore).
// ---------------------------------------------------------------------------

class _EmergencyService {
  const _EmergencyService({
    required this.title,
    required this.subtitle,
    required this.number,
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    required this.pillBackground,
    required this.pillForeground,
  });

  final String title;
  final String subtitle;
  final String number;
  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final Color pillBackground;
  final Color pillForeground;
}

const List<_EmergencyService> _emergencyServices = <_EmergencyService>[
  _EmergencyService(
    title: 'Rwanda National Police',
    subtitle: 'General & Traffic Dispatch',
    number: '112',
    icon: Icons.local_police_rounded,
    iconBackground: AppColors.lavenderTint,
    iconColor: AppColors.lavenderIcon,
    pillBackground: AppColors.blueTint,
    pillForeground: AppColors.blueIcon,
  ),
  _EmergencyService(
    title: 'Fire & Rescue Brigade',
    subtitle: 'Urban Fire, Extraction, Hazard',
    number: '111',
    icon: Icons.local_fire_department_rounded,
    iconBackground: AppColors.amberIcon,
    iconColor: AppColors.amberIconDark,
    pillBackground: AppColors.amberTint,
    pillForeground: AppColors.amberIconDark,
  ),
  _EmergencyService(
    title: 'GBV / Medical Rapid Care',
    subtitle: 'Isange One Stop Center hotline',
    number: '3512',
    icon: Icons.volunteer_activism_rounded,
    iconBackground: AppColors.mintTint,
    iconColor: AppColors.primaryGreen,
    pillBackground: AppColors.mintTint,
    pillForeground: AppColors.primaryGreen,
  ),
];

enum _TagKind { general, insurance, language }

class _HospitalTag {
  const _HospitalTag(this.label, this.kind);

  final String label;
  final _TagKind kind;
}

class _TraumaCenter {
  const _TraumaCenter({
    required this.name,
    required this.address,
    required this.status,
    required this.distance,
    required this.tags,
    required this.callLabel,
    required this.phone,
    required this.latitude,
    required this.longitude,
  });

  final String name;
  final String address;
  final String status;
  final String distance;
  final List<_HospitalTag> tags;
  final String callLabel;
  final String phone;
  final double latitude;
  final double longitude;
}

const List<_TraumaCenter> _traumaCenters = <_TraumaCenter>[
  _TraumaCenter(
    name: 'CHUK Kigali',
    address: 'KN 4 Ave • 1.1 km (4 min via SAMU priority route)',
    status: 'OPEN 24/7 • LEVEL 1 TRAUMA',
    distance: '1.1km',
    tags: <_HospitalTag>[
      _HospitalTag('Direct Ambulance Bay', _TagKind.general),
      _HospitalTag('RSSB Accepted', _TagKind.insurance),
      _HospitalTag('EN/FR/RW', _TagKind.language),
    ],
    callLabel: 'Call Reception',
    phone: 'tel:+250788300604',
    latitude: -1.9441,
    longitude: 30.0619,
  ),
  _TraumaCenter(
    name: 'King Faisal Hospital Rwanda',
    address: 'KG 544 St, Kacyiru • 4.2 km (11 min drive)',
    status: 'OPEN 24/7 • ADULT & PEDS ICU',
    distance: '4.2km',
    tags: <_HospitalTag>[
      _HospitalTag('Trauma & Cardiac Care', _TagKind.general),
      _HospitalTag('RSSB & Global Ins.', _TagKind.insurance),
      _HospitalTag('EN/FR', _TagKind.language),
    ],
    callLabel: 'Call Emergency',
    phone: 'tel:+250788300555',
    latitude: -1.9433,
    longitude: 30.0895,
  ),
  _TraumaCenter(
    name: 'Rwanda Military Hospital (RMH)',
    address: 'Kanombe, Kicukiro • 8.5 km (18 min drive)',
    status: 'OPEN 24/7 • RESUSCITATION UNIT',
    distance: '8.5km',
    tags: <_HospitalTag>[
      _HospitalTag('Emergency Surgical Deck', _TagKind.general),
      _HospitalTag('MMI & RSSB', _TagKind.insurance),
    ],
    callLabel: 'Call RMH',
    phone: 'tel:+250788301122',
    latitude: -1.9647,
    longitude: 30.1045,
  ),
];

class _FirstAidGuide {
  const _FirstAidGuide({
    required this.title,
    required this.tag,
    required this.description,
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
  });

  final String title;
  final String tag;
  final String description;
  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
}

const List<_FirstAidGuide> _firstAidGuides = <_FirstAidGuide>[
  _FirstAidGuide(
    title: 'Severe Bleeding',
    tag: 'Priority 1',
    description: 'Direct firm pressure with clean cloth. Elevate limb…',
    icon: Icons.bloodtype_rounded,
    iconBackground: AppColors.emergencyRedLight,
    iconColor: AppColors.emergencyRed,
  ),
  _FirstAidGuide(
    title: 'Adult CPR & Choking',
    tag: '100–120 bpm',
    description: 'Interlock hands on center of chest. Push hard and fast 5–…',
    icon: Icons.favorite_rounded,
    iconBackground: AppColors.mintTint,
    iconColor: AppColors.primaryGreen,
  ),
  _FirstAidGuide(
    title: 'Moto / Traffic Crash',
    tag: 'Kigali Roads',
    description: 'Do not remove helmets unless airway blocked.…',
    icon: Icons.two_wheeler_rounded,
    iconBackground: AppColors.amberTint,
    iconColor: AppColors.amberIconDark,
  ),
  _FirstAidGuide(
    title: 'Poison / Ingestion',
    tag: 'Antidote',
    description: 'Keep packaging container. Do not induce vomiting…',
    icon: Icons.science_rounded,
    iconBackground: AppColors.lavenderTint,
    iconColor: AppColors.lavenderIcon,
  ),
];

// ---------------------------------------------------------------------------
// Screen.
// ---------------------------------------------------------------------------

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key, required this.user});

  final UserProfile user;

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
              const _EmergencyTopBar(),
              const SizedBox(height: 16),
              const _LiveGpsCard(),
              const SizedBox(height: 16),
              const _AmbulanceCard(),
              const SizedBox(height: 24),
              const _ServicesDirectory(),
              const SizedBox(height: 24),
              _FirstResponderIdCard(user: user),
              const SizedBox(height: 24),
              const _TraumaCentersSection(),
              const SizedBox(height: 24),
              const _FirstAidGuides(),
              const SizedBox(height: 24),
              const _GuaranteeBanner(),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared in-file building blocks.
// ---------------------------------------------------------------------------

Future<void> _openUri(BuildContext context, String url) async {
  var launched = false;
  try {
    launched = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
  } catch (_) {
    launched = false;
  }
  if (launched || !context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Could not open this link on your device.')),
  );
}

class _CardShell extends StatelessWidget {
  const _CardShell({
    required this.child,
    this.color = AppColors.white,
    this.padding = const EdgeInsets.all(AppSpacing.cardPadding),
  });

  final Widget child;
  final Color color;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadows.soft,
      ),
      child: child,
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({this.color = AppColors.emergencyRed, this.size = 8});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    this.icon,
    this.background = AppColors.white,
    this.foreground = AppColors.textMuted,
    this.fontSize = 10.5,
  });

  final String label;
  final IconData? icon;
  final Color background;
  final Color foreground;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: 12, color: foreground),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                color: foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CallPill extends StatelessWidget {
  const _CallPill({
    required this.label,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.phone_rounded, size: 13, color: foreground),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: foreground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardButton extends StatelessWidget {
  const _CardButton({
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon, size: 16, color: foreground),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: foreground,
                  ),
                ),
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

class _EmergencyTopBar extends StatelessWidget {
  const _EmergencyTopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Row(
            children: <Widget>[
              const Flexible(
                child: Text(
                  'MediMatch',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
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
                  color: AppColors.emergencyRedLight,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    _Dot(size: 6),
                    SizedBox(width: 5),
                    Text(
                      'EMERGENCY',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: AppColors.emergencyRed,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            color: AppColors.primaryGreen,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.person_rounded,
            size: 22,
            color: AppColors.white,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Live GPS.
// ---------------------------------------------------------------------------

class _LiveGpsCard extends StatelessWidget {
  const _LiveGpsCard();

  @override
  Widget build(BuildContext context) {
    // The cubit is provided at app root. Guard the lookup so the card still
    // renders in tests or previews that mount the screen without one.
    final cubit = _maybeLocationCubit(context);
    if (cubit == null) {
      return const _LiveGpsBody(state: null);
    }

    return BlocBuilder<LocationCubit, LocationState>(
      builder: (context, state) => _LiveGpsBody(
        state: state,
        onRefresh: () =>
            context.read<LocationCubit>().requestAndStreamLocation(),
      ),
    );
  }
}

LocationCubit? _maybeLocationCubit(BuildContext context) {
  try {
    return context.read<LocationCubit>();
  } catch (_) {
    return null;
  }
}

String _savedLabel(DateTime? savedAt) {
  if (savedAt == null) return 'recently';
  final diff = DateTime.now().difference(savedAt);
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inHours < 1) return '${diff.inMinutes} min ago';
  if (diff.inDays < 1) return '${diff.inHours} h ago';
  return '${diff.inDays} d ago';
}

class _LiveGpsBody extends StatelessWidget {
  const _LiveGpsBody({required this.state, this.onRefresh});

  final LocationState? state;
  final VoidCallback? onRefresh;

  Future<void> _copyCoordinates(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Coordinates copied to clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final loaded = state is LocationLoaded ? state as LocationLoaded : null;
    final cached = LocationStore.cached;
    final hasFix = loaded != null || cached.hasFix;

    final latitude =
        loaded?.position.latitude ?? (cached.hasFix ? cached.latitude : null);
    final longitude =
        loaded?.position.longitude ?? (cached.hasFix ? cached.longitude : null);
    final accuracy = loaded?.position.accuracy ?? cached.accuracy;
    final placeName = loaded?.placeName ??
        (cached.hasFix ? cached.placeName : 'Rwanda');

    final coordinates = latitude == null || longitude == null
        ? 'No GPS fix yet'
        : '${latitude.abs().toStringAsFixed(4)}° S, '
            '${longitude.toStringAsFixed(4)}° E';

    final error = state is LocationError ? (state as LocationError).message : null;
    final subtitle = error ??
        (hasFix
            ? 'Accurate to ${accuracy.round()} m • Saved '
                '${_savedLabel(loaded != null ? DateTime.now() : cached.savedAt)}'
            : 'Location sharing is off — tap Refresh to locate you.');

    return _CardShell(
      color: AppColors.surfaceTint,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const _Dot(size: 7),
              const SizedBox(width: 7),
              const Flexible(
                child: Text(
                  'LIVE EMERGENCY GPS',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                    color: AppColors.emergencyRed,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _Pill(
                label: hasFix
                    ? 'Accurate to ${accuracy.round()}m'
                    : 'No GPS fix',
                icon: Icons.my_location_rounded,
                fontSize: 10,
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'READ ALOUD TO 112 DISPATCHER',
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            placeName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w800,
              height: 1.15,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              height: 1.35,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 6, 8),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: <Widget>[
                const Icon(
                  Icons.location_on_rounded,
                  size: 18,
                  color: AppColors.primaryGreen,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      coordinates,
                      maxLines: 1,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: latitude == null || longitude == null
                      ? null
                      : () => _copyCoordinates(context, coordinates),
                  icon: const Icon(Icons.copy_rounded, size: 15),
                  label: const Text(
                    'Copy Text',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryGreen,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 44,
            child: OutlinedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text(
                'Refresh location',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryGreen,
                backgroundColor: AppColors.white,
                disabledForegroundColor: AppColors.textMuted,
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Ambulance dispatch.
// ---------------------------------------------------------------------------

class _AmbulanceCard extends StatelessWidget {
  const _AmbulanceCard();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: Stack(
        children: <Widget>[
          const Positioned.fill(
            child: ColoredBox(color: AppColors.emergencyRedLight),
          ),
          Positioned(
            right: -60,
            bottom: -80,
            child: Container(
              width: 220,
              height: 220,
              decoration: const BoxDecoration(
                color: Color(0x14B71C1C),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.emergencyRed,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.medical_services_rounded,
                        size: 20,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'RWANDA SAMU DISPATCH',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: AppColors.emergencyRed,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const _Pill(
                      label: 'Toll-Free 24/7',
                      foreground: AppColors.emergencyRed,
                      fontSize: 10,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'National Medical Ambulance',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                    color: AppColors.emergencyRed,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Direct priority connection to Kigali Central Dispatch & '
                  'Resuscitation Fleet.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.35,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  height: 64,
                  child: FilledButton.icon(
                    onPressed: () => _openUri(context, 'tel:112'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.emergencyRed,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    icon: const Icon(Icons.phone_rounded, size: 20),
                    label: const Text(
                      'CALL 112 (AMBULANCE)',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Services directory.
// ---------------------------------------------------------------------------

class _ServicesDirectory extends StatelessWidget {
  const _ServicesDirectory();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            const Expanded(
              child: Text(
                'Emergency Services Directory',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Rwanda National',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (final service in _emergencyServices)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _EmergencyServiceRow(service: service),
          ),
      ],
    );
  }
}

class _EmergencyServiceRow extends StatelessWidget {
  const _EmergencyServiceRow({required this.service});

  final _EmergencyService service;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.tile),
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: service.iconBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(service.icon, size: 19, color: service.iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  service.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  service.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _CallPill(
            label: service.number,
            background: service.pillBackground,
            foreground: service.pillForeground,
            onTap: () => _openUri(context, 'tel:${service.number}'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// First responder ID.
// ---------------------------------------------------------------------------

class _FirstResponderIdCard extends StatefulWidget {
  const _FirstResponderIdCard({required this.user});

  final UserProfile user;

  @override
  State<_FirstResponderIdCard> createState() => _FirstResponderIdCardState();
}

class _FirstResponderIdCardState extends State<_FirstResponderIdCard> {
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  /// Firestore is the source of truth; the signed-in account fills the name in
  /// when the document has not been written yet.
  Future<Map<String, dynamic>> _load() async {
    final data = <String, dynamic>{'fullName': widget.user.fullName};
    final uid = UserRepository.currentUid;

    if (uid != null) {
      final remote = await UserRepository.fetchProfile(uid);
      if (remote != null) {
        for (final entry in remote.entries) {
          final value = entry.value;
          if (value == null) continue;
          if (value is String && value.trim().isEmpty) continue;
          data[entry.key] = value;
        }
      }
    }
    return data;
  }

  Future<void> _openEdit(Map<String, dynamic> data) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => EditProfileScreen(initialProfile: data),
      ),
    );
    if (saved == true && mounted) {
      setState(() => _future = _load());
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _FirstResponderSkeleton();
        }
        final data =
            snapshot.data ?? <String, dynamic>{'fullName': widget.user.fullName};
        return _FirstResponderCard(
          data: data,
          onEdit: () => _openEdit(data),
        );
      },
    );
  }
}

String _responderText(Map<String, dynamic> data, String key) {
  final value = data[key]?.toString().trim() ?? '';
  return value.isEmpty ? 'Not set' : value;
}

class _FirstResponderCard extends StatelessWidget {
  const _FirstResponderCard({required this.data, required this.onEdit});

  final Map<String, dynamic> data;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final fullName = _responderText(data, 'fullName');
    final bloodType = _responderText(data, 'bloodType');
    final allergy = _responderText(data, 'allergy');
    final coverage = _responderText(data, 'coverage');
    final coverageNumber = _responderText(data, 'coverageNumber');
    final nextOfKin = _responderText(data, 'nextOfKin');

    final kinPhoneRaw = data['nextOfKinPhone']?.toString().trim() ?? '';
    final kinPhoneDigits = kinPhoneRaw.replaceFirst(RegExp(r'^tel:'), '');
    final kinPhoneLabel = kinPhoneDigits.isEmpty
        ? 'Not set'
        : formatRwandanPhone(kinPhoneDigits);
    final kinPhoneUri = kinPhoneDigits.isEmpty
        ? null
        : 'tel:$kinPhoneDigits';

    return _CardShell(
      color: AppColors.surfaceTint,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(
                Icons.badge_rounded,
                size: 22,
                color: AppColors.primaryGreen,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'First Responder ID',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              IconButton(
                onPressed: onEdit,
                tooltip: 'Edit profile',
                icon: const Icon(Icons.edit_rounded, size: 18),
                color: AppColors.primaryGreen,
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
              ),
              const SizedBox(width: 4),
              const _Pill(
                label: 'Verified Patient',
                background: AppColors.mintBadge,
                foreground: AppColors.deepGreen,
                fontSize: 9.5,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppRadius.tile),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const _MiniLabel('Patient Full Name'),
                          const SizedBox(height: 4),
                          Text(
                            fullName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 21,
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
                        const _MiniLabel('Blood Type'),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.emergencyRedLight,
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                          child: Text(
                            bloodType,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.emergencyRed,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Expanded(
                        child: _TintedInfoBox(
                          background: AppColors.emergencyRedLight,
                          label: 'CRITICAL ALLERGY',
                          labelColor: AppColors.emergencyRed,
                          labelIcon: Icons.warning_amber_rounded,
                          children: <Widget>[
                            Text(
                              allergy,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _TintedInfoBox(
                          background: AppColors.mintTint,
                          label: 'ACTIVE COVERAGE',
                          labelColor: AppColors.primaryGreen,
                          labelIcon: Icons.verified_rounded,
                          children: <Widget>[
                            Text(
                              coverage,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              coverageNumber,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const _MiniLabel('Next of Kin / ICE Contact'),
                          const SizedBox(height: 4),
                          Text(
                            nextOfKin,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Material(
                      color: kinPhoneUri == null
                          ? AppColors.grayTint
                          : AppColors.primaryGreen,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      child: InkWell(
                        onTap: kinPhoneUri == null
                            ? null
                            : () => _openUri(context, kinPhoneUri),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 9,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(
                                Icons.phone_rounded,
                                size: 13,
                                color: kinPhoneUri == null
                                    ? AppColors.textMuted
                                    : AppColors.white,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                kinPhoneLabel,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: kinPhoneUri == null
                                      ? AppColors.textMuted
                                      : AppColors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FirstResponderSkeleton extends StatelessWidget {
  const _FirstResponderSkeleton();

  @override
  Widget build(BuildContext context) {
    Widget bar(double width, double height) => Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.grayTint,
        borderRadius: BorderRadius.circular(8),
      ),
    );

    return _CardShell(
      color: AppColors.surfaceTint,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          bar(180, 20),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppRadius.tile),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                bar(140, 16),
                const SizedBox(height: 12),
                bar(double.infinity, 14),
                const SizedBox(height: 12),
                bar(double.infinity, 14),
                const SizedBox(height: 12),
                bar(160, 14),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniLabel extends StatelessWidget {
  const _MiniLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontSize: 9.5,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
        color: AppColors.textMuted,
      ),
    );
  }
}

class _TintedInfoBox extends StatelessWidget {
  const _TintedInfoBox({
    required this.background,
    required this.label,
    required this.labelColor,
    required this.labelIcon,
    required this.children,
  });

  final Color background;
  final String label;
  final Color labelColor;
  final IconData labelIcon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(labelIcon, size: 13, color: labelColor),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                    color: labelColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ...children,
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Trauma centers.
// ---------------------------------------------------------------------------

class _TraumaCentersSection extends StatelessWidget {
  const _TraumaCentersSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Nearest 24/7 Trauma Centers',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Accredited emergency wards with RSSB direct billing',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.3,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Material(
              color: AppColors.lavenderTint,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${_traumaCenters.length} accredited trauma centers '
                        'within 10 km',
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: const SizedBox(
                  width: 42,
                  height: 42,
                  child: Icon(
                    Icons.local_hospital_rounded,
                    size: 20,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        for (final center in _traumaCenters)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _HospitalCard(center: center),
          ),
      ],
    );
  }
}

class _HospitalCard extends StatelessWidget {
  const _HospitalCard({required this.center});

  final _TraumaCenter center;

  void _openDirections(BuildContext context) {
    final url =
        'https://www.google.com/maps/dir/?api=1&destination='
        '${center.latitude},${center.longitude}';
    _openUri(context, url);
  }

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              const _Dot(color: AppColors.primaryGreen, size: 7),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  center.status,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.lavenderTint,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  center.distance,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.lavenderIcon,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            center.name,
            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w800,
              height: 1.15,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            center.address,
            style: const TextStyle(
              fontSize: 12,
              height: 1.35,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: <Widget>[
              for (final tag in center.tags) _TagChip(tag: tag),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              Expanded(
                child: _CardButton(
                  label: center.callLabel,
                  icon: Icons.phone_rounded,
                  background: AppColors.lavenderTint,
                  foreground: AppColors.lavenderIcon,
                  onTap: () => _openUri(context, center.phone),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _CardButton(
                  label: 'Directions',
                  icon: Icons.navigation_rounded,
                  background: AppColors.deepGreen,
                  foreground: AppColors.white,
                  onTap: () => _openDirections(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.tag});

  final _HospitalTag tag;

  @override
  Widget build(BuildContext context) {
    final (Color background, Color foreground) = switch (tag.kind) {
      _TagKind.general => (AppColors.grayTint, AppColors.textMuted),
      _TagKind.insurance => (AppColors.mintBadge, AppColors.deepGreen),
      _TagKind.language => (AppColors.lavenderTint, AppColors.lavenderIcon),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        tag.label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: foreground,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Offline first-aid guides.
// ---------------------------------------------------------------------------

class _FirstAidGuides extends StatelessWidget {
  const _FirstAidGuides();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                color: AppColors.mintTint,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.bolt_rounded,
                size: 18,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Offline First-Aid Quick Guides',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                  color: AppColors.textDark,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const _Pill(
              label: 'Cached',
              background: AppColors.mintTint,
              foreground: AppColors.primaryGreen,
            ),
          ],
        ),
        const SizedBox(height: 14),
        for (var i = 0; i < _firstAidGuides.length; i += 2)
          Padding(
            padding: EdgeInsets.only(
              bottom: i + 2 < _firstAidGuides.length ? 12 : 0,
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(child: _FirstAidCard(guide: _firstAidGuides[i])),
                  const SizedBox(width: 12),
                  if (i + 1 < _firstAidGuides.length)
                    Expanded(
                      child: _FirstAidCard(guide: _firstAidGuides[i + 1]),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _FirstAidCard extends StatelessWidget {
  const _FirstAidCard({required this.guide});

  final _FirstAidGuide guide;

  void _openGuide(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => _FirstAidStepsPage(guide: guide)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.tile),
        boxShadow: AppShadows.soft,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.tile),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _openGuide(context),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: guide.iconBackground,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(guide.icon, size: 17, color: guide.iconColor),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        guide.tag,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  guide.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  guide.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    height: 1.35,
                    color: AppColors.textMuted,
                  ),
                ),
                const Spacer(),
                const SizedBox(height: 8),
                const Text(
                  'View steps ›',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FirstAidStepsPage extends StatelessWidget {
  const _FirstAidStepsPage({required this.guide});

  final _FirstAidGuide guide;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        backgroundColor: AppColors.pageBackground,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.textDark,
        title: Text(
          guide.title,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            '${guide.title} steps are being finalised.\n'
            'This guide will be available offline soon.',
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

// ---------------------------------------------------------------------------
// Guarantee banner.
// ---------------------------------------------------------------------------

class _GuaranteeBanner extends StatelessWidget {
  const _GuaranteeBanner();

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      color: AppColors.surfaceTint,
      padding: const EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.mintTint,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.health_and_safety_rounded,
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
                  'Rwanda Emergency Guarantee',
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryGreen,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Under Rwandan public health law, life-saving trauma triage '
                  'is provided unconditionally prior to insurance processing.',
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.4,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
