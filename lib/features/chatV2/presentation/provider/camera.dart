import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:rakhsa/common/constants/remote_data_source_consts.dart';
import 'package:rakhsa/common/helpers/storage.dart';
import 'package:rakhsa/features/chatV2/data/models/camera/create_ticket.dart';

enum CameraStatus { idle, loading, loaded, error, empty }

class CameraProvider extends ChangeNotifier {
  CameraStatus _cameraStatus = CameraStatus.idle;
  CameraStatus get cameraStatus => _cameraStatus;

   void setStateCameraStatus(CameraStatus cameraStatus) {
    _cameraStatus = cameraStatus;
    Future.delayed(Duration.zero, () => notifyListeners());
  }

  Future<void> createTicket({required String description, required String media_link, required String media_type, required String latitude, required String longitude}) async {
    try {
      setStateCameraStatus(CameraStatus.loading);
      String? token = await StorageHelper.getToken();
      print("${RemoteDataSourceConsts.baseUrlApiMarlinda}/api/v1/ticket");
      print("Bearer $token");
      print("Data : ${{
        "description": description,
        "media_link": media_link,
        "media_type": media_type,
        "latitude": latitude,
        "longitude": longitude,
      }}");
      Dio dio = Dio();
      Response res = await dio.post("${RemoteDataSourceConsts.baseUrlApiMarlinda}/api/v1/ticket", 
        data: {
          "description": description,
          "media_link": media_link,
          "media_type": media_type,
          "latitude": latitude,
          "longitude": longitude,
        }, options: Options(
        headers: {
          "Authorization": "Bearer $token"
        })
      );
      print("Text : ${res.data}");
      Map<String, dynamic> resData = res.data;
      CreateTicketModel createTicketModel = CreateTicketModel.fromJson(resData);

      if (res.statusCode == 400) {
        throw createTicketModel.message ?? "Terjadi kesalahan";
      }
      return null;
    } catch (e) {
      debugPrint("ERROR : $e");
    }
    return null;
  }
}