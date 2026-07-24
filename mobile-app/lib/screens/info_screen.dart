import 'package:flutter/material.dart';

class InfoScreen extends StatefulWidget {
  const InfoScreen({super.key});

  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  int _selectedTab = 0;
  final List<String> _tabs = ['Features', 'How It Works', 'Pricing', 'FAQs', 'Contact'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1D),
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 18.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const Text(
                    'ARCHBRAIN',
                    style: TextStyle(
                      color: Color(0xFF22D3EE),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(width: 24),
                ],
              ),
            ),

            // Tab navigation
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(
                    _tabs.length,
                    (index) => Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedTab = index;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: _selectedTab == index
                                ? const Color(0xFF22D3EE).withValues(alpha: 0.15)
                                : const Color(0xFF111827),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _selectedTab == index
                                  ? const Color(0xFF22D3EE)
                                  : Colors.white12,
                              width: _selectedTab == index ? 1.5 : 1.0,
                            ),
                          ),
                          child: Text(
                            _tabs[index],
                            style: TextStyle(
                              color: _selectedTab == index
                                  ? const Color(0xFF22D3EE)
                                  : Colors.white70,
                              fontSize: 12,
                              fontWeight: _selectedTab == index ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Content area
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_selectedTab == 0) _buildFeaturesTab(),
                    if (_selectedTab == 1) _buildHowItWorksTab(),
                    if (_selectedTab == 2) _buildPricingTab(),
                    if (_selectedTab == 3) _buildFAQsTab(),
                    if (_selectedTab == 4) _buildContactTab(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesTab() {
    final features = [
      {
        'icon': Icons.phone_iphone,
        'title': 'Device Tracking',
        'description': 'Real-time GPS tracking of your registered devices with pinpoint accuracy and location history.',
      },
      {
        'icon': Icons.lock_outline,
        'title': 'Remote Lock',
        'description': 'Instantly lock your device remotely to prevent unauthorized access in case of theft.',
      },
      {
        'icon': Icons.delete_outline,
        'title': 'Remote Wipe',
        'description': 'Securely erase all personal data from your device remotely with a single command.',
      },
      {
        'icon': Icons.notifications_active_outlined,
        'title': 'Instant Alerts',
        'description': 'Receive real-time notifications when your device is reported as stolen or compromised.',
      },
      {
        'icon': Icons.shield_outlined,
        'title': 'IMEI Protection',
        'description': 'Register your device IMEI for maximum protection and official ownership verification.',
      },
      {
        'icon': Icons.history_outlined,
        'title': 'Location History',
        'description': 'Access complete location history and movement patterns of your registered devices.',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Powerful Features for Device Protection',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Everything you need to protect, track, and recover your smartphones',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 13,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        ...features.map((feature) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF111827),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF22D3EE).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      feature['icon'] as IconData,
                      color: const Color(0xFF22D3EE),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          feature['title'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          feature['description'] as String,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildHowItWorksTab() {
    final steps = [
      {
        'number': '1',
        'title': 'Download & Register',
        'description': 'Download the ARCHBRAIN app and create your secure account with email or phone number.',
      },
      {
        'number': '2',
        'title': 'Add Your Device',
        'description': 'Register your smartphone by entering its IMEI number (dial *#06# to find it instantly).',
      },
      {
        'number': '3',
        'title': 'Enable Tracking',
        'description': 'Grant location permissions and enable GPS tracking for real-time device monitoring.',
      },
      {
        'number': '4',
        'title': 'Stay Protected',
        'description': 'Your device is now protected. Track it, lock it, or wipe it remotely anytime.',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'How It Works',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Get started in 4 simple steps',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 24),
        ...steps.asMap().entries.map((entry) {
          final idx = entry.key;
          final step = entry.value;
          final isLast = idx == steps.length - 1;

          return Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Color(0xFF22D3EE), Color(0xFF0EA5E9)],
                          ),
                        ),
                        child: Center(
                          child: Text(
                            step['number'] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      if (!isLast)
                        Container(
                          width: 2,
                          height: 60,
                          color: const Color(0xFF22D3EE).withValues(alpha: 0.3),
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            step['title'] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            step['description'] as String,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (!isLast) const SizedBox(height: 12),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildPricingTab() {
    final plans = [
      {
        'name': 'Free',
        'price': '₦0',
        'period': 'Forever',
        'features': [
          '1 Device Registration',
          'Basic Location Tracking',
          'Device Status Monitoring',
          'Community Support',
        ],
      },
      {
        'name': 'Pro',
        'price': '₦2,999',
        'period': '/month',
        'featured': true,
        'features': [
          '5 Device Registration',
          'Real-Time GPS Tracking',
          'Remote Lock & Wipe',
          'Location History (30 days)',
          'Priority Email Support',
          'Instant Alerts',
        ],
      },
      {
        'name': 'Premium',
        'price': '₦5,999',
        'period': '/month',
        'features': [
          'Unlimited Devices',
          'Real-Time GPS Tracking',
          'Remote Lock & Wipe',
          'Location History (1 year)',
          '24/7 Phone Support',
          'Instant Alerts',
          'Advanced Analytics',
          'Family Sharing',
        ],
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pricing Plans',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Choose the plan that fits your needs',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 24),
        ...plans.map((plan) {
          final isFeatured = plan['featured'] as bool? ?? false;

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF111827),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isFeatured ? const Color(0xFF22D3EE) : Colors.white12,
                  width: isFeatured ? 2 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isFeatured)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF22D3EE).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'MOST POPULAR',
                        style: TextStyle(
                          color: Color(0xFF22D3EE),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Text(
                    plan['name'] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        plan['price'] as String,
                        style: const TextStyle(
                          color: Color(0xFF22D3EE),
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        plan['period'] as String,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  ...(plan['features'] as List<String>).map((feature) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Color(0xFF10B981),
                            size: 16,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            feature,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isFeatured
                            ? const Color(0xFF22D3EE)
                            : const Color(0xFF22D3EE).withValues(alpha: 0.1),
                        foregroundColor: isFeatured ? Colors.black : const Color(0xFF22D3EE),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${plan['name']} plan selected'),
                          ),
                        );
                      },
                      child: Text(
                        'Choose Plan',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isFeatured ? Colors.black : const Color(0xFF22D3EE),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildFAQsTab() {
    final faqs = [
      {
        'q': 'What is ARCHBRAIN?',
        'a': 'ARCHBRAIN is a comprehensive mobile device protection and tracking service that helps you locate, lock, and manage your smartphones remotely.',
      },
      {
        'q': 'How do I register my device?',
        'a': 'Simply dial *#06# on your phone to find your IMEI number, then enter it in the ARCHBRAIN app to register your device.',
      },
      {
        'q': 'Is my location data secure?',
        'a': 'Yes! All data is encrypted end-to-end and stored securely on our servers. Your privacy is our top priority.',
      },
      {
        'q': 'Can I track multiple devices?',
        'a': 'Absolutely! Free plan allows 1 device, Pro allows 5 devices, and Premium allows unlimited devices.',
      },
      {
        'q': 'What happens if my device is stolen?',
        'a': 'You can immediately lock your device and report it. ARCHBRAIN will help track its location and you can contact local authorities.',
      },
      {
        'q': 'How accurate is the tracking?',
        'a': 'GPS tracking is accurate to within 5-12 meters under normal conditions. Accuracy may vary based on GPS signal strength.',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Frequently Asked Questions',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        ...faqs.map((faq) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF111827),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF22D3EE), width: 1.5),
                        ),
                        child: const Center(
                          child: Text(
                            '?',
                            style: TextStyle(
                              color: Color(0xFF22D3EE),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          faq['q'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(left: 36),
                    child: Text(
                      faq['a'] as String,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildContactTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Get in Touch',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Have questions? We\'re here to help',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 24),

        // Contact methods
        _buildContactMethod(
          icon: Icons.email_outlined,
          title: 'Email',
          value: 'support@archbrain.ng',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Email copied to clipboard')),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildContactMethod(
          icon: Icons.phone_outlined,
          title: 'Phone',
          value: '+234 (0) 810 234 5678',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Phone number copied to clipboard')),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildContactMethod(
          icon: Icons.language_outlined,
          title: 'Website',
          value: 'www.archbrain.ng',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Website link copied to clipboard')),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildContactMethod(
          icon: Icons.location_on_outlined,
          title: 'Address',
          value: '12 Broad Street, Lagos Island, Lagos 101001',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Address copied to clipboard')),
            );
          },
        ),
        const SizedBox(height: 28),

        // Social media section
        const Text(
          'Follow Us',
          style: TextStyle(
            color: Color(0xFF22D3EE),
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildSocialButton('Twitter', Icons.tag),
            const SizedBox(width: 12),
            _buildSocialButton('Instagram', Icons.photo_camera_outlined),
            const SizedBox(width: 12),
            _buildSocialButton('LinkedIn', Icons.business_center_outlined),
            const SizedBox(width: 12),
            _buildSocialButton('Facebook', Icons.people_outlined),
          ],
        ),
        const SizedBox(height: 28),

        // Message form
        const Text(
          'Send us a Message',
          style: TextStyle(
            color: Color(0xFF22D3EE),
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF111827),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white12),
          ),
          child: const TextField(
            maxLines: 4,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Your message...',
              hintStyle: TextStyle(color: Colors.white38),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF22D3EE),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Message sent! We\'ll reply soon.')),
              );
            },
            child: const Text(
              'Send Message',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactMethod({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF22D3EE).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF22D3EE), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white38),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton(String label, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF22D3EE), size: 18),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
