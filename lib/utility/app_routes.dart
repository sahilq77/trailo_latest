import 'package:get/get.dart';
import 'package:trailo/binding/inward/inward_binding.dart';
import 'package:trailo/binding/outward/checked_by_outward_binding.dart';
import 'package:trailo/binding/outward/completed_order_binding.dart';
import 'package:trailo/binding/outward/outward_list_binding.dart';
import 'package:trailo/binding/outward/packed_by_outward_binding.dart';
import 'package:trailo/binding/outward/picked_by_outward_binding.dart';
import 'package:trailo/utility/customdesign/nointernetconnectionpage.dart';
import 'package:trailo/view/customer_view/login/customer_login_screen.dart';
import 'package:trailo/view/inward/add_inward_screen.dart';
import 'package:trailo/view/inward/inward_detail_screen.dart';
import 'package:trailo/view/inward/inward_list.dart';
import 'package:trailo/view/inward/inward_verification_screen.dart';
import 'package:trailo/view/login/login_screen.dart';
import 'package:trailo/view/outward/add_outward_screen.dart';
import 'package:trailo/view/outward/checked_by_outward/checked_by_outward_detail.dart';
import 'package:trailo/view/outward/checked_by_outward/checked_by_outward_screen.dart';
import 'package:trailo/view/outward/completed_order/completed_order_detail.dart';
import 'package:trailo/view/outward/completed_order/completed_order_list.dart';
import 'package:trailo/view/outward/outward_list_screen.dart';
import 'package:trailo/view/outward/packed_by_outward/outward_movement_form.dart';
import 'package:trailo/view/outward/packed_by_outward/packed_by_outward_screen.dart';
import 'package:trailo/view/outward/picked_by_outward/picked_by_outward_detail.dart';
import 'package:trailo/view/outward/picked_by_outward/picked_by_outward_screen.dart';
import 'package:trailo/view/outward/receipt_form.dart';
import 'package:trailo/view/report/pending_overdue_screen.dart';
import 'package:trailo/view/signup/signup_screen.dart';
import 'package:trailo/view/view_pdf/view_pdf_screen.dart';
import 'package:trailo/view/welcome/welcome_screen.dart';

import '../view/customer_view/home/customer_home_screen.dart';
import '../view/forgot_password/enter_new_password_screen.dart';
import '../view/forgot_password/forgot_password_screen.dart';
import '../view/home/home_screen.dart';
import '../view/inward/edit_inward_screen.dart';
import '../view/inward/view_notes_screen.dart';
import '../view/outward/edit_outward_screen.dart';
import '../view/outward/outward_detail_screen.dart';
import '../view/outward/packed_by_outward/packed_by_outward_detail.dart';
import '../view/outward/packed_by_outward/stock_movement_form.dart';
import '../view/report/overdue_details.dart';
import '../view/splash/splash_screen.dart';
import '../view/view_image/view_images_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String forgotpassword = '/forgotpassword';
  static const String newspassword = '/newpassword';
  static const String home = '/home';
  static const String addinward = '/addinward';
  static const String inwardlist = '/inwardlist';
  static const String inwarddetail = '/inwarddetail';
  static const String inwardverification = '/inward_vrification';
  static const String addoutward = '/add_outward';
  static const String outwardList = '/outward_list';
  static const String outwarddetail = '/outward_detail';
  static const String pickedbyoutward = '/pickedby_outward';
  static const String pickedbyoutwarddetail = '/pickedby_outward_detail';
  static const String checkedbyoutward = '/checkedby_outward';
  static const String checkedbyoutwarddetail = '/checkedby_outward_detail';
  static const String receiptform = '/receipt_form';
  static const String packedbyoutward = '/packedby_outward';
  static const String packedbyoutwarddetail = '/packedby_outward_detail';
  static const String stockmovement = '/stock_movement';
  static const String outwardmovement = '/outward_movement_form';
  static const String completedorderlist = '/completed_order_list';
  static const String completedorderdetail = '/completed_order_detail';
  static const String noInternet = '/nointernet';
  static const String viewpdf = '/view_pdf';
  static const String editOutward = '/edit_outward';
  static const String viewImage = '/view_image';
  static const String viewNote = '/view_note';
  static const String pendingOverdue = '/pending_overdue';
  static const String overdueDetails = '/pending_overdue_details';
  static const String editInward = '/edit_inward';
  //customer screens
  static const String customerLogin = '/customer_login';
 static const String customerHome = '/customer_home';
  
  static final routes = [
    GetPage(
      name: splash,
      page: () => SplashScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: login,
      page: () => LoginScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: welcome,
      page: () => WelcomeScreen(),
      transition: Transition.fadeIn,
    ),

    GetPage(
      name: forgotpassword,
      page: () => ForgotPasswordScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: newspassword,
      page: () => EnterNewPasswordScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: home,
      page: () => HomeScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: addinward,
      page: () => AddInwardScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: inwardlist,
      page: () => InwardListScreen(),
      binding: InwardBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: inwarddetail,
      page: () => InwardDetailScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: inwardverification,
      page: () => InwardVerificationScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: addoutward,
      page: () => AddOutwardScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: outwardList,
      page: () => OutwardListScreen(),
      binding: OutwardListBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: outwarddetail,
      page: () => OutwardDetailScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: pickedbyoutward,
      page: () => PickedByOutwardScreen(),
      binding: PickedByOutwardBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: pickedbyoutwarddetail,
      page: () => PickedByOutwardDetail(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: checkedbyoutward,
      page: () => CheckedByOutwardScreen(),
      binding: CheckedByOutwardBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: checkedbyoutwarddetail,
      page: () => CheckedByOutwardDetail(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: receiptform,
      page: () => ReceiptForm(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: packedbyoutward,
      page: () => PackedByOutwardScreen(),
      binding: PackedByOutwardBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: packedbyoutwarddetail,
      page: () => PackedByOutwardDetailScreen(),
      binding: CompletedOrderBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: stockmovement,
      page: () => StockMovementForm(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: outwardmovement,
      page: () => OutwardMovementForm(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: completedorderlist,
      page: () => CompletedOrderList(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: completedorderdetail,
      page: () => CompletedOrderDetail(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: noInternet,
      page: () => NoInternetPage(),
      transition: Transition.fadeIn,
    ),

    GetPage(
      name: viewpdf,
      page: () => ViewResultScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: editOutward,
      page: () => EditOutwardScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: viewImage,
      page: () => ViewImagesScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: viewNote,
      page: () => ViewNoteTable(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: pendingOverdue,
      page: () => PendingOverdueScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: overdueDetails,
      page: () => PendingOverdueDetail(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: editInward,
      page: () => EditInwardScreen(),
      transition: Transition.fadeIn,
    ),
    //Customer screens
    GetPage(
      name: customerLogin,
      page: () => CustomerLoginScreen(),
      transition: Transition.fadeIn,
    ),
  GetPage(
      name: customerHome,
      page: () => CustomerHomeScreen(),
      transition: Transition.fadeIn,
    ),
    
  ];
}
