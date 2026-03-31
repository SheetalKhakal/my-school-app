import 'package:flutter/material.dart';
import 'package:my_school_app/modules/home.dart';
import 'package:my_school_app/modules/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

/// Entry point — also handles the overlay window entry point
@pragma("vm:entry-point")
void overlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const OverlayApp());
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Check if a phone number is already saved
  final prefs = await SharedPreferences.getInstance();
  final savedNumber = prefs.getString('monitored_phone') ?? '';
  final schoolName = prefs.getString('school_name') ?? '';

  runApp(
    SchoolCallApp(
      isLoggedIn: savedNumber.isNotEmpty && schoolName.isNotEmpty,
      savedNumber: savedNumber,
      schoolName: schoolName,
    ),
  );
}

class SchoolCallApp extends StatelessWidget {
  final bool isLoggedIn;
  final String savedNumber;
  final String schoolName;

  const SchoolCallApp({
    super.key,
    required this.isLoggedIn,
    required this.savedNumber,
    required this.schoolName,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'School Call Alert',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A237E),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: isLoggedIn
          ? HomeScreen(phoneNumber: savedNumber, schoolName: schoolName)
          : const LoginScreen(),
    );
  }
}

/// Separate app shown inside the overlay window when a call arrives
class OverlayApp extends StatelessWidget {
  const OverlayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: OverlayCallScreen(),
    );
  }
}

class OverlayCallScreen extends StatefulWidget {
  const OverlayCallScreen({super.key});

  @override
  State<OverlayCallScreen> createState() => _OverlayCallScreenState();
}

class _OverlayCallScreenState extends State<OverlayCallScreen>
    with SingleTickerProviderStateMixin {
  String schoolName = 'My School';
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _loadSchoolName();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Listen for data sent from the main app
    FlutterOverlayWindow.overlayListener.listen((data) {
      if (data != null && data is Map) {
        setState(() {
          schoolName = data['school_name'] ?? schoolName;
        });
      }
    });
  }

  Future<void> _loadSchoolName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      schoolName = prefs.getString('school_name') ?? 'My School';
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0D1B6E),
              Color(0xFF1A237E),
              Color(0xFF283593),
              Color(0xFF1565C0),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Incoming call banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                color: const Color(0xFFE53935),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.call_rounded, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'INCOMING CALL',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 3,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Animated school logo
              ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.4),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.school_rounded,
                      size: 80,
                      color: Color(0xFF1A237E),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // School name
              Text(
                schoolName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  shadows: [
                    Shadow(
                      color: Colors.black38,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'is calling you',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.5,
                ),
              ),

              const Spacer(),

              // Dismiss button
              GestureDetector(
                onTap: () => FlutterOverlayWindow.closeOverlay(),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: Colors.white38, width: 1.5),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.close_rounded, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Dismiss',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

@override
Widget build(BuildContext context) {
  return MaterialApp(debugShowCheckedModeBanner: false, home: LoginScreen());
}
