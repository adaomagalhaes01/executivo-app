import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import 'otp_screen.dart';

/// Ecrã de Login — fundo branco, logo grande, sem botões sociais.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _onLoginPressed() async {
    if (_phoneController.text.trim().isEmpty) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _isLoading = false);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OtpScreen(phoneNumber: _phoneController.text.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.xxxl),

              // ── Logo grande centrada ─────────────────────────────────────────
              Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 120,
                  height: 120,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Wordmark ────────────────────────────────────────────────────
              Center(
                child: Text(
                  'executivo',
                  style: AppTextStyles.displayMd.copyWith(
                    color: AppColors.textPrimary,
                    letterSpacing: 4,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Center(
                child: Container(
                  width: 40,
                  height: 2,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8000D),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // ── Instruções ─────────────────────────────────────────
              Text(
                'Insira o seu número de telemóvel para aceder ou criar a sua conta.',
                style: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // ── Campo de telemóvel ───────────────────────────────────────────
              Text(
                'Número de Telemóvel',
                style: AppTextStyles.labelLg.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              _PhoneInput(controller: _phoneController),

              const SizedBox(height: AppSpacing.xl),

              // ── Botão Entrar ─────────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _onLoginPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE8000D),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        const Color(0xFFE8000D).withAlpha(100),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Receber Código OTP',
                          style: AppTextStyles.buttonLg
                              .copyWith(color: Colors.white),
                        ),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Campo de Telemóvel ───────────────────────────────────────────────────────

class _PhoneInput extends StatelessWidget {
  final TextEditingController controller;
  const _PhoneInput({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Prefixo do país
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(color: AppColors.border),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🇦🇴', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 4),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textSecondary,
                  size: 18,
                ),
              ],
            ),
          ),
          // Input
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.phone,
              style: AppTextStyles.bodyMd
                  .copyWith(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: '9XX XXX XXX',
                hintStyle: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.textTertiary,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
