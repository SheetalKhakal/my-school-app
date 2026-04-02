import 'package:flutter/material.dart';
import 'package:my_school_app/views/home.dart';
import 'package:my_school_app/views/login.dart';
import 'package:my_school_app/views/call_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

//Notification plugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Entry point for overlay
@pragma("vm:entry-point")
void overlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const OverlayApp());
}

Future<void> initNotifications() async {
  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings settings = InitializationSettings(
    android: androidSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(
    settings,
    onDidReceiveNotificationResponse: (response) {
      final schoolName = response.payload ?? 'My School';

      navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (_) => CallScreen(schoolName: schoolName)),
      );
    },
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initNotifications();
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
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: true,
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

/// Overlay App
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
      body: Center(
        child: Text(
          schoolName,
          style: const TextStyle(fontSize: 24, color: Colors.black),
        ),
      ),
    );
  }
}
