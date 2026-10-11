import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/models/car_listing_draft.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/rentcar_theme.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/rentacar_owner_provider.dart';
import 'car_publish_success_screen.dart';
import '../widgets/publish_steps.dart';

/// Seven-step wizard that turns a draft into a published listing.
///
/// State lives in [RentCarOwnerProvider] so leaving and re-entering the wizard
/// keeps whatever the owner already typed.
class CarPublishScreen extends StatefulWidget {
  const CarPublishScreen({super.key});

  @override
  State<CarPublishScreen> createState() => _CarPublishScreenState();
}

class _CarPublishScreenState extends State<CarPublishScreen> {
  final PageController _controller = PageController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _goTo(PublishStep step) async {
    final provider = context.read<RentCarOwnerProvider>();
    provider.goToStep(step);
    await _controller.animateToPage(
      step.index,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _next() async {
    final provider = context.read<RentCarOwnerProvider>();
    final draft = provider.draft;
    final current = draft.currentStep;

    if (!draft.isStepValid(current)) {
      final message = draft.blockingMessage(current);
      if (message != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
      return;
    }

    final nextIndex = current.index + 1;
    if (nextIndex >= PublishStep.values.length) {
      await _publish();
      return;
    }
    await _goTo(PublishStep.values[nextIndex]);
  }

  Future<void> _back() async {
    final provider = context.read<RentCarOwnerProvider>();
    final current = provider.draft.currentStep;
    if (current.index == 0) {
      Navigator.of(context).maybePop();
      return;
    }
    await _goTo(PublishStep.values[current.index - 1]);
  }

  Future<void> _publish() async {
    final provider = context.read<RentCarOwnerProvider>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final car = await provider.publishDraft();
    if (car == null) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage.isEmpty
                ? 'Revise os dados do anúncio.'
                : provider.errorMessage,
          ),
        ),
      );
      return;
    }

    navigator.pushReplacement(
      MaterialPageRoute(
        builder: (_) => RentCarTheme.wrap(CarPublishSuccessScreen(car: car)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RentCarOwnerProvider>();
    final draft = provider.draft;

    return PopScope(
      canPop: draft.currentStep == PublishStep.vehicle,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(draft.currentStep.title),
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            onPressed: _back,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.md),
              child: Center(
                child: Text(
                  '${draft.currentStep.index + 1}/${PublishStep.values.length}',
                  style: AppTextStyles.labelMd.copyWith(
                    color: AppColors.textOnDarkSecondary,
                  ),
                ),
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(3),
            child: LinearProgressIndicator(
              value: draft.completion,
              minHeight: 3,
              backgroundColor: AppColors.surfaceVariant,
            ),
          ),
        ),
        body: PageView(
          controller: _controller,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            for (final step in PublishStep.values)
              _StepPage(step: step),
          ],
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            border: Border(
              top: BorderSide(color: Theme.of(context).dividerColor),
            ),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: provider.isPublishing ? null : _next,
                child: provider.isPublishing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        draft.currentStep == PublishStep.review
                            ? 'Publicar anúncio'
                            : 'Continuar',
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Wraps a step with its heading, subtitle and scroll view.
class _StepPage extends StatelessWidget {
  const _StepPage({required this.step});

  final PublishStep step;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.xxl,
      ),
      children: [
        Text(step.subtitle, style: AppTextStyles.bodyMd),
        const SizedBox(height: AppSpacing.xl),
        PublishStepBody(step: step),
      ],
    );
  }
}
