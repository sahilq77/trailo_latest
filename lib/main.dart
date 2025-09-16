import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trailo/controller/global_controller/company/company_controller.dart';
import 'package:trailo/controller/global_controller/division/divsion_controller.dart';
import 'package:trailo/controller/global_controller/employee/employee_controller.dart';
import 'package:trailo/controller/global_controller/sales_team/sales_team_employee_controller.dart';
import 'package:trailo/controller/global_controller/status/status_controller.dart';
import 'package:trailo/utility/app_colors.dart';
import 'package:trailo/utility/app_routes.dart';
import 'package:trailo/utility/customdesign/connctivityservice.dart';

import 'controller/global_controller/customers/customer_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Initialize binding
  Get.put(ConnectivityService(), permanent: true);
  Get.lazyPut<CompanyController>(() => CompanyController(), fenix: true);
  Get.lazyPut<DivsionController>(() => DivsionController(), fenix: true);
  Get.lazyPut<CustomerController>(() => CustomerController(), fenix: true);
  Get.lazyPut<StatusController>(() => StatusController(), fenix: true);
  Get.lazyPut<EmployeeController>(() => EmployeeController(), fenix: true);
  Get.lazyPut<SalesTeamEmployeeController>(
    () => SalesTeamEmployeeController(),
    fenix: true,
  );
  Get.lazyPut<StatusController>(() => StatusController(), fenix: true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Trailo',
      theme: ThemeData(
        textSelectionTheme: TextSelectionThemeData(
          selectionHandleColor: AppColors.primary,
        ),
        scaffoldBackgroundColor: AppColors.background,
        primaryColor: AppColors.primary,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.background,
          primary: AppColors.primary,
        ),
        appBarTheme: const AppBarTheme(
          scrolledUnderElevation: 0.0,
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.defaultblack,
          iconTheme: IconThemeData(color: AppColors.white),
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: AppColors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          elevation: 0,
        ),

        iconTheme: const IconThemeData(color: AppColors.primary),
        fontFamily: GoogleFonts.poppins().fontFamily,
        textTheme: GoogleFonts.poppinsTextTheme().copyWith(
          bodyMedium: const TextStyle(
            fontSize: 16,
            color: AppColors.defaultblack,
          ),

          headlineSmall: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.defaultblack,
          ),
          bodyLarge: const TextStyle(color: AppColors.defaultblack),
          bodySmall: const TextStyle(color: AppColors.defaultblack),
          headlineLarge: const TextStyle(color: AppColors.defaultblack),
          headlineMedium: const TextStyle(color: AppColors.defaultblack),
          titleLarge: const TextStyle(color: AppColors.defaultblack),
          titleMedium: const TextStyle(color: AppColors.defaultblack),
          titleSmall: const TextStyle(color: AppColors.defaultblack),
          labelLarge: const TextStyle(color: AppColors.defaultblack),
          labelMedium: const TextStyle(color: AppColors.defaultblack),
          labelSmall: const TextStyle(color: AppColors.defaultblack),
        ),

        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            borderSide: BorderSide(color: AppColors.grey),
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            borderSide: BorderSide(color: AppColors.textfieldBorderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            borderSide: BorderSide(color: AppColors.primary),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            borderSide: BorderSide(color: AppColors.error),
          ),
          prefixIconColor: AppColors.primary,
          labelStyle: TextStyle(color: AppColors.grey),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            // backgroundColor: AppColors.primary, // Uncomment if needed
            // foregroundColor: Colors.white, // Uncomment if needed
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadiusGeometry.circular(8),
            ),
            side: const BorderSide(
              color: Colors.black, // Define border color
              width: 1.0, // Define border width
            ),
            minimumSize: const Size(double.infinity, 0),
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            minimumSize: const Size(double.infinity, 0),
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            // borderRadius: BorderRadius.circular(8.0),
            side: const BorderSide(color: AppColors.borderColor),
          ),
          // margin: const EdgeInsets.all(8),
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: AppColors.primary,
        ),
      ),
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.routes,
      //  home: InwardListScreen(),
      builder: (context, child) {
        return ColorfulSafeArea(
          color: AppColors.primary, // Matches AppBar background color
          top: true,
          bottom: true, // Only apply SafeArea to top for AppBar
          left: false,
          right: false,
          child: child ?? Container(),
        );
      },
    );
  }
}
