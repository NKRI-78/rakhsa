import 'package:flutter/material.dart';

import 'package:rakhsa/common/helpers/enum.dart';

import 'package:rakhsa/features/ppob/domain/entities/payment.dart';
import 'package:rakhsa/features/ppob/domain/usecases/payment_channel_usecase.dart';

class PaymentChannelProvider with ChangeNotifier {
  final PaymentChannelUseCase useCase;

  PaymentChannelProvider({
    required this.useCase
  });

  String? paymentChannel = "";
  String? paymentCode = "";
  String? paymentName = "";

  ProviderState _state = ProviderState.idle;
  ProviderState get state => _state;

  String _message = '';
  String get message => _message;

  List<PaymentDataEntity> _entity = [];
  List<PaymentDataEntity> get entity => [..._entity];

  void reset() {
    paymentChannel = "";
    paymentCode = "";
    paymentName = "";
  }

  void selectPaymentChannel({
    required String paymentChannelSelect,
    required String paymentCodeSelect,
    required String paymentNameSelect
  }) {
    paymentChannel = paymentChannelSelect;
    paymentCode = paymentCodeSelect;
    paymentName = paymentNameSelect;
    
    notifyListeners();
  }

  Future<void> fetch() async {
    _state = ProviderState.loading;
    notifyListeners();

    final result = await useCase.execute();

    result.fold((l) {
      _state = ProviderState.error;
      _message = l.message;
    }, (r) {

      _entity = [];
      _entity.addAll(r);
      _state = ProviderState.loaded;

      if(entity.isEmpty) {
        _message = "No data found";
        _state = ProviderState.empty;
      }
    });

    notifyListeners();
  }

}