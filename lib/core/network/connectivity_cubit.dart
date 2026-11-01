import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class ConnectivityCubit extends Cubit<bool> {
  ConnectivityCubit() : super(true) {
    _sub = InternetConnection().onStatusChange.listen(
      (s) => emit(s == InternetStatus.connected),
    );
  }

  StreamSubscription<InternetStatus>? _sub;

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
