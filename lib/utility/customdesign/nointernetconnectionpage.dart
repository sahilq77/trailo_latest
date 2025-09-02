import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trailo/utility/app_colors.dart';
import 'connctivityservice.dart';

class NoInternetPage extends StatefulWidget {
  const NoInternetPage({super.key});

  @override
  State<NoInternetPage> createState() => _NoInternetPageState();
}

class _NoInternetPageState extends State<NoInternetPage> {
  StreamSubscription<bool>? _connectivitySubscription;
  final ConnectivityService _connectivityService =
      Get.find<ConnectivityService>();
  bool _isRetrying = false;

  @override
  void initState() {
    super.initState();
    _connectivitySubscription = _connectivityService.connectionStatus.listen((
      isConnected,
    ) {
      if (isConnected && mounted) {
        _handleReconnect();
      }
    });
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  Future<void> _handleReconnect() async {
    if (!mounted) {
      print('Widget is not mounted');
      return;
    }
    final isConnected = await _connectivityService.checkConnectivity();
    if (isConnected && mounted && Navigator.canPop(context)) {
      print('Popping navigator');
      Get.back();
      Get.snackbar(
        'Connection Restored',
        'Internet connection is back online.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } else {
      print('Cannot pop navigator or not connected');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool? shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              'Exit App',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            content: Text(
              'No internet connection. Are you sure you want to exit the app?',
              style: GoogleFonts.poppins(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.poppins(color: AppColors.primary),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  'Exit',
                  style: GoogleFonts.poppins(color: Colors.red),
                ),
              ),
            ],
          ),
        );
        return shouldExit ?? false;
      },
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Image.asset(
                //   AppImages.logoP, // Replace with valid asset path
                //   height: 280,
                //   width: 280,
                // ),
                const SizedBox(height: 20),
                Text(
                  'No Internet Connection',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  'Please check your internet connection\nand try again',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 25),
                ElevatedButton(
                  onPressed: _isRetrying
                      ? null
                      : () async {
                          setState(() => _isRetrying = true);
                          final isConnected = await _connectivityService
                              .checkConnectivity();
                          if (isConnected && mounted) {
                            await _handleReconnect();
                          } else {
                            Get.snackbar(
                              'No Connection',
                              'Still no internet. Please try again.',
                              snackPosition: SnackPosition.TOP,
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                              duration: const Duration(seconds: 3),
                            );
                          }
                          if (mounted) setState(() => _isRetrying = false);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isRetrying
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Retry',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
