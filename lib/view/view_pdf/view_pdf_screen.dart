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
        // title: const Text('Result View'),
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
        errorWidget: (error) => Center(child: Text(error.toString())),
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
