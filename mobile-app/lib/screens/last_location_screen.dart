import 'package:flutter/material.dart';

class LastLocationScreen extends StatefulWidget {
  const LastLocationScreen({super.key});

  @override
  State<LastLocationScreen> createState() => _LastLocationScreenState();
}

class _LastLocationScreenState extends State<LastLocationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1D),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with back button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const Text(
                    'Location',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF22D3EE).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF22D3EE), width: 1),
                    ),
                    child: const Text(
                      'JD • ACTIVE',
                      style: TextStyle(
                        color: Color(0xFF22D3EE),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Tab buttons
              Row(
                children: [
                  Expanded(
                    child: _buildTabButton('Last Location', true),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, '/live-location');
                      },
                      child: _buildTabButton('Live Location', false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Map container (placeholder)
              Container(
                height: 250,
                decoration: BoxDecoration(
                  color: const Color(0xFF111827),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12),
                ),
                child: Stack(
                  children: [
                    // Map placeholder
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.map_outlined,
                              size: 48,
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Last Known',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.4),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Location marker
                    Center(
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF22D3EE).withValues(alpha: 0.3),
                          border: Border.all(color: const Color(0xFF22D3EE), width: 2),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.location_on,
                            color: Color(0xFF22D3EE),
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Last recorded info
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.history, size: 14, color: Colors.white54),
                    SizedBox(width: 8),
                    Text(
                      'Last recorded: Today 08:23 AM',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Coordinates section
              const Text(
                'COORDINATES',
                style: TextStyle(
                  color: Color(0xFF22D3EE),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
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
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '6.4541° N',
                      style: TextStyle(
                        color: Color(0xFF22D3EE),
                        fontSize: 13,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '3.3049° E',
                      style: TextStyle(
                        color: Color(0xFF22D3EE),
                        fontSize: 13,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Details section
              _buildLocationDetailRow('ADDRESS', '12 Broad St, Lagos Island, Nigeria'),
              _buildLocationDetailRow('RECORDED', '08:23 AM, Jul 14 2026'),
              _buildLocationDetailRow('ACCURACY', '±12 meters'),
              _buildLocationDetailRow('SOURCE', 'GPS + Cell Tower'),
              const SizedBox(height: 24),

              // Device info
              _buildLocationDetailRow('DEVICE', 'Samsung Galaxy S23 Ultra'),
              _buildLocationDetailRow('IMEI', '35-289184-526835-7'),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF22D3EE).withValues(alpha: 0.1) : const Color(0xFF111827),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? const Color(0xFF22D3EE) : Colors.white12,
        ),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? const Color(0xFF22D3EE) : Colors.white70,
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildLocationDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
