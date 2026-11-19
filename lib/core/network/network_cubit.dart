import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'network_state.dart';

class NetworkCubit extends Cubit<NetworkState> {
  final Connectivity _connectivity;
  late final StreamSubscription<List<ConnectivityResult>> _subscription;

  NetworkCubit({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity(),
        super(const NetworkInitial()) {
    _initConnectivity();
  }

  bool get isConnected => state.isConnected;

  Future<void> _initConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateConnectionState(results);
    } catch (_) {
      emit(const NetworkConnected([ConnectivityResult.mobile]));
    }

    _subscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionState);
  }

  void _updateConnectionState(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.none) || results.isEmpty) {
      emit(const NetworkDisconnected());
    } else {
      emit(NetworkConnected(results));
    }
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
