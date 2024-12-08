import 'package:dartz/dartz.dart';

import 'package:rakhsa/common/errors/failure.dart';

import 'package:rakhsa/features/information/domain/repository/kbri_repository.dart';

class GetKbriUseCase {
  final KbriRepository repository;

  GetKbriUseCase(this.repository);

  Future<Either<Failure, void>> execute({
    required String stateId,
  }) {
    return repository.infoKbri(
      stateId: stateId,
    );  
  }
}