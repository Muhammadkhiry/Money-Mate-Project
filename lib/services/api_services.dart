import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:money_mate/core/api/api_consumer.dart';
import 'package:money_mate/core/api/end_point.dart';
import 'package:money_mate/models/bill_model.dart';

class ApiServices {
  final ApiConsumer api;
  final int id;

  ApiServices({required this.api, required this.id});

  BillsModel? model;

  billsView() async {
    try {
      final response = await api.get("${EndPoint.customerBills}5");
      model = BillsModel.fromJson({"bills": response});
      return model;
    } on DioException catch (e) {
      log(e.toString());
    }
  }
}

recentExpenses() async {}
