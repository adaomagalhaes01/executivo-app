import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../onboarding/presentation/onboarding_screen.dart';

/// Splash Screen animada do EXECUTIVO.
///
/// Sequência de animação (~4 segundos):
///   1. Logo entra de cima com fade
///   2. Logo sobe e desce 3× em bounce
///   3. Logo cai no buraco (escala → 0)
///   4. Buraco abre e fecha
///   5. Texto "executivo" aparece com scale + fade
///   6. Navega para Onboarding
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _bounceCtrl;
  late final AnimationController _fallCtrl;
  late final AnimationController _holeCtrl;
  late final AnimationController _textCtrl;

  late final Animation<double> _logoY;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _fallY;
  late final Animation<double> _fallScale;
  late final Animation<double> _fallOpacity;
  late final Animation<double> _holeScaleX;
  late final Animation<double> _holeScaleY;
  late final Animation<double> _textOpacity;
  late final Animation<double> _textScale;

  bool _showHole = false;
  bool _showText = false;
  bool _logoVisible = true;

  @override
  void initState() {
    super.initState();

    // ── 1. Bounce (1.8 s) ─────────────────────────────────────────────────────
    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _bounceCtrl,
        curve: const Interval(0.0, 0.12, curve: Curves.easeIn),
      ),
    );

    _logoY = TweenSequence<double>([
      // Entra de cima
      TweenSequenceItem(
        tween: Tween(
          begin: -120.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 18,
      ),
      // Bounce 1 — grande
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: -55.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 14,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: -55.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 14,
      ),
      // Bounce 2 — médio
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: -28.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 10,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: -28.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 10,
      ),
      // Bounce 3 — pequeno
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: -12.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 7,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: -12.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 7,
      ),
      // Pausa no centro antes de cair
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.0), weight: 20),
    ]).animate(_bounceCtrl);

    // ── 2. Queda (0.55 s) ─────────────────────────────────────────────────────
    _fallCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    _fallY = Tween<double>(
      begin: 0.0,
      end: 70.0,
    ).animate(CurvedAnimation(parent: _fallCtrl, curve: Curves.easeIn));

    _fallScale = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _fallCtrl, curve: Curves.easeIn));

    _fallOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _fallCtrl,
        curve: const Interval(0.55, 1.0, curve: Curves.easeOut),
      ),
    );

    // ── 3. Buraco abre e fecha (0.9 s) ────────────────────────────────────────
    _holeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _holeScaleX = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 35,
      ),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 20),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 45,
      ),
    ]).animate(_holeCtrl);

    _holeScaleY = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: 0.3,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 35,
      ),
      TweenSequenceItem(tween: Tween(begin: 0.3, end: 0.3), weight: 20),
      TweenSequenceItem(
        tween: Tween(
          begin: 0.3,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 45,
      ),
    ]).animate(_holeCtrl);

    // ── 4. Texto (0.9 s) ──────────────────────────────────────────────────────
    _textCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _textOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut));

    _textScale = Tween<double>(
      begin: 0.75,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOutCubic));

    _runSequence();
  }

  Future<void> _runSequence() async {
    // Aguarda 400 ms antes de começar
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    // 1. Bounce
    await _bounceCtrl.forward();
    if (!mounted) return;

    // 2. Buraco aparece + logo começa a cair simultaneamente
    setState(() => _showHole = true);
    await Future.wait([_fallCtrl.forward(), _holeCtrl.forward()]);
    if (!mounted) return;
    setState(() => _logoVisible = false);

    // 3. Mostra texto
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;
    setState(() {
      _showHole = false;
      _showText = true;
    });
    _textCtrl.forward();

    // 4. Aguarda 1.8 s com o texto visível e navega
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;
    _navigateToOnboarding();
  }

  void _navigateToOnboarding() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, animation, _) => const OnboardingScreen(),
        transitionsBuilder: (_, animation, _, child) => FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    _fallCtrl.dispose();
    _holeCtrl.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SizedBox(
          width: 260,
          height: 260,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // ── Logo com bounce e queda ──────────────────────────────────
              if (_logoVisible)
                AnimatedBuilder(
                  animation: Listenable.merge([_bounceCtrl, _fallCtrl]),
                  builder: (context, _) {
                    final isFalling = _bounceCtrl.isCompleted;
                    final yOffset = isFalling ? _fallY.value : _logoY.value;
                    final scale = isFalling ? _fallScale.value : 1.0;
                    final opacity = isFalling
                        ? _fallOpacity.value
                        : _logoOpacity.value;

                    return Opacity(
                      opacity: opacity.clamp(0.0, 1.0),
                      child: Transform.translate(
                        offset: Offset(0, yOffset),
                        child: Transform.scale(
                          scale: scale.clamp(0.0, 1.0),
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: 130,
                            height: 130,
                          ),
                        ),
                      ),
                    );
                  },
                ),

              // ── Buraco ────────────────────────────────────────────────────
              if (_showHole)
                AnimatedBuilder(
                  animation: _holeCtrl,
                  builder: (context, _) => Transform.scale(
                    scaleX: _holeScaleX.value,
                    scaleY: _holeScaleY.value,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF1A1A1A),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(180),
                            blurRadius: 24,
                            spreadRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // ── Texto "executivo" ─────────────────────────────────────────
              if (_showText)
                AnimatedBuilder(
                  animation: _textCtrl,
                  builder: (context, _) => Opacity(
                    opacity: _textOpacity.value,
                    child: Transform.scale(
                      scale: _textScale.value,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'executivo',
                            style: AppTextStyles.displayMd.copyWith(
                              color: AppColors.textPrimary,
                              letterSpacing: 6,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            width: 44,
                            height: 3,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8000D),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Mobilidade urbana premium.',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
