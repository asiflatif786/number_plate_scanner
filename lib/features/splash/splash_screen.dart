import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'splash_viewmodel.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _logoFade;
  late final Animation<Offset> _taglineSlide;
  late final Animation<double> _progressFade;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _logoFade = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );

    _taglineSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.3, 0.9, curve: Curves.easeOut),
    ));

    _progressFade = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
    );

    _animController.forward();

    _startSessionCheck();
  }

  Future<void> _startSessionCheck() async {
    final viewmodel = context.read<SplashViewModel>();
    viewmodel.checkSession();

    await Future.delayed(const Duration(milliseconds: 2500));

    await _animController.reverse();
    if (!mounted) return;

    final decision = viewmodel.routeDecision;
    if (decision != null) {
      Navigator.pushReplacementNamed(context, decision);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
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
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A237E), Color(0xFF0D1642)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 3),
              // Logo + Name + Tagline
              FadeTransition(
                opacity: _logoFade,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildLogo(),
                    const SizedBox(height: 20),
                    const Text(
                      'Consolidated Haulage Levy',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SlideTransition(
                      position: _taglineSlide,
                      child: const Text(
                        'Transaction Management System',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 2),
              // Progress indicator
              FadeTransition(
                opacity: _progressFade,
                child: const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                  ),
                ),
              ),
              const Spacer(flex: 3),
              // Bottom section
              Consumer<SplashViewModel>(
                builder: (_, vm, __) {
                  if (!vm.isLoading && vm.routeDecision != null) {
                    return const SizedBox.shrink();
                  }
                  return const SizedBox(
                    width: 24,
                    height: 24,
                  );
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'v1.0.0',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white38,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Powered by Cyber1 Systems',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white24,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Image.asset(
      'assets/images/logo.png',
      width: 100,
      height: 100,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text(
            'CHL',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A237E),
            ),
          ),
        ),
      ),
    );
  }
}
