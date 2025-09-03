class Networkutility {
  static String baseUrl =
      "https://auditrail.in/"; // Live - https://auditrail.in/  and staging - https://seekhelp.in/trail-o/
  static String login = "${baseUrl + "employee-login"}";
  static int loginApi = 1;
  static String forgotPassword = "${baseUrl + "forgot-password"}";
  static int forgotPasswordApi = 2;
  static String getCompany = "${baseUrl + "get-all-companies"}";
  static int getCompanyApi = 3;
  static String getDivisions = "${baseUrl + "get-all-divisions"}";
  static int getDivisionsApi = 4;
  static String getAllTransport = "${baseUrl + "get-all-transports"}";
  static int getAllTransportApi = 5;
  static String getCustomers = "${baseUrl + "get-all-customers"}";
  static int getCustomersApi = 6;
  static String getVendors = "${baseUrl + "get-all-vendors"}";
  static int getVendorsApi = 7;
  static String getStatus = "${baseUrl + "get-all-status"}";
  static int getStatusApi = 8;
  static String addInward = "${baseUrl + "add-inward-data"}";
  static int addInwardApi = 9;
  static String inwardList = "${baseUrl + "get-all-inward-list"}";
  static int inwardListApi = 10;
  static String getallemployee = "${baseUrl + "get-all-employee"}";
  static int getallemployeeApi = 11;
  static String storeEmployee =
      "${baseUrl + "get-all-store-department-employee"}";
  static int storeEmployeeApi = 12;
  static String deleteInward = "${baseUrl + "delete-inward-data"}";
  static int deleteInwardApi = 13;
  static String outwardList = "${baseUrl + "get-all-outward-list"}";
  static int outwardListApi = 14;
  static String deleteOutward = "${baseUrl + "delete-outward-data"}";
  static int deleteOutwardApi = 15;
  static String transforPicked = "${baseUrl + "transfer-for-picked"}";
  static int transforPickedApi = 16;
  static String pickedByList = "${baseUrl + "get-all-picked-by-outward-list"}";
  static int pickedByListApi = 17;
  static String transferChecked = "${baseUrl + "transfer-for-checked"}";
  static int transferCheckedApi = 18;
  static String checkedByList =
      "${baseUrl + "get-all-checked-by-outward-list"}";
  static int checkedByListApi = 19;
  static String transferPacked = "${baseUrl + "transfer-for-packed"}";
  static int transferPackedApi = 20;
  static String packedByList = "${baseUrl + "get-all-packed-by-outward-list"}";
  static int packedByListApi = 21;
  static String completedOrderList =
      "${baseUrl + "get-all-completed-order-list"}";
  static int completedOrderListApi = 22;
  static String getDashboardData = "${baseUrl + "get-dashboard-details"}";
  static int getDashboardDataListApi = 23;
  static String addOutward = "${baseUrl + "add-outward-data"}";
  static int addOutwardApi = 24;
  static String getSalesTeamEmployee =
      "${baseUrl + "get-all-sales-team-employee"}";
  static int getSalesTeamEmployeeApi = 25;
  static String addStockMovement = "${baseUrl + "add-stock-movement-data"}";
  static int addStockMovementApi = 26;
  static String addOutwardMovement = "${baseUrl + "add-outward-movement-data"}";
  static int addOutwardMovementApi = 27;
  static String addInwardVerification =
      "${baseUrl + "add-inward-verification-data"}";
  static int addInwardVerificationApi = 28;
  static String getNoteDetails = "${baseUrl + "credit-note-details"}";
  static int getNoteDetailsApi = 29;
  static String checkInvoiceNumber =
      "${baseUrl + "check-unique-invoice-number"}";
  static int checkInvoiceNumberApi = 30;
  static String pendingOverdueList =
      "${baseUrl + "get-all-pending-overdue-order-list"}";
  static int pendingOverdueListApi = 31;
  static String get_previlege_api = "${baseUrl + "get-previlege"}";
  static int get_previlege_apiApi = 32;
  static String checkInwardNumber = "${baseUrl + "check-unique-inward-number"}";
  static int checkInwardNumberApi = 33;
  static String checkVenderInvoiceNumber =
      "${baseUrl + "check-unique-vendor-invoice-number"}";
  static int checkVenderInvoiceNumberApi = 34;
  static String checkDebitNoteNumber =
      "${baseUrl + "check-unique-debit-note-number"}";
  static int checkDebitNoteNumberApi = 35;
  static String getCompanySales =
      "${baseUrl + "get-all-companies-of-sales-employee"}";
}
