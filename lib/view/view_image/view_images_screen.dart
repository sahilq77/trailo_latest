import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';

import '../../utility/app_colors.dart';

class ViewImagesScreen extends StatefulWidget {
  const ViewImagesScreen({super.key});

  @override
  State<ViewImagesScreen> createState() => _ViewImagesScreenState();
}

class _ViewImagesScreenState extends State<ViewImagesScreen> {
  String? pdfUrl; // To store the receipt URL
  bool isLoading = true; // To manage API loading state

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    final url = args as String?;
    pdfUrl = url;
    print("url $url");
  }

  @override
  Widget build(BuildContext context) {
    print("url $pdfUrl");
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        automaticallyImplyLeading: true,
        // title: const Text(''),
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(height: 1, color: Color(0xFFE5E7EB)),
        ),
      ),
      backgroundColor: AppColors.background,

      body: SingleChildScrollView(
        child: Column(
          children: [
            CachedNetworkImage(
              imageUrl: pdfUrl.toString(),
              // fit: BoxFit.cover,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              placeholder: (context, url) =>
                  const Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) => const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, color: Colors.red, size: 48),
                  SizedBox(height: 8),
                  Text(
                    'Failed to load image',
                    style: TextStyle(fontSize: 16, color: Colors.red),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
