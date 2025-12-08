import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:money_mate/controllers/controllers.dart';
import 'package:money_mate/core/api/api_consumer.dart';
import 'package:money_mate/core/api/end_point.dart';
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

  login() async {
    try {
      final response = await api.post(
        EndPoint.login,
        data: {
          ApiKey.email: Controllers.emailController.text,
          ApiKey.password: Controllers.passwordController.text,
        },
      );
      userModel = UserModel.fromJson(response);

      UserModel.currentUser = userModel;
    } on ServerException catch (e) {
      log(e.toString());
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

    return response;
  }

  Future<Map<String, dynamic>> getCustomerStats({
    required String period,
    required String token,
  }) async {
    final response = await api.get(
      "${EndPoint.customerStats}$period",
      headers: {"Authorization": token},
    );

    return response;
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
