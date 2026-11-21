import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../network/network_cubit.dart';
import '../network/server_health_cubit.dart';
import 'pulsing_dot.dart';
import 'radio_wave_dot.dart';

class ServerStatusIndicator extends StatelessWidget {
  const ServerStatusIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return BlocBuilder<NetworkCubit, NetworkState>(
      buildWhen: (previous, current) =>
          (previous is NetworkDisconnected) != (current is NetworkDisconnected),
      builder: (context, networkState) {
        if (networkState is NetworkDisconnected) {
          return _StatusPill(
            dotColor: scheme.outline,
            text: 'Offline',
            isLoading: false,
            isAwake: false,
            onTap: null,
          );
        }

        return BlocBuilder<ServerHealthCubit, ServerHealthState>(
          builder: (context, state) {
            final isWakingUp = state is ServerWakingUp;
            final isAwake = state is ServerAwake;

            final Color dotColor;
            final String text;
            if (isAwake) {
              dotColor = Colors.green;
              text = 'Online';
            } else if (isWakingUp) {
              dotColor = Colors.amber;
              text = 'Waking up…';
            } else {
              dotColor = scheme.error;
              text = 'Wake server';
            }

            return _StatusPill(
              dotColor: dotColor,
              text: text,
              isLoading: isWakingUp,
              isAwake: isAwake,
              onTap: isWakingUp
                  ? null
                  : () => context.read<ServerHealthCubit>().wakeServer(),
            );
          },
        );
      },
    );
  }
}

class _StatusPill extends StatelessWidget {
  final Color dotColor;
  final String text;
  final bool isLoading;
  final bool isAwake;
  final VoidCallback? onTap;

  const _StatusPill({
    required this.dotColor,
    required this.text,
    required this.isLoading,
    required this.isAwake,
    required this.onTap,
  });

  Widget _buildDot() {
    if (isAwake) {
      return const RadioWaveDot(color: Colors.green, size: 7, maxScale: 2.2);
    }
    if (isLoading) {
      return const PulsingDot(
        color: Colors.amber,
        size: 7,
        minSize: 0.7,
        maxSize: 1.4,
      );
    }
    return DecoratedBox(
      decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Semantics(
      button: onTap != null,
      label: 'Server status: $text',
      child: Material(
        color: scheme.surfaceContainerHigh,
        shape: const StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: Center(child: _buildDot()),
                ),
                const SizedBox(width: 6),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    text,
                    key: ValueKey(text),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
