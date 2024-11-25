import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:rakhsa/common/constants/remote_data_source_consts.dart';
import 'package:rakhsa/common/errors/exception.dart';
import 'package:rakhsa/common/helpers/storage.dart';

import 'package:rakhsa/features/event/data/models/list.dart';

abstract class EventRemoteDataSource {
  Future<EventModel> list();
  Future<void> save({
    required String title, 
    required String startDate,
    required String endDate, 
    required int continentId,
    required int stateId, 
    required String description
  });
  Future<void> update({
    required int id, 
    required String title, 
    required String startDate,
    required String endDate, 
    required int continentId,
    required int stateId, 
    required String description
  });
  Future<void> delete({
    required int id
  });
}

class EventRemoteDataSourceImpl implements EventRemoteDataSource {
  Dio client;

  EventRemoteDataSourceImpl({required this.client});

  @override 
  Future<EventModel> list() async {
    try {
      final response = await client.get("${RemoteDataSourceConsts.baseUrlProd}/api/v1/event");
      Map<String, dynamic> data = response.data;
      EventModel itineraryModel = EventModel.fromJson(data);
      return itineraryModel;
    } on DioException catch(e) {
      String message = handleDioException(e);
      throw ServerException(message);
    } catch(e, stacktrace) {
      debugPrint(stacktrace.toString());
      throw Exception(e.toString());
    } 
  }

  @override 
  Future<void> save({
    required String title,
    required String startDate,
    required String endDate,
    required int continentId,
    required int stateId, 
    required String description
  }) async {
    try {
      await client.post("${RemoteDataSourceConsts.baseUrlProd}/api/v1/event",
        data: {
          "title": title,
          "start_date": startDate,
          "end_date": endDate,
          "continent_id": continentId,
          "state_id": stateId,
          "description": description,
          "user_id": StorageHelper.getUserId()
        }
      );
    } on DioException catch(e) {
      debugPrint(e.response.toString());
      String message = handleDioException(e);
      throw ServerException(message);
    } catch(e, stacktrace) {
      debugPrint(stacktrace.toString());
      throw Exception(e.toString());
    } 
  }

  @override 
  Future<void> update({
    required int id,
    required String title,
    required String startDate,
    required String endDate,
    required int continentId,
    required int stateId, 
    required String description
  }) async {
    try {
      await client.put("${RemoteDataSourceConsts.baseUrlProd}/api/v1/event/$id",
        data: {
          "title": title,
          "start_date": startDate,
          "end_date": endDate,
          "continent_id": continentId,
          "state_id": stateId,
          "description": description
        }
      );
    } on DioException catch(e) {
      debugPrint(e.response.toString());
      String message = handleDioException(e);
      throw ServerException(message);
    } catch(e, stacktrace) {
      debugPrint(stacktrace.toString());
      throw Exception(e.toString());
    } 
  }

  @override 
  Future<void> delete({
    required int id
  }) async {
    try {
      await client.delete("${RemoteDataSourceConsts.baseUrlProd}/api/v1/event/$id");
    } on DioException catch(e) {
      debugPrint(e.response.toString());
      String message = handleDioException(e);
      throw ServerException(message);
    } catch(e, stacktrace) {
      debugPrint(stacktrace.toString());
      throw Exception(e.toString());
    }
  }

}