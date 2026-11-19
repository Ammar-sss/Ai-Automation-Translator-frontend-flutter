part of 'server_health_cubit.dart';

@immutable
sealed class ServerHealthState {}

/// Server is asleep or unreachable (🔴 Red)
final class ServerSleeping extends ServerHealthState {}

/// Sending ping to wake up the server (🟡 Yellow / Loading)
final class ServerWakingUp extends ServerHealthState {}

/// Server is awake and ready (🟢 Green)
final class ServerAwake extends ServerHealthState {}
