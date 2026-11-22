import 'package:flutter/material.dart';
import '../location/live_location.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF0F4C3A);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 18),
          onPressed: () {},
        ),
        title: const Text('Welcome Onboarding', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Skip', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w600)),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Profile / Brand
            Center(
              child: Column(
                children: [
                  const CircleAvatar(radius: 18, backgroundColor: Color(0xFFE1F5EE), child: Icon(Icons.local_hospital, color: primaryColor, size: 18)),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('MediMatch', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                      const SizedBox(width: 6),
                      BlocBuilder<LocationCubit, LocationState>(
                        builder: (context, state) {
                          String label = 'Locating...';
                          if (state is LocationLoaded) {
                            label = state.placeName; // Current location of where user are at that moment
                            } else if (state is LocationError) {
                              label = 'Rwanda'; // Graceful fallback
                            }
                            return GestureDetector(
                              onTap: () => context.read<LocationCubit>().getCurrentLocation(), 
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE1F5EE),
                                  borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.location_on, size: 10, color: Color(0xFF0F4C3A)),
                                      const SizedBox(width: 3),
                                      Text(
                                        label,
                                        style: const TextStyle(
                                          fontSize: 9.5,
                                          color: Color(0xFF0F4C3A),
                                          fontWeight: FontWeight.bold,
                                          ),
                                      ),
                                  ],
                               ),
                             ),
                          );
                        },
                      ),
                    ],
                  ),
                  const Text('HEALTHCARE ACCESS COMPANION', style: TextStyle(fontSize: 9, color: Colors.grey, letterSpacing: 1.1)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Illustration Banner
            Container(
              width: double.infinity,
              height: 140,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.map_rounded, size: 64, color: Color(0xFFD0DFFF)),
                  Positioned(top: 10, left: 10, child: _badge('RSSB / RAMA Live', Icons.verified)),
                  Positioned(top: 10, right: 10, child: _badge('24/7 Verified', Icons.access_time)),
                  Positioned(bottom: 10, right: 10, child: _badge('Kigali Network', Icons.star)),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // Title & Description
            const Text(
              'Find healthcare that accepts your insurance.',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 6),
            const Text(
              'Discover nearby verified pharmacies, clinics, and hospitals in Kigali before you leave. Avoid surprise out-of-pocket costs and physical verification delays.',
              style: TextStyle(fontSize: 12.5, color: Colors.black54, height: 1.4),
            ),
            const SizedBox(height: 16),

            // Feature List Items
            _featureRow(Icons.verified_user, Colors.green, 'Instant Insurance Matching', 'RSSB, MMI, Britam, UAP & Travel policies'),
            const SizedBox(height: 8),
            _featureRow(Icons.access_time_filled, Colors.teal, 'Operating Hours & Stock Check', 'Real-time duty rosters for night pharmacies'),
            const SizedBox(height: 8),
            _featureRow(Icons.navigation, Colors.blue, 'Turn-by-Turn Navigation', 'Accurate routes across Gasabo, Kicukiro & Nyarugenge'),
            const SizedBox(height: 20),

            // Action Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Get Started', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, color: Colors.white, size: 16),
                  ],
                ),
              ),
            ),
            const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text('Skip for now', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 3)]),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: Colors.teal),
          const SizedBox(width: 3),
          Text(text, style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _featureRow(IconData icon, Color color, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade200)),
      child: Row(
        children: [
          CircleAvatar(radius: 16, backgroundColor: color.withOpacity(0.15), child: Icon(icon, color: color, size: 16)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: Colors.black87)),
                const SizedBox(height: 1),
                Text(subtitle, style: const TextStyle(fontSize: 10.5, color: Colors.black54)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}