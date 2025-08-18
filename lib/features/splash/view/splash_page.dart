import 'dart:async';
import 'package:flutter/material.dart';
import 'package:z_parking/core/dio_client.dart';
import 'package:z_parking/core/locator.dart';
import 'package:z_parking/core/navigation_utils.dart';
import 'package:z_parking/features/auth/view/login_page.dart';
import 'package:z_parking/features/vehicle/view/vehicle_list_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
  static const String routeName = '/';
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _scale = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
    unawaited(_goNext());
  }

  Future<void> _goNext() async {
    await Future<void>.delayed(const Duration(milliseconds: 1400));
    final token = sl<TokenProvider>().token;
    if (!mounted) return;
    if (token != null && token.isNotEmpty) {
      NavigationUtils.pushReplacementNamed(VehicleListPage.routeName);
    } else {
      NavigationUtils.pushReplacementNamed(LoginPage.routeName);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF3949AB), Color(0xFF1E88E5)],
          ),
        ),
        child: Center(
          child: ScaleTransition(
            scale: _scale,
            child: FadeTransition(
              opacity: _fade,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.local_parking, size: 96, color: Colors.white),
                  SizedBox(height: 12),
                  Text('ZParking', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


