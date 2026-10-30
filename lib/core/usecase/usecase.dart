/// Abstract callable UseCase contract for enterprise business logic.
abstract interface class UseCase<T, Params> {
  Future<T> call(Params params);
}

class NoParams {
  const NoParams();
}
