import 'package:dio/dio.dart';
import 'package:money_mate/core/api/api_consumer.dart';
import 'package:money_mate/core/api/api_interceptors.dart';
import 'package:money_mate/core/api/end_point.dart';
import 'package:money_mate/core/errors/exceptions.dart';

class DioCosumer extends ApiConsumer {
  final Dio dio;

  DioCosumer({required this.dio}) {
    dio.options.baseUrl = EndPoint.baseURL;
    dio.interceptors.add(ApiInterceptors());
    dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
    ));
  }

  @override
  Future delete(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParms,
  }) async {
    try {
      final response = await dio.delete(
        path,
        data: data,
        queryParameters: queryParms,
      );
      return response.data;
    } on DioException catch (e) {
      handleDioExceptions(e);
    }
  }

  @override
  Future get(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParms,
  }) async {
    try {
      final response = await dio.get(
        path,
        data: data,
        queryParameters: queryParms,
      );
      return response.data;
    } on DioException catch (e) {
      handleDioExceptions(e);
    }
  }

  @override
  Future patch(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParms,
  }) async {
    try {
      final response = await dio.patch(
        path,
        data: data,
        queryParameters: queryParms,
      );
      return response.data;
    } on DioException catch (e) {
      handleDioExceptions(e);
    }
  }

  @override
  Future post(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParms,
  }) async {
    try {
      final response = await dio.post(
        path,
        data: data,
        queryParameters: queryParms,
      );
      return response.data;
    } on DioException catch (e) {
      handleDioExceptions(e);
    }
  }
}
