import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utility/app_colors.dart';
import '../../utility/app_routes.dart';
import '../../utility/app_utility.dart';

class AppSidebar extends StatelessWidget {
  const AppSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Drawer(
        backgroundColor: Colors.white,
        width: 250,
        child: Column(
          children: [
            // App title section
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Center(
                child: Text(
                  'Trailo',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            Container(
              height: 1,
              width: double.infinity,
              color: AppColors.primary,
            ),
            //  const Divider(color: AppColors.primary, thickness: 1.0),
            // Profile section using ListTile
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary.withOpacity(0.2),
                  radius: 30,
                  child: Icon(Icons.person, size: 25, color: AppColors.primary),
                ),
                title: Text(
                  "Hi, ${AppUtility.fullName}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                subtitle: Padding(
                  padding: EdgeInsets.only(top: 3),
                  child: Text(
                    AppUtility.mobileNumber! ?? "",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              height: 1,
              width: double.infinity,
              color: AppColors.primary,
            ),
            // Existing sidebar content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(top: 10),
                children: <Widget>[
                  AppUtility.hasPrivilege('add-inward') ||
                          AppUtility.hasPrivilege('inward-list')
                      ? ExpansionTile(
                          title: Text(
                            'Inward Management',
                            style: TextStyle(fontSize: 13),
                          ),
                          leading: Icon(Icons.inventory),
                          children: [
                            SizedBox(
                              child: AppUtility.hasPrivilege('add-inward')
                                  ? _buildSidebarItem(
                                      icon: Icons.add,
                                      title: 'Add Inward',
                                      onTap: () {
                                        Get.toNamed(AppRoutes.addinward);
                                      },
                                    )
                                  : SizedBox.shrink(),
                            ),
                            SizedBox(
                              child: AppUtility.hasPrivilege('inward-list')
                                  ? _buildSidebarItem(
                                      icon: Icons.list,
                                      title: 'Inward List',
                                      onTap: () {
                                        Get.toNamed(AppRoutes.inwardlist);
                                      },
                                    )
                                  : SizedBox.shrink(),
                            ),
                          ],
                        )
                      : SizedBox.shrink(),
                   AppUtility.hasPrivilege('add-outward') ||
                          AppUtility.hasPrivilege('outward-list') ||
                          AppUtility.hasPrivilege('picked-by-outward-list') ||
                          AppUtility.hasPrivilege('checked-by-outward-list') ||
                          AppUtility.hasPrivilege('packed-by-outward-list') ||
                          AppUtility.hasPrivilege('order-completed-list')
                      ?  ExpansionTile(
                    title: Text(
                      'Outward Management',
                      style: TextStyle(fontSize: 13),
                    ),
                    leading: Icon(Icons.inventory),
                    children: [
                      SizedBox(
                        child: AppUtility.hasPrivilege('add-outward')
                            ? _buildSidebarItem(
                                icon: Icons.add,
                                title: 'Add Outward',
                                onTap: () {
                                  Get.toNamed(AppRoutes.addoutward);
                                },
                              )
                            : SizedBox.shrink(),
                      ),
                      SizedBox(
                        child: AppUtility.hasPrivilege('outward-list')
                            ? _buildSidebarItem(
                                icon: Icons.list,
                                title: 'Outward List',
                                onTap: () {
                                  Get.toNamed(AppRoutes.outwardList);
                                },
                              )
                            : SizedBox.shrink(),
                      ),
                      SizedBox(
                        child: AppUtility.hasPrivilege('picked-by-outward-list')
                            ? _buildSidebarItem(
                                icon: Icons.list,
                                title: 'Picked By Outward List',
                                onTap: () {
                                  Get.toNamed(AppRoutes.pickedbyoutward);
                                },
                              )
                            : SizedBox.shrink(),
                      ),
                      SizedBox(
                        child:
                            AppUtility.hasPrivilege('checked-by-outward-list')
                            ? _buildSidebarItem(
                                icon: Icons.list,
                                title: 'Checked By Outward List',
                                onTap: () {
                                  Get.toNamed(AppRoutes.checkedbyoutward);
                                },
                              )
                            : SizedBox.shrink(),
                      ),
                      SizedBox(
                        child: AppUtility.hasPrivilege('packed-by-outward-list')
                            ? _buildSidebarItem(
                                icon: Icons.list,
                                title: 'Packed By Outward List',
                                onTap: () {
                                  Get.toNamed(AppRoutes.packedbyoutward);
                                },
                              )
                            : SizedBox.shrink(),
                      ),
                      SizedBox(
                        child: AppUtility.hasPrivilege('order-completed-list')
                            ? _buildSidebarItem(
                                icon: Icons.list,
                                title: 'Completed Order List',
                                onTap: () {
                                  Get.toNamed(AppRoutes.completedorderlist);
                                },
                              )
                            : SizedBox.shrink(),
                      ),
                    ],
                  ): SizedBox.shrink(),
                    AppUtility.hasPrivilege('pending-overdue-list')
                      ?    ExpansionTile(
                    title: Text('Reports', style: TextStyle(fontSize: 13)),
                    leading: Icon(Icons.file_copy),
                    children: [
                      SizedBox(
                        child: AppUtility.hasPrivilege('pending-overdue-list')
                            ? _buildSidebarItem(
                                icon: Icons.format_list_bulleted_sharp,
                                title: 'Pending Overdue List',
                                onTap: () {
                                  Get.toNamed(AppRoutes.pendingOverdue);
                                },
                              )
                            : SizedBox.shrink(),
                      ),
                    ],
                  ):SizedBox.shrink(),
                  _buildSidebarItem(
                    icon: Icons.logout,
                    title: 'Log Out',
                    onTap: () => _showLogoutConfirmationDialog(context),
                  ),
                ].where((child) => child != const SizedBox.shrink()).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        splashColor: Colors.blue.withOpacity(0.1),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, size: 18, color: Colors.grey.shade500),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 16),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Log Out",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              Divider(color: Colors.grey[300]),
              const SizedBox(height: 16),
              const Text(
                "Are you sure you want to Log Out?",
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        AppUtility.clearUserInfo().then((_) {
                          Get.offAllNamed(
                            AppRoutes.login,
                          ); // Navigate to login screen after logout
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: const Text(
                        'Log Out',
                        style: TextStyle(fontSize: 14, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
