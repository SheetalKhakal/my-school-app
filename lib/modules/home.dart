import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_school_app/main.dart';
import 'package:my_school_app/modules/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:phone_state/phone_state.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'call_screen.dart';

class HomeScreen extends StatefulWidget {
  final String phoneNumber;
  final String schoolName;

  const HomeScreen({
    super.key,
    required this.phoneNumber,
    required this.schoolName,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  bool _monitoringActive = false;
  String _statusText = 'Requesting permissions…';
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;
  String _lastIncomingNumber = '';
  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _initPermissions();
  }

  Future<void> _initPermissions() async {
    // 📞 Phone permission
    final phoneStatus = await Permission.phone.request();

    // 🔔 Notification permission (IMPORTANT for Android 13+)
    final notificationStatus = await Permission.notification.request();

    setState(() {
      _monitoringActive = phoneStatus.isGranted && notificationStatus.isGranted;

      _statusText = _monitoringActive
          ? 'Monitoring active'
          : 'Grant phone & notification permissions';
    });

    if (_monitoringActive) {
      _startListening();
    }
  }

  void _startListening() {
    PhoneState.stream.listen((PhoneState event) async {
      final incoming = event.number ?? '';

      // Save number when ringing
      if (event.status == PhoneStateStatus.CALL_INCOMING ||
          event.status == PhoneStateStatus.CALL_STARTED) {
        _lastIncomingNumber = incoming;
      }

      final normalized = _normalizeNumber(_lastIncomingNumber);
      final saved = _normalizeNumber(widget.phoneNumber);

      print("Saved normalized: $saved");
      print("Last incoming normalized: $normalized");

      // ✅ Trigger AFTER call ends
      if (event.status == PhoneStateStatus.CALL_ENDED) {
        if (normalized.endsWith(saved) || saved.endsWith(normalized)) {
          print("✅ CALL ENDED MATCH → SHOW OVERLAY");
          await _showCallNotification();
        }
      }
    });
  }

  String _normalizeNumber(String number) {
    number = number.replaceAll(RegExp(r'\D'), '');

    // Always take last 10 digits
    if (number.length > 10) {
      number = number.substring(number.length - 10);
    }

    return number;
  }

  Future<void> _showCallNotification() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'call_channel',
          'Call Alerts',
          channelDescription: 'School Call Alerts',
          importance: Importance.max,
          priority: Priority.high,
          fullScreenIntent: true,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      'Incoming Call',
      '${widget.schoolName} is calling you',
      notificationDetails,
      payload: widget.schoolName, // ✅ PASS DATA HERE
    );
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF151B45),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Reset Settings',
          style: GoogleFonts.nunito(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: Text(
          'This will clear the saved number and school name. Continue?',
          style: GoogleFonts.nunito(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.nunito(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Reset',
              style: GoogleFonts.nunito(
                color: const Color(0xFFEF5350),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('monitored_phone');
      await prefs.remove('school_name');

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  /// Preview the call screen (demo)
  void _previewCallScreen() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => CallScreen(schoolName: widget.schoolName),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E2A),
      body: Stack(
        children: [
          // Background blobs
          Positioned(
            top: -60,
            right: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF3949AB).withOpacity(0.35),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -50,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF1565C0).withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  // Top bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'School Call\nAlert',
                        style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                        ),
                      ),
                      IconButton(
                        onPressed: _logout,
                        icon: const Icon(
                          Icons.settings_backup_restore_rounded,
                          color: Colors.white54,
                        ),
                        tooltip: 'Reset settings',
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Status card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1A237E), Color(0xFF1565C0)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1A237E).withOpacity(0.5),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Pulsing indicator
                        ScaleTransition(
                          scale: _pulseAnim,
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _monitoringActive
                                  ? const Color(0xFF4CAF50)
                                  : const Color(0xFFEF5350),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      (_monitoringActive
                                              ? const Color(0xFF4CAF50)
                                              : const Color(0xFFEF5350))
                                          .withOpacity(0.5),
                                  blurRadius: 20,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                            child: Icon(
                              _monitoringActive
                                  ? Icons.shield_rounded
                                  : Icons.warning_rounded,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _statusText,
                          style: GoogleFonts.nunito(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _monitoringActive
                              ? 'Your app is watching for calls'
                              : 'Grant permissions to enable monitoring',
                          style: GoogleFonts.nunito(
                            color: Colors.white60,
                            fontSize: 13,
                          ),
                        ),
                        if (!_monitoringActive) ...[
                          const SizedBox(height: 14),
                          TextButton(
                            onPressed: _initPermissions,
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                            ),
                            child: Text(
                              'Retry Permissions',
                              style: GoogleFonts.nunito(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Info cards
                  _infoCard(
                    icon: Icons.school_rounded,
                    label: 'School',
                    value: widget.schoolName,
                    color: const Color(0xFF5C6BC0),
                  ),

                  const SizedBox(height: 12),

                  _infoCard(
                    icon: Icons.phone_rounded,
                    label: 'Monitored Number',
                    value: widget.phoneNumber,
                    color: const Color(0xFF1976D2),
                  ),

                  const Spacer(),

                  // Preview button
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton.icon(
                      onPressed: _previewCallScreen,
                      icon: const Icon(Icons.preview_rounded, size: 22),
                      label: Text(
                        'Preview Call Screen',
                        style: GoogleFonts.nunito(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF283593),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1535),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.nunito(
                  color: Colors.white38,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
