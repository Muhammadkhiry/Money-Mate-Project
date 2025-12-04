import 'dart:developer';

import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:money_mate/controllers/controllers.dart';
import 'package:money_mate/core/api/api_consumer.dart';
import 'package:money_mate/core/api/end_point.dart';
import 'package:money_mate/core/errors/exceptions.dart';
import 'package:money_mate/models/bill_model.dart';
import 'package:money_mate/models/user_model.dart';

class ApiServices {
  final ApiConsumer api;
  ApiServices({required this.api});

  BillsModel? billsModel;
  UserModel? userModel;
  billsView(String userType,String token) async {
    try {
      final response = await api.get("bills/$userType/",headers: {
    "Authorization": token,
  },);
      return BillsModel.fromJson({"bills": response});
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
      final decoderToken = JwtDecoder.decode(userModel!.token);
    } on ServerException catch (e) {
      log(e.toString());
    }
  }

  Future<bool> payBill(int billId,String token) async {
    final response = await api.patch('/bills/$billId/pay',headers: {
    "Authorization": token,
  },);

    if (response['message'] == 'Bill paid successfully') {
      return true;
    }
    return false;
  }
}
