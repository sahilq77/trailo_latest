import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/splash/splash_controller.dart';
import '../../utility/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // Future.delayed(Duration(seconds: 3), () {
    //   Get.offNamed(AppRoutes.welcome);
    // });
  }

  @override
  Widget build(BuildContext context) {
    Get.put(SplashController());
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Icon(Icons.medical_services, size: 100, color: AppColors.white),
      ),
    );
  }
}
