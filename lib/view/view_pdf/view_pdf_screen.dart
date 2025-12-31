import 'package:flutter/material.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:get/get.dart';
import '../../utility/app_colors.dart';

class ViewResultScreen extends StatefulWidget {
  ViewResultScreen({super.key});

  @override
  _ViewResultScreenState createState() => _ViewResultScreenState();
}

class _ViewResultScreenState extends State<ViewResultScreen> {
  String productID = '';
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
        iconTheme: IconThemeData(color: Color(0xFF000000)),
        title: const Text(
          'File View',

          style: TextStyle(color: Color(0xFF000000)),
        ),
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(height: 1, color: Color(0xFFE5E7EB)),
        ),
      ),
      backgroundColor: AppColors.background,

      body: PDF(fitEachPage: true).fromUrl(
        pdfUrl!,
        placeholder: (progress) =>
            Center(child: CircularProgressIndicator(value: progress)),
        errorWidget: (error) {
          String errorMessage = error.toString().toLowerCase();

          if (errorMessage.contains('404')) {
            return const Center(
              child: Text('File not found', style: TextStyle(fontSize: 18)),
            );
          } else if (errorMessage.contains('403')) {
            return const Center(
              child: Text('Access denied', style: TextStyle(fontSize: 18)),
            );
          } else if (errorMessage.contains('500')) {
            return const Center(
              child: Text('Server error', style: TextStyle(fontSize: 18)),
            );
          } else if (errorMessage.contains('timeout') ||
              errorMessage.contains('connection')) {
            return const Center(
              child: Text('Connection error', style: TextStyle(fontSize: 18)),
            );
          } else if (errorMessage.contains('network')) {
            return const Center(
              child: Text('Network error', style: TextStyle(fontSize: 18)),
            );
          } else {
            return const Center(
              child: Text(
                'Unable to load file',
                style: TextStyle(fontSize: 18),
              ),
            );
          }
        },
      ),

      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // FloatingActionButton(
          //   onPressed: fetchReportPdf,
          //   heroTag: 'refresh', // Trigger refresh action
          //   child: const Icon(Icons.refresh),
          // ),
          //  const SizedBox(height: 10),
        ],
      ),
    );
  }
}
