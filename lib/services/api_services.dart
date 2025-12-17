import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:money_mate/core/api/api_consumer.dart';
import 'package:money_mate/core/api/end_point.dart';
import 'package:money_mate/core/errors/error_model.dart';
import 'package:money_mate/core/errors/exceptions.dart';
import 'package:money_mate/models/bill_model.dart';
import 'package:money_mate/models/bill_response.dart';
import 'package:money_mate/models/user_model.dart';

class ApiServices {
  final ApiConsumer api;
  ApiServices({required this.api});

  BillsModel? billsModel;
  UserModel? userModel;

  Future<BillsModel?> billsView(String userType, String token) async {
    try {
      final response = await api.get(
        "/bills/$userType/",
        headers: {"Authorization": token},
      );

      // response هنا List<dynamic>
      final List<dynamic> billsList = response;

      return BillsModel(
        bills: billsList
            .map((e) => Bill.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } on DioException catch (e) {
      log(e.toString());
      return null;
    }
  }

  recentExpenses() async {}

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await api.post(
        EndPoint.login,
        data: {"email": email, "password": password},
      );

      if (response == null) {
        throw ServerException(
          errorModel: ErrorModel(errorMessage: "Network Error"),
        );
      }

      return UserModel.fromJson(response);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final data = e.response?.data;

      if (status == 404) {
        throw ServerException(
          errorModel: ErrorModel(errorMessage: "User not found"),
        );
      } else if (status == 401) {
        throw ServerException(
          errorModel: ErrorModel(errorMessage: "Incorrect password"),
        );
      } else if (status == 400) {
        throw ServerException(
          errorModel: ErrorModel(errorMessage: data["error"] ?? "Invalid data"),
        );
      }

      throw ServerException(
        errorModel: ErrorModel(errorMessage: "Network Error"),
      );
    }
  }

  Future<void> register(Map<String, dynamic> body) async {
    try {
      final response = await api.post(EndPoint.register, data: body);

      if (response == null) {
        throw ServerException(
          errorModel: ErrorModel(errorMessage: "Network error"),
        );
      }
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final data = e.response?.data;

      if (status == 400) {
        throw ServerException(
          errorModel: ErrorModel(errorMessage: data["error"] ?? "Invalid data"),
        );
      }

      throw ServerException(
        errorModel: ErrorModel(errorMessage: "Network error"),
      );
    }
  }

  Future<bool> payBill(int billId, String token) async {
    final response = await api.patch(
      '/bills/$billId/pay',
      headers: {"Authorization": token},
    );

    if (response['message'] == 'Bill paid successfully') {
      return true;
    }
    return false;
  }

  Future<BillResponse?> createBill({
    required String customerEmail,
    required int billAmount,
    required String token,
  }) async {
    try {
      final response = await api.post(
        "bills/add",
        headers: {"Authorization": token},
        data: {"customer_email": customerEmail, "bill_amount": billAmount},
      );

      return BillResponse.fromJson(response);
    } catch (e) {
      print("Error creating bill: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>> getCompanyStats({
    required String period,
    required String token,
  }) async {
    final response = await api.get(
      "${EndPoint.companyStats}$period",
      headers: {"Authorization": token},
    );

    if (response == null) {
      return {"total_paid": 0, "total_unpaid": 0, "balance": 0};
    }

    return Map<String, dynamic>.from(response);
  }

  Future<Map<String, dynamic>> getCustomerStats({
    required String period,
    required String token,
  }) async {
    final response = await api.get(
      "${EndPoint.customerStats}$period",
      headers: {"Authorization": token},
    );

    if (response == null) {
      return {"total_paid": 0, "total_unpaid": 0, "balance": 0};
    }

    return Map<String, dynamic>.from(response);
  }

  Future<List<double>> getWeeklyChart({
    required String userType,
    required String token,
  }) async {
    final response = await api.get(
      "stats/$userType/chart/weekly",
      headers: {"Authorization": token},
    );

    // ترتيب ثابت لأيام الأسبوع
    final Map<String, double> ordered = {
      "Monday": 0.0,
      "Tuesday": 0.0,
      "Wednesday": 0.0,
      "Thursday": 0.0,
      "Friday": 0.0,
      "Saturday": 0.0,
      "Sunday": 0.0,
    };

    // نعبي الداتا اللي جاية من الـ API
    for (var row in response) {
      final day = row["day_name"];
      final amount = (row["amount"] ?? 0).toDouble();

      if (ordered.containsKey(day)) {
        ordered[day] = amount;
      }
    }

    // نرجّع الأرقام بس بالترتيب (List<double>)
    return ordered.values.toList();
  }
}
