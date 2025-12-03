import 'dart:developer';

import 'package:money_mate/controllers/controllers.dart';
import 'package:money_mate/core/api/api_consumer.dart';
import 'package:money_mate/core/api/end_point.dart';
import 'package:money_mate/core/errors/exceptions.dart';
import 'package:money_mate/models/bill_model.dart';
import 'package:money_mate/models/user_model.dart';
import 'package:money_mate/views/login_screen.dart';

class ApiServices {
  final ApiConsumer api;
  ApiServices({required this.api});

  BillsModel? billsModel;
  UserModel? userModel;
  billsView() async {
    try {
      
      final response = await api.get("${EndPoint.customerBills}$userId");
      billsModel = BillsModel.fromJson({"bills": response});
      return billsModel;
    } on ServerException catch (e) {
      log(e.toString());
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
    } on ServerException catch (e) {
      log(e.toString());
    }
  }
}
