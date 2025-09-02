import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import '../../controller/inward/view_note_controller.dart';
import '../../model/inward_list/get_view_notes_response.dart';

class ViewNoteTable extends StatefulWidget {
  const ViewNoteTable({super.key});

  @override
  State<ViewNoteTable> createState() => _ViewNoteTableState();
}

class _ViewNoteTableState extends State<ViewNoteTable> {
  final ViewNoteController controller = Get.put(ViewNoteController());
  String? id;

  @override
  void initState() {
    super.initState();
    final inwardID = Get.arguments as String;
    setState(() {
      id = inwardID;
    });
    controller.fetchNoteDetails(context: context, inwardId: id);
  }

  // Helper method to check Android version (API 33+ for READ_MEDIA_IMAGES)
  Future<bool> _isAndroid13OrAbove() async {
    if (Platform.isAndroid) {
      try {
        var androidInfo = await DeviceInfoPlugin().androidInfo;
        return androidInfo.version.sdkInt >= 33;
      } catch (e) {
        print('Error checking Android version: $e');
        return false;
      }
    }
    return false;
  }

  // Request storage-related permissions based on Android version
  Future<bool> _requestStoragePermissions() async {
    if (Platform.isAndroid) {
      bool isAndroid13OrAbove = await _isAndroid13OrAbove();
      PermissionStatus status;

      if (isAndroid13OrAbove) {
        // For Android 13+ (API 33+), request READ_MEDIA_IMAGES
        status = await Permission.photos.request();
      } else {
        // For older Android versions, request storage permission
        status = await Permission.storage.request();
      }

      if (status.isGranted) {
        return true;
      } else if (status.isPermanentlyDenied) {
        Fluttertoast.showToast(
          msg: "Please enable storage permission in settings",
          toastLength: Toast.LENGTH_LONG,
        );
        await openAppSettings();
        return false;
      } else {
        Fluttertoast.showToast(
          msg: "Storage permission denied",
          toastLength: Toast.LENGTH_LONG,
        );
        return false;
      }
    }
    return true; // No permission needed for iOS or other platforms
  }

  // Validate if the URL points to a PDF
  Future<bool> _isValidPdfUrl(String url) async {
    try {
      final response = await Dio().head(url);
      final contentType = response.headers.value('content-type');
      print('Content-Type: $contentType');
      return contentType?.contains('application/pdf') ?? false;
    } catch (e) {
      print('Error validating URL: $e');
      return false;
    }
  }

  // Download function for note files
  Future<void> _downloadNoteFile(String url, String noteId) async {
    try {
      // Validate URL
      bool isValidPdf = await _isValidPdfUrl(url);
      if (!isValidPdf) {
        Fluttertoast.showToast(
          msg: "Invalid PDF URL or file type",
          toastLength: Toast.LENGTH_LONG,
        );
        return;
      }

      // Request storage permissions
      if (!await _requestStoragePermissions()) {
        return;
      }

      // Get download directory
      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      // Create a unique filename
      String fileName =
          'note_${noteId}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      String filePath = '${directory!.path}/$fileName';

      // Download the file with binary response
      final dio = Dio();
      dio.options.connectTimeout = Duration(seconds: 10);
      dio.options.receiveTimeout = Duration(seconds: 30);
      await dio.download(
        url,
        filePath,
        options: Options(
          responseType: ResponseType.bytes, // Ensure binary response
        ),
        onReceiveProgress: (received, total) {
          if (total != -1) {
            double progress = (received / total * 100);
            Fluttertoast.showToast(
              msg: "Downloading: ${progress.toStringAsFixed(0)}%",
              toastLength: Toast.LENGTH_SHORT,
            );
          }
        },
      );

      // Verify file integrity
      File file = File(filePath);
      if (await file.exists() && await file.length() > 0) {
        print('Downloaded file size: ${await file.length()} bytes');
        Fluttertoast.showToast(
          msg: "Note downloaded to Downloads folder",
          toastLength: Toast.LENGTH_LONG,
        );

        // Open the downloaded file
        final result = await OpenFile.open(filePath);
        if (result.type != ResultType.done) {
          Fluttertoast.showToast(
            msg: "Error opening file: ${result.message}",
            toastLength: Toast.LENGTH_LONG,
          );
        }
      } else {
        Fluttertoast.showToast(
          msg: "Downloaded file is empty or corrupted",
          toastLength: Toast.LENGTH_LONG,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error downloading note: $e",
        toastLength: Toast.LENGTH_LONG,
      );
      print('Download error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Note Details',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Obx(
            () => controller.isLoading.value
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () async {
                      await controller.refreshNoteList(
                        context: context,
                        inwardId: id,
                      );
                    },
                    child: controller.noteList.isEmpty
                        ? Center(child: Text(controller.errorMessage.value))
                        : SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: SizedBox(
                              width:
                                  double.infinity, // Fit table to screen width
                              child: DataTable(
                                columnSpacing:
                                    0.0, // Reduced spacing for better fit
                                dataRowHeight: 48.0,
                                headingRowHeight: 56.0,
                                columns: [
                                  DataColumn(
                                    label: Expanded(
                                      child: Text(
                                        'Sr.No.',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Expanded(
                                      child: Text(
                                        'Note No.',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Expanded(
                                      child: Text(
                                        'Note File',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ],
                                rows: controller.noteList.asMap().entries.map((
                                  entry,
                                ) {
                                  final index = entry.key + 1;
                                  final note = entry.value;
                                  return DataRow(
                                    cells: [
                                      DataCell(
                                        Container(
                                          width: constraints.maxWidth * 0.2,
                                          alignment: Alignment.center,
                                          child: Text(
                                            index.toString(),
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Container(
                                          width: constraints.maxWidth * 0.5,
                                          alignment: Alignment.center,
                                          child: Text(
                                            note.creditNote ?? 'N/A',
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Container(
                                          width: constraints.maxWidth * 0.3,
                                          alignment: Alignment.center,
                                          child: IconButton(
                                            onPressed:
                                                note.creditNoteCopy != null &&
                                                    note
                                                        .creditNoteCopy!
                                                        .isNotEmpty
                                                ? () => _downloadNoteFile(
                                                    '${controller.url.value}${note.creditNoteCopy}',
                                                    note.creditNote ??
                                                        'note_$index',
                                                  )
                                                : null,
                                            icon: const Icon(
                                              Icons.file_download,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                  ),
          );
        },
      ),
    );
  }
}
