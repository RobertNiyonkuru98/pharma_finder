import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:pharma_finder/core/firestore/user_repository.dart';
import 'package:pharma_finder/core/theme/app_colors.dart';

/// Read-only "About MediMatch Rwanda" page backed by `app_config/about`.
///
/// The document is fetched when the caller does not already have it, so the
/// page always reflects the latest published copy without an app release.
class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key, this.about});

  /// About document already loaded by the caller.
  final Map<String, dynamic>? about;

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  late final Future<Map<String, dynamic>?> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.about != null
        ? Future<Map<String, dynamic>?>.value(widget.about)
        : UserRepository.fetchAbout();
  }

  Future<void> _open(String url) async {
    var launched = false;
    try {
      launched = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
    } catch (error) {
      debugPrint('Could not launch $url: $error');
    }
    if (launched || !mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Could not open this link on your device.')),
      );
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
          'About',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            );
          }

          final about = snapshot.data;
          if (snapshot.hasError || about == null || about.isEmpty) {
            return const _UnavailableMessage();
          }
          return _AboutBody(about: about, onOpen: _open);
        },
      ),
    );
  }
}

class _AboutBody extends StatelessWidget {
  const _AboutBody({required this.about, required this.onOpen});

  final Map<String, dynamic> about;
  final Future<void> Function(String url) onOpen;

  String _text(String key) => about[key]?.toString().trim() ?? '';

  @override
  Widget build(BuildContext context) {
    final appName = _text('appName').isEmpty
        ? 'MediMatch Rwanda'
        : _text('appName');
    final version = _text('version');
    final tagline = _text('tagline');
    final body = _text('aboutBody');
    final supportPhone = _text('supportPhone');
    final supportEmail = _text('supportEmail');
    final privacyUrl = _text('privacyUrl');

    return SafeArea(
      top: false,
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
            Container(
              padding: const EdgeInsets.all(AppSpacing.cardPadding),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppRadius.card),
                boxShadow: AppShadows.soft,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              appName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textDark,
                              ),
                            ),
                            if (version.isNotEmpty) ...<Widget>[
                              const SizedBox(height: 4),
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
                                child: Text(
                                  'v$version',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.deepGreen,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (tagline.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 14),
                    Text(
                      tagline,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                  if (body.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 14),
                    Text(
                      body,
                      style: const TextStyle(
                        fontSize: 13.5,
                        height: 1.55,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (supportPhone.isNotEmpty ||
                supportEmail.isNotEmpty ||
                privacyUrl.isNotEmpty) ...<Widget>[
              const SizedBox(height: 20),
              const Text(
                'Support & Policies',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  boxShadow: AppShadows.soft,
                ),
                child: Column(
                  children: <Widget>[
                    if (supportPhone.isNotEmpty)
                      _AboutLinkRow(
                        icon: Icons.phone_rounded,
                        title: 'Support hotline',
                        value: supportPhone,
                        onTap: () => onOpen('tel:$supportPhone'),
                      ),
                    if (supportEmail.isNotEmpty)
                      _AboutLinkRow(
                        icon: Icons.mail_outline_rounded,
                        title: 'Email support',
                        value: supportEmail,
                        onTap: () => onOpen('mailto:$supportEmail'),
                      ),
                    if (privacyUrl.isNotEmpty)
                      _AboutLinkRow(
                        icon: Icons.privacy_tip_outlined,
                        title: 'Privacy policy',
                        value: privacyUrl,
                        onTap: () => onOpen(privacyUrl),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AboutLinkRow extends StatelessWidget {
  const _AboutLinkRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
                color: AppColors.lavenderTint,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 19, color: AppColors.lavenderIcon),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
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

class _UnavailableMessage extends StatelessWidget {
  const _UnavailableMessage();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: AppColors.lavenderTint,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.info_outline_rounded,
                size: 26,
                color: AppColors.lavenderIcon,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'About information is being updated. Please try again later.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
