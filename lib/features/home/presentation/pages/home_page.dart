import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_translator/core/network/connectivity_cubit.dart';
import '../../../user/presentation/widgets/profile_drawer.dart';

// ---------------------------------------------------------------------------
// Design tokens (same palette as MainWrapperPage)
// ---------------------------------------------------------------------------
class _C {
  static const bg = Color(0xFF11131D);
  static const cardAlt = Color(0xFF1F2230);
  static const border = Color(0xFF2A2D3B);
  static const orange = Color(0xFFFF5A2C);
  static const green = Color(0xFF3DDC84);
  static const textPrimary = Colors.white;
  static const textSecondary = Color(0xFFA9ABB8);
  static const textMuted = Color(0xFF7C7F8F);
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      body: SafeArea(
        bottom: false,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusScope.of(context).unfocus(),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              const _TopBar(),
              const SizedBox(height: 16),
              const _Greeting(),
              const SizedBox(height: 16),
              const SizedBox(height: 16),
              const SizedBox(height: 16),
              const SizedBox(height: 24),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Top bar
// ---------------------------------------------------------------------------
class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    final isOnline = context.watch<ConnectivityCubit>().state;
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: _C.orange,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.translate, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 10),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI translator',
              style: TextStyle(
                color: _C.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'HOME',
              style: TextStyle(
                color: _C.textMuted,
                fontSize: 9,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        const Spacer(),
        _StatusChip(
          label: isOnline ? 'Online' : "offline",
          color: isOnline ? _C.green : Colors.yellow,
        ),
        const SizedBox(width: 8),
        InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => ProfileDrawer.open(context),
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: _C.cardAlt,
              shape: BoxShape.circle,
              border: Border.all(color: _C.border),
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              color: _C.textSecondary,
              size: 18,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _C.cardAlt,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: _C.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Greeting row
// ---------------------------------------------------------------------------
class _Greeting extends StatelessWidget {
  const _Greeting();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            const CircleAvatar(
              radius: 22,
              backgroundColor: _C.cardAlt,
              // TODO: swap for NetworkImage / user avatar.
              child: Icon(Icons.person, color: _C.textSecondary),
            ),
            Positioned(
              right: -1,
              bottom: -1,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _C.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: _C.bg, width: 2),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, Linh',
                style: TextStyle(
                  color: _C.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Wednesday, 24 Oct',
                style: TextStyle(color: _C.textMuted, fontSize: 12),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: _C.cardAlt,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _C.border),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.local_fire_department_rounded,
                color: _C.orange,
                size: 16,
              ),
              SizedBox(width: 4),
              Text(
                '7 Days',
                style: TextStyle(
                  color: _C.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
