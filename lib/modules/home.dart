import 'package:flutter/material.dart';
import 'package:my_school_app/modules/school_banner.dart';
import 'package:phone_state/phone_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? savedNumber;

  @override
  void initState() {
    super.initState();
    loadNumber();
    listenCalls();
  }

  Future<void> loadNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      savedNumber = prefs.getString("phone");
    });
  }

  bool isSameNumber(String a, String b) {
    String normalize(String num) {
      return num.replaceAll(RegExp(r'\D'), '') // remove non-digits
          .replaceAll(RegExp(r'^91'), ''); // remove country code (India)
    }

    return normalize(a) == normalize(b);
  }

  void listenCalls() {
    PhoneState.stream.listen((event) {
      if (event != null && event.status == PhoneStateStatus.CALL_INCOMING) {
        print("INCOMING CALL DETECTED");

        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => SchoolBannerScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home")),
      body: Center(child: Text("Waiting for incoming call...")),
    );
  }
}
