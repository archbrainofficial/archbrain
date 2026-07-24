import 'package:flutter/material.dart';

class LiveLocationScreen extends StatefulWidget {
  const LiveLocationScreen({super.key});

  @override
  State<LiveLocationScreen> createState() => _LiveLocationScreenState();
}

class _LiveLocationScreenState extends State<LiveLocationScreen> {
  bool _isLiveTracking = true;

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
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, '/last-location');
                      },
                      child: _buildTabButton('Last Location', false),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildTabButton('Live Location', true),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Map container with live tracking indicator
              Stack(
                children: [
                  Container(
                    height: 250,
                    decoration: BoxDecoration(
                      color: const Color(0xFF111827),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Container(
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
                              'Live Tracking Active',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.4),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Live tracking indicator
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFB5A5A).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFFB5A5A), width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFFB5A5A),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'LIVETRACKING',
                            style: TextStyle(
                              color: Color(0xFFFB5A5A),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Live location marker
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Animated pulse effect
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF22D3EE).withValues(alpha: 0.1),
                            border: Border.all(
                              color: const Color(0xFF22D3EE).withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF22D3EE).withValues(alpha: 0.2),
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
                        const SizedBox(height: 8),
                        const Text(
                          'John Doe — LIVE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
                      '6.4585° N',
                      style: TextStyle(
                        color: Color(0xFF22D3EE),
                        fontSize: 13,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '3.4835° E',
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

              // Live info grid - top row
              Row(
                children: [
                  Expanded(
                    child: _buildLiveInfoCard('ADDRESS', '42 Marina Rd, Lagos'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildLiveInfoCard('SIGNAL', 'Excellent (LTE)', isHighlight: true),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Live info grid - bottom row
              Row(
                children: [
                  Expanded(
                    child: _buildLiveInfoCard('SPEED', '34 km/h'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildLiveInfoCard('BATTERY', '71%'),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Live info grid - bottom row 2
              Row(
                children: [
                  Expanded(
                    child: _buildLiveInfoCard('DIRECTION', 'North-East'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildLiveInfoCard('UPDATED', 'Just now'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Toggle button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isLiveTracking
                        ? const Color(0xFFEF4444)
                        : const Color(0xFF22D3EE),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    setState(() {
                      _isLiveTracking = !_isLiveTracking;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          _isLiveTracking
                              ? 'Live tracking enabled'
                              : 'Live tracking disabled',
                        ),
                      ),
                    );
                  },
                  child: Text(
                    _isLiveTracking ? 'Stop Tracking' : 'Start Tracking',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
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

  Widget _buildLiveInfoCard(String label, String value, {bool isHighlight = false}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHighlight ? const Color(0xFF22D3EE) : Colors.white12,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 10,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: isHighlight ? const Color(0xFF22D3EE) : Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
