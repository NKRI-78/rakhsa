import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:rakhsa/common/constants/remote_data_source_consts.dart';

import 'package:rakhsa/common/errors/exception.dart';

import 'package:rakhsa/features/nearme/data/models/nearme.dart';

abstract class NearmeRemoteDataSource {
  Future<NearbyplaceModel> getNearme({
    required String keyword,
    required double currentLat,
    required double currentLng,
    required String type,
  });
}

class NearmeRemoteDataSourceImpl implements NearmeRemoteDataSource {

  Dio client;

  NearmeRemoteDataSourceImpl({required this.client});

  @override
  Future<NearbyplaceModel> getNearme({
    required String keyword,
    required double currentLat,
    required double currentLng,
    required String type,
  }) async {
    try { 
      final response = await client.get("https://maps.googleapis.com/maps/api/place/nearbysearch/json?keyword=$keyword&location=$currentLat,$currentLng&types=mosque&radius=500&key=${RemoteDataSourceConsts.gmaps}");
      Map<String, dynamic> data = response.data;
      NearbyplaceModel nearby = NearbyplaceModel.fromJson(data);
      return nearby;
    } on DioException catch (e) {
      String message = handleDioException(e);
      throw ServerException(message);
    } catch (e, stacktrace) {
      debugPrint(stacktrace.toString());
      throw Exception(e.toString());
    }
  }


}