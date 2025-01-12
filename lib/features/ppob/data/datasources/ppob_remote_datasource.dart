import 'package:dio/dio.dart';
import 'package:rakhsa/common/constants/remote_data_source_consts.dart';

import 'package:rakhsa/common/errors/exception.dart';
import 'package:rakhsa/common/helpers/storage.dart';

import 'package:rakhsa/features/ppob/data/models/payment_model.dart';
import 'package:rakhsa/features/ppob/data/models/ppob_denom_topup_model.dart';
import 'package:rakhsa/features/ppob/data/models/ppob_inquiry_pulsa_model.dart';
import 'package:rakhsa/features/ppob/data/models/ppob_inquiry_tokenlistrik_model.dart';

abstract class PPOBRemoteDataSource {
  Future<PPOBPulsaInquiryModel> inquiryPulsa({required String prefix, required String type});
  Future<PPOBTokenListrikInquiryModel> inquiryPrabayarPLN({required String idpel});
  Future<PaymentModel> paymentChannelList();
  Future<int> getBalance();
  Future<void> payPulsaAndPaketData({
    required String productCode,
    required String phone
  });
  Future<void> payPraPLN({
    required String idpel, 
    required String ref2,
    required String nominal
  });
  Future<DenomTopupModel> denomTopup();
  Future<void> inquiryTopup({
    required String productId, 
    required int productPrice,
    required String channel,
    required String topupby
  });
}

// static const inquiryPulsa = "/inquiry/pulsa";
// static const payPulsa = "";
// static const inquiryPlnPra = "/inquiry/pln-prabayar";
// static const payPlnPra = "/pay/pln-prabayar";
// static const getBalance = "/get/balance";
// static const paymentList = "/payment_v2/pub/v1/payment/channels";

class PPOBRemoteDataSourceImpl implements PPOBRemoteDataSource {
  final Dio client;

  PPOBRemoteDataSourceImpl({required this.client});

  @override 
  Future<PPOBPulsaInquiryModel> inquiryPulsa({
    required String prefix,
    required String type
  }) async {
    try {
      Response res = await client.get("${RemoteDataSourceConsts.baseUrlPpob}/inquiry/pulsa?prefix=$prefix&type=$type");
      Map<String, dynamic> data = res.data;
      PPOBPulsaInquiryModel ppobPulsaInquiryModel = PPOBPulsaInquiryModel.fromJson(data);
      return ppobPulsaInquiryModel;
    } on DioException catch(e) {
      String message = handleDioException(e);
      throw ServerException(message);
    } catch(e) {
      throw Exception(e.toString());
    }
  }

  @override 
  Future<PPOBTokenListrikInquiryModel> inquiryPrabayarPLN({required String idpel}) async {
    try {
      Response res = await client.post("${RemoteDataSourceConsts.baseUrlPpob}/inquiry/pln-prabayar", 
        data: {
          "idpel": idpel
        }
      );
      Map<String, dynamic> data = res.data;
      PPOBTokenListrikInquiryModel ppobTokenListrikInquiryModel = PPOBTokenListrikInquiryModel.fromJson(data);
      return ppobTokenListrikInquiryModel;
    } on DioException catch(e) {
      String message = handleDioException(e);
      throw ServerException(message);
    } catch(e) {
      throw Exception(e.toString());
    }
  }

  @override 
  Future<void> payPraPLN({
    required String idpel, 
    required String ref2,
    required String nominal
  }) async {
    try {
      await client.post("${RemoteDataSourceConsts.baseUrlPpob}/pay/pln-prabayar",
        data: {
          "idpel": idpel,
          "ref2": ref2,
          "nominal": nominal,
          "user_id": StorageHelper.getUserId()
        }
      );
    } on DioException catch(e) {
      String message = handleDioException(e);
      throw ServerException(message);
    } catch(e) {
      throw Exception(e.toString());
    }
  }

  @override 
  Future<PaymentModel> paymentChannelList() async {
    try {
      Response res = await client.get("${RemoteDataSourceConsts.baseUrlPpob}/payment_v2/pub/v1/payment/channels");
      Map<String, dynamic> data = res.data;
      PaymentModel pm = PaymentModel.fromJson(data);
      return pm;
    } on DioException catch(e) {
      String message = handleDioException(e);
      throw ServerException(message);
    } catch(e) {
      throw Exception(e.toString());
    }
  }

  @override 
  Future<int> getBalance() async {
    try {
      Response res = await client.post("${RemoteDataSourceConsts.baseUrlPpob}/get/balance",
        data: {
          "user_id": StorageHelper.getUserId(),
          "origin": "raksha"
        }
      );
      Map<String, dynamic> data = res.data;
      return data["body"]["balance"];
    } on DioException catch(e) {
      String message = handleDioException(e);
      throw ServerException(message);
    } catch(e) {
      throw Exception(e.toString());
    }
  }

  @override 
  Future<DenomTopupModel> denomTopup() async {
    try {
      Response res = await client.get("${RemoteDataSourceConsts.baseUrlPpob}/get/denom");
      Map<String, dynamic> data = res.data;
      DenomTopupModel inquiryDenomTopupModel = DenomTopupModel.fromJson(data);
      return inquiryDenomTopupModel;
    } on DioException catch(e) {
      String message = handleDioException(e);
      throw ServerException(message);
    } catch(e) {
      throw Exception(e.toString());
    }
  }

  @override 
  Future<void> inquiryTopup({
    required String productId,
    required int productPrice,
    required String channel,
    required String topupby
  }) async {
    try {
      if(topupby == "without") {
        await client.post("${RemoteDataSourceConsts.baseUrlPpob}/inquiry/topup/balance",
          data: {
            "product_id": productId,
            "channel": channel,
            "user_id": StorageHelper.getUserId(),
            "phone_number": StorageHelper.getUserPhone(),
            "email_address": StorageHelper.getUserEmail(),
            "origin": "sman4medan"
          }
        );
      } else {
        await client.post("${RemoteDataSourceConsts.baseUrlPpob}/inquiry/topup/balance/input",
          data: {
            "product_price": productPrice,
            "channel": channel,
            "user_id": StorageHelper.getUserId(),
            "phone_number": StorageHelper.getUserPhone(),
            "email_address": StorageHelper.getUserEmail(),
            "origin": "sman4medan"
          }
        );
      }
    } on DioException catch(e) {
      String message = handleDioException(e);
      throw ServerException(message);
    } catch(e) {
      throw Exception(e.toString());
    }
  }

  @override 
  Future<void> payPulsaAndPaketData({
    required String productCode,
    required String phone
  }) async {
    try {
      await client.post("${RemoteDataSourceConsts.baseUrlPpob}/pay/pulsa", 
        data: {
          "product_code": productCode,
          "phone": phone,
          "user_id": StorageHelper.getUserId()
        }
      );
    } on DioException catch(e) {
      String message = handleDioException(e);
      throw ServerException(message);
    } catch(e) {
      throw Exception(e.toString());
    }
  }

}
