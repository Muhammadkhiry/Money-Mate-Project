import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'http://192.168.11.60:3000';

  // ==========================
  // LOGIN
  // ==========================
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }

  // ==========================
  // GET BILLS FOR COMPANY
  // ==========================
  Future<List<dynamic>> getCompanyBills(int companyId, {String? status}) async {
    String url = '$baseUrl/bills/company/$companyId';
    if (status != null) {
      url += '?status=$status'; // paid / unpaid
    }
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200)
      return jsonDecode(response.body);
    else
      throw Exception('Failed to load company bills');
  }

  // ==========================
  // GET BILLS FOR CUSTOMER
  // ==========================
  Future<List<dynamic>> getCustomerBills(
    int customerId, {
    String? status,
  }) async {
    String url = '$baseUrl/bills/customer/$customerId';
    if (status != null) {
      url += '?status=$status';
    }
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200)
      return jsonDecode(response.body);
    else
      throw Exception('Failed to load customer bills');
  }

  // ==========================
  // ADD BILL
  // ==========================
  Future<void> addBill({
    required int customerId,
    required int companyId,
    required int amount,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/addBill'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'bill_amount': amount,
        'customer_id': customerId,
        'company_id': companyId,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add bill: ${response.body}');
    }
  }

  // ==========================
  // PAY BILL
  // ==========================
  Future<void> payBill(int billId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/payBill'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'bill_id': billId}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to pay bill: ${response.body}');
    }
  }
}
