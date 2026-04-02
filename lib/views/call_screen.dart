import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CallScreen extends StatefulWidget {
  final String schoolName;

  const CallScreen({super.key, required this.schoolName});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late AnimationController _rippleCtrl;
  late AnimationController _bannerCtrl;
  late AnimationController _shimmerCtrl;

  late Animation<double> _pulseAnim;
  late Animation<double> _ripple1Anim;
  late Animation<double> _ripple2Anim;
  late Animation<double> _ripple3Anim;
  late Animation<Offset> _bannerAnim;
  late Animation<double> _shimmerAnim;

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(
      begin: 0.92,
      end: 1.08,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _rippleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
    _ripple1Anim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _rippleCtrl,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );
    _ripple2Anim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _rippleCtrl,
        curve: const Interval(0.2, 0.9, curve: Curves.easeOut),
      ),
    );
    _ripple3Anim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _rippleCtrl,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    _bannerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _bannerAnim = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _bannerCtrl, curve: Curves.easeOutBack));
    _bannerCtrl.forward();

    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _shimmerAnim = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(parent: _shimmerCtrl, curve: Curves.linear));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _rippleCtrl.dispose();
    _bannerCtrl.dispose();
    _shimmerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF080C22),
              Color(0xFF0D1B6E),
              Color(0xFF1A237E),
              Color(0xFF0D47A1),
            ],
            stops: [0.0, 0.3, 0.6, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Star dots background
            ...List.generate(24, (i) {
              final rand = Random(i * 137);
              final x = rand.nextDouble() * size.width;
              final y = rand.nextDouble() * size.height;
              final r = rand.nextDouble() * 2 + 1;
              return Positioned(
                left: x,
                top: y,
                child: Container(
                  width: r,
                  height: r,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(
                      0.3 + rand.nextDouble() * 0.4,
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }),

            // Top incoming call banner
            SlideTransition(
              position: _bannerAnim,
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFD32F2F), Color(0xFFE53935)],
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildBlinkingDot(),
                        const SizedBox(width: 12),
                        Text(
                          'INCOMING CALL',
                          style: GoogleFonts.nunito(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 4,
                          ),
                        ),
                        const SizedBox(width: 12),
                        _buildBlinkingDot(),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Center content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),

                  // Ripple rings + logo
                  SizedBox(
                    width: 240,
                    height: 240,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Ripple 1
                        AnimatedBuilder(
                          animation: _ripple1Anim,
                          builder: (_, __) => Opacity(
                            opacity: (1 - _ripple1Anim.value).clamp(0, 1),
                            child: Transform.scale(
                              scale: 0.5 + _ripple1Anim.value * 0.9,
                              child: Container(
                                width: 240,
                                height: 240,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFF5C6BC0),
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Ripple 2
                        AnimatedBuilder(
                          animation: _ripple2Anim,
                          builder: (_, __) => Opacity(
                            opacity: (1 - _ripple2Anim.value).clamp(0, 1),
                            child: Transform.scale(
                              scale: 0.5 + _ripple2Anim.value * 0.9,
                              child: Container(
                                width: 240,
                                height: 240,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFF3949AB),
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Ripple 3
                        AnimatedBuilder(
                          animation: _ripple3Anim,
                          builder: (_, __) => Opacity(
                            opacity: (1 - _ripple3Anim.value).clamp(0, 1),
                            child: Transform.scale(
                              scale: 0.5 + _ripple3Anim.value * 0.9,
                              child: Container(
                                width: 240,
                                height: 240,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFF1A237E),
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Logo circle
                        ScaleTransition(
                          scale: _pulseAnim,
                          child: Container(
                            width: 160,
                            height: 160,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const RadialGradient(
                                colors: [Colors.white, Color(0xFFE8EAF6)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.3),
                                  blurRadius: 40,
                                  spreadRadius: 8,
                                ),
                                BoxShadow(
                                  color: const Color(
                                    0xFF3949AB,
                                  ).withOpacity(0.4),
                                  blurRadius: 30,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 4),
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
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // School name banner with shimmer
                  AnimatedBuilder(
                    animation: _shimmerAnim,
                    builder: (_, child) {
                      return ShaderMask(
                        shaderCallback: (bounds) {
                          final shimmerX = _shimmerAnim.value;
                          return LinearGradient(
                            begin: Alignment(shimmerX - 0.5, 0),
                            end: Alignment(shimmerX + 0.5, 0),
                            colors: const [
                              Colors.white,
                              Color(0xFFE3F2FD),
                              Colors.white,
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ).createShader(bounds);
                        },
                        child: child!,
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        widget.schoolName,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 1.1,
                          letterSpacing: 0.5,
                          shadows: const [
                            Shadow(
                              color: Colors.black45,
                              blurRadius: 12,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    'is calling you',
                    style: GoogleFonts.nunito(
                      color: Colors.white60,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),

                  const SizedBox(height: 64),

                  // Dismiss button (for demo/preview)
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 36,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1E88E5), Color(0xFF3949AB)],
                        ),
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1E88E5).withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.call_end_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Dismiss Preview',
                            style: GoogleFonts.nunito(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom school banner strip
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF1A237E).withOpacity(0.95),
                      const Color(0xFF0D47A1).withOpacity(0.95),
                    ],
                  ),
                  border: const Border(
                    top: BorderSide(color: Color(0xFF3949AB), width: 1),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.school_rounded,
                        color: Colors.white60,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.schoolName.toUpperCase(),
                        style: GoogleFonts.nunito(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlinkingDot() {
    return AnimatedBuilder(
      animation: _pulseCtrl,
      builder: (_, __) => Opacity(
        opacity: _pulseCtrl.value,
        child: Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
