import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../auth/presentation/login_screen.dart';

class _OnboardingPage {
  final String imagePath;
  final String title;
  final String subtitle;

  const _OnboardingPage({
    required this.imagePath,
    required this.title,
    required this.subtitle,
  });
}

/// Ecrã de Onboarding com 3 páginas deslizantes — fundo branco.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const List<_OnboardingPage> _pages = [
    _OnboardingPage(
      imagePath: 'assets/images/onboarding_taxi.png',
      title: 'Viagens com Conforto e Estilo',
      subtitle:
          'Reserve o seu táxi executivo em segundos. Motoristas profissionais, viaturas premium e pontualidade garantida para cada deslocação.',
    ),
    _OnboardingPage(
      imagePath: 'assets/images/onboarding_entrega.png',
      title: 'Entregas Rápidas à sua Porta',
      subtitle:
          'Envie e receba encomendas com rastreamento em tempo real. O seu pacote entregue com segurança, rapidez e total fiabilidade.',
    ),
    _OnboardingPage(
      imagePath: 'assets/images/onboarding_rentcar.png',
      title: 'Alugue o Carro Ideal',
      subtitle:
          'Escolha entre uma frota de veículos premium para as suas necessidades. Flexibilidade, comodidade e preços competitivos ao seu alcance.',
    ),
  ];

  void _onNextPressed() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, animation, _) => const LoginScreen(),
        transitionsBuilder: (_, animation, _, child) => FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Skip ─────────────────────────────────────────────────────────
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(
                  top: AppSpacing.md,
                  right: AppSpacing.md,
                ),
                child: TextButton(
                  onPressed: _navigateToLogin,
                  child: Text(
                    'Ignorar',
                    style: AppTextStyles.labelLg.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),

            // ── Páginas ───────────────────────────────────────────────────────
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (_, i) =>
                    _OnboardingPageWidget(page: _pages[i]),
              ),
            ),

            // ── Controlos ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.xl,
              ),
              child: Column(
                children: [
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: _pages.length,
                    effect: ExpandingDotsEffect(
                      dotHeight: 8,
                      dotWidth: 8,
                      expansionFactor: 4,
                      spacing: 6,
                      activeDotColor: const Color(0xFFE8000D),
                      dotColor: AppColors.border,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _onNextPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE8000D),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _currentPage == _pages.length - 1
                            ? 'Começar'
                            : 'Próximo',
                        style: AppTextStyles.buttonLg
                            .copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Widget de cada página ────────────────────────────────────────────────────

class _OnboardingPageWidget extends StatelessWidget {
  final _OnboardingPage page;
  const _OnboardingPageWidget({required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Image.asset(page.imagePath, fit: BoxFit.contain),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: AppTextStyles.headingMd.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            page.subtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMd.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}
