import 'package:flutter/material.dart';

import 'package:rakhsa/common/helpers/enum.dart';

import 'package:rakhsa/features/event/data/models/list.dart';
import 'package:rakhsa/features/event/domain/usecases/list_event.dart';

class ListEventNotifier extends ChangeNotifier {
  final ListEventUseCase useCase;

  ListEventNotifier({required this.useCase});

  List<EventData> _entity = [];
  List<EventData> get entity => [..._entity];

  ProviderState _state = ProviderState.empty;
  ProviderState get state => _state;

  String _message = '';
  String get message => _message;

  Future<void> list() async {
    _state = ProviderState.loading;
    Future.delayed(Duration.zero, () => notifyListeners());

    final result = await useCase.execute();
    result.fold((l) {
      _state = ProviderState.error;
      Future.delayed(Duration.zero, () => notifyListeners());

      _message = l.message;
    }, (r) {
      _entity = [];
      _entity.addAll(r.data);
      
      _state = ProviderState.loaded;
      Future.delayed(Duration.zero, () => notifyListeners());
    });
  }
}