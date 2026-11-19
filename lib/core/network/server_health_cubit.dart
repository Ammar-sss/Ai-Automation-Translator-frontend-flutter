import 'dart:async';

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'server_health_service.dart';

part 'server_health_state.dart';

class ServerHealthCubit extends Cubit<ServerHealthState>
    with WidgetsBindingObserver {
  final ServerHealthService _service;
  Timer? _timer;

  /// Adaptive interval: fast when sleeping, slow when awake.
  static const _sleepingInterval = Duration(seconds: 30);
  static const _awakeInterval = Duration(seconds: 120);

  ServerHealthCubit({required this._service}) : super(ServerSleeping()) {
    WidgetsBinding.instance.addObserver(this);
    _startHealthTimer();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startHealthTimer();
    } else if (state == AppLifecycleState.paused) {
      _stopHealthTimer();
    }
  }

  void _startHealthTimer() {
    _timer?.cancel();
    final interval = state is ServerAwake ? _awakeInterval : _sleepingInterval;
    _timer = Timer.periodic(interval, (_) {
      wakeServer();
    });
  }

  void _stopHealthTimer() {
    _timer?.cancel();
  }

  Future<void> wakeServer() async {
    if (state is ServerWakingUp) return;

    emit(ServerWakingUp());

    final isAlive = await _service.isServerAlive();

    if (isAlive) {
      emit(ServerAwake());
    } else {
      emit(ServerSleeping());
    }

    // Restart timer with the appropriate interval for the new state
    _startHealthTimer();
  }

  @override
  Future<void> close() {
    WidgetsBinding.instance.removeObserver(this);
    _stopHealthTimer();
    return super.close();
  }
}
