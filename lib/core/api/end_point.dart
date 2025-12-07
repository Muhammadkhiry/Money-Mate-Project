class EndPoint {
  static String baseURL = "http://10.0.2.2:3000/api/";
  static String register = "auth/register";
  static String login = "auth/login";
  static String addBill = "bills/add";
  static String customerBills = "bills/customer/";
  static String companyStats = "stats/company/";
  static String customerStats = "stats/customer/";
  // TODO: لسه ال get , patch
}

class ApiKey {
  static String username = "username";
  static String password = "password";
  static String email = "email";
  static String phone = "phone";
  static String user_address = "user_address";
  static String user_type = "user_type";
  static String gender = "gender";
  static String salary = "salary";

  static String bill_id = "bill_id";
  static String bill_amount = "bill_amount";
  static String bill_status = "bill_status";
  static String created_at = "created_at";
  static String customer_name = "customer_name";
}
