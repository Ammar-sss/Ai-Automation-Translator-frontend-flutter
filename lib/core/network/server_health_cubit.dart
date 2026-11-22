// ignore_for_file: prefer_initializing_formals
import 'dart:async';

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'network_cubit.dart';
import 'server_health_service.dart';

part 'server_health_state.dart';

class ServerHealthCubit extends Cubit<ServerHealthState>
    with WidgetsBindingObserver {
  final ServerHealthService _service;
  final NetworkCubit? _networkCubit;
  StreamSubscription? _networkSubscription;
  CancelToken? _cancelToken;
  Timer? _timer;

  /// Automatically check server health every 10 seconds.
  static const _checkInterval = Duration(seconds: 10);

  ServerHealthCubit({
    required ServerHealthService service,
    NetworkCubit? networkCubit,
  }) : _service = service,
       _networkCubit = networkCubit,
       super(ServerWakingUp()) {
    WidgetsBinding.instance.addObserver(this);
    _listenToNetwork();
    _startHealthTimer();
    wakeServer(force: true);
  }

  void _listenToNetwork() {
    final cubit = _networkCubit;
    if (cubit == null) return;
    _networkSubscription = cubit.stream.listen((networkState) {
      if (networkState is NetworkConnected) {
        // Automatically re-check server when network reconnects
        wakeServer(force: true);
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startHealthTimer();
      wakeServer(force: true);
    } else if (state == AppLifecycleState.paused) {
      _stopHealthTimer();
    }
  }

  void _startHealthTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(_checkInterval, (_) {
      wakeServer();
    });
  }

  void _stopHealthTimer() {
    _timer?.cancel();
  }

  Future<void> wakeServer({bool force = false}) async {
    if (state is ServerWakingUp && !force) return;

    // Cancel any previous hanging request
    _cancelToken?.cancel('New health check started');
    _cancelToken = CancelToken();

    if (state is! ServerWakingUp) {
      emit(ServerWakingUp());
    }

    final isAlive = await _service.isServerAlive(cancelToken: _cancelToken);

    if (_cancelToken?.isCancelled ?? false) return;

    if (isAlive) {
      emit(ServerAwake());
    } else {
      emit(ServerSleeping());
    }
  }

  @override
  Future<void> close() {
    _networkSubscription?.cancel();
    _cancelToken?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _stopHealthTimer();
    return super.close();
  }
}
