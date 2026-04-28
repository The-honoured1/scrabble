import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scrabble/core/theme.dart';
import 'package:scrabble/core/motion.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:scrabble/presentation/screens/asset_management_screen.dart';
import 'package:scrabble/services/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _versionTaps = 0;

  void _onVersionTap() {
    setState(() => _versionTaps++);
    if (_versionTaps >= 7) {
      _showEasterEgg();
      _versionTaps = 0;
    }
  }

  void _showEasterEgg() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('EASTER EGG ACTIVATED! 🎮'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: AnimationConfiguration.toStaggeredList(
              duration: const Duration(milliseconds: 600),
              childAnimationBuilder: (widget) => SlideAnimation(
                horizontalOffset: 50.0,
                child: FadeInAnimation(child: widget),
              ),
              children: [
                Text(
                  'SETTINGS',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: 32),
                
                const _SettingsGroup(
                  title: 'GAMEPLAY',
                  children: [
                    _SettingsToggle(label: 'HAPTIC FEEDBACK', settingsKey: 'haptic'),
                    _SettingsToggle(label: 'SOUND EFFECTS', settingsKey: 'sound'),
                    _SettingsToggle(label: 'TILE MAGNETISM', settingsKey: 'magnet'),
                  ],
                ),

                _SettingsGroup(
                  title: 'APPEARANCE',
                  children: [
                    _SettingsRow(
                      label: 'ASSET MANAGEMENT',
                      onTap: () {
                        Navigator.push(
                          context,
                          ScaleFadePageRoute(page: const AssetManagementScreen()),
                        );
                      },
                    ),
                    const _SettingsToggle(label: 'HIGH CONTRAST', settingsKey: 'contrast'),
                    const _SettingsToggle(label: 'DARK MODE', settingsKey: 'dark_mode'),
                  ],
                ),

                const _SettingsGroup(
                  title: 'ACCOUNT',
                  children: [
                    _SettingsRow(label: 'LOGIN / SIGN UP'),
                    _SettingsRow(label: 'EXPORT DATA'),
                  ],
                ),

                const SizedBox(height: 48),
                Center(
                  child: GestureDetector(
                    onTap: _onVersionTap,
                    child: Text(
                      'VERSION 1.0.0 (BETA)',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        color: AppColors.textMuted,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsGroup({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            title,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: AppColors.primary,
              letterSpacing: 4,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Column(
            children: children,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _SettingsToggle extends StatefulWidget {
  final String label;
  final String settingsKey; // Added to distinguish settings

  const _SettingsToggle({required this.label, required this.settingsKey});

  @override
  State<_SettingsToggle> createState() => _SettingsToggleState();
}

class _SettingsToggleState extends State<_SettingsToggle> with SingleTickerProviderStateMixin {
  late bool _value;
  late AnimationController _burstController;

  @override
  void initState() {
    super.initState();
    _value = true; // Placeholder until load
    _loadValue();
    _burstController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _burstController.dispose();
    super.dispose();
  }

  Future<void> _loadValue() async {
    bool val = false;
    if (widget.settingsKey == 'haptic') val = await SettingsService.isHapticEnabled();
    if (widget.settingsKey == 'sound') val = await SettingsService.isSoundEnabled();
    if (mounted) setState(() => _value = val);
  }

  void _toggle(bool? val) async {
    final newValue = val ?? !_value;
    setState(() => _value = newValue);
    
    if (widget.settingsKey == 'haptic') await SettingsService.setHaptic(newValue);
    if (widget.settingsKey == 'sound') await SettingsService.setSound(newValue);

    if (_value) {
      _burstController.forward(from: 0);
      HapticService.light();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      title: Text(
        widget.label,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      trailing: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            painter: _BurstPainter(animation: _burstController),
            size: const Size(100, 100),
          ),
          Switch(
            value: _value,
            onChanged: _toggle,
            activeColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withOpacity(0.2),
            inactiveThumbColor: AppColors.textMuted,
            inactiveTrackColor: Colors.white10,
          ),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _SettingsRow({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      title: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
      onTap: onTap,
    );
  }
}

class _BurstPainter extends CustomPainter {
  final Animation<double> animation;

  _BurstPainter({required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    if (animation.value == 0 || animation.value == 1) return;

    final paint = Paint()
      ..color = AppColors.primary.withOpacity(1 - animation.value)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2 + 15, size.height / 2);
    final radius = 20 + animation.value * 20;

    for (int i = 0; i < 8; i++) {
      final angle = (i * 45) * pi / 180;
      final start = Offset(
        center.dx + cos(angle) * (radius - 10),
        center.dy + sin(angle) * (radius - 10),
      );
      final end = Offset(
        center.dx + cos(angle) * radius,
        center.dy + sin(angle) * radius,
      );
      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
