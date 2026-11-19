part of 'network_cubit.dart';

@immutable
sealed class NetworkState {
  final bool isConnected;
  const NetworkState({required this.isConnected});
}

class NetworkInitial extends NetworkState {
  const NetworkInitial() : super(isConnected: true);
}

class NetworkConnected extends NetworkState {
  final List<ConnectivityResult> connectionTypes;
  const NetworkConnected(this.connectionTypes) : super(isConnected: true);
}

class NetworkDisconnected extends NetworkState {
  const NetworkDisconnected() : super(isConnected: false);
}
