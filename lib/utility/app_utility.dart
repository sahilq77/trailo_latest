import 'dart:convert';
import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';

//created by sahil
class AppUtility {
  static String? userID;
  static String? fullName;
  static String? mobileNumber;
  static String? userType; //user_type=1for and  user_type=2 for sales employee
  static bool isLoggedIn = false;
  static bool isAdmin = false;
  static List<String> privileges = [];

  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    if (isLoggedIn) {
      fullName = prefs.getString('full_name');
      mobileNumber = prefs.getString('mobile_number');
      userType = prefs.getString('user_type');
      // profileImage = prefs.getString('profile_image');
      userID = prefs.getString('login_user_id');
      isAdmin = prefs.getBool('is_admin') ?? false;
      final privilegesString = prefs.getString('privileges');
      if (privilegesString != null) {
        privileges = List<String>.from(jsonDecode(privilegesString));
      }
      log(
        'AppUtility initialized - ID: $userID, isAdmin: $isAdmin, privileges: $privileges',
      );
    }
  }

  static Future<void> setUserInfo(
    String name,
    String mobile,
    String usertype, // 0= student ,1= open
    //   String profile,
    String userid,
    bool adminStatus,
    List<String> userPrivileges,
  ) async {
    final privilegesToSave = userPrivileges.isEmpty
        ? ['dashboard']
        : userPrivileges;
    if (userPrivileges.isEmpty) {
      log('No privileges provided, setting default privilege: [dashboard]');
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('full_name', name);
    await prefs.setString('mobile_number', mobile);
    await prefs.setString('user_type', usertype);
    await prefs.setString('login_user_id', userid);
    await prefs.setBool('is_admin', adminStatus);
    await prefs.setString('privileges', jsonEncode(privilegesToSave));
    fullName = name;
    mobileNumber = mobile;
    userID = userid;
    userType = usertype;
    isAdmin = adminStatus;
    privileges = privilegesToSave;
    // profileImage = profile;
    userID = userid;
    // AppUtility.u = userId;
    isLoggedIn = true;
    log("User ID $userID");
    log(
      'AppUtility initialized - ID: $userID, isAdmin: $isAdmin, privileges: $privileges',
    );
    log("User Type $userType");
  }

  static Future<void> updatePrivileges(List<String> userPrivileges) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('privileges', jsonEncode(userPrivileges));
    privileges = userPrivileges;
    log('Privileges updated: $userPrivileges');
  }

  static Future<void> clearUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // fullName = null;
    // mobileNumber = null;
    // userType = null;
    // profileImage = null;
    isAdmin = false;
    privileges = [];
    userID = null;
    userType = null;
    isLoggedIn = false;
  }

  static bool hasPrivilege(String module) {
    if (isAdmin) {
      log('Admin access: Full privileges granted for $module');
      return true;
    }
    final hasAccess = privileges.contains(module);
    log('Checking privilege for $module: $hasAccess');
    return hasAccess;
  }
}
