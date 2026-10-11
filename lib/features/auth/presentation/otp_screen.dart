import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import 'password_screen.dart';

/// Ecrã de verificação OTP.
///
/// Recebe o número de telemóvel e solicita o código de 6 dígitos
/// enviado por SMS. Permite reenvio após contagem regressiva.
class OtpScreen extends StatefulWidget {
  final String phoneNumber;

  const OtpScreen({super.key, required this.phoneNumber});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  String _otpValue = '';
  bool _isLoading = false;
  int _secondsLeft = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      if (_secondsLeft > 0) {
        setState(() => _secondsLeft--);
        _startCountdown();
      } else {
        setState(() => _canResend = true);
      }
    });
  }

  void _onResend() {
    setState(() {
      _secondsLeft = 60;
      _canResend = false;
    });
    _startCountdown();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Código reenviado para ${widget.phoneNumber}',
          style: AppTextStyles.bodyMd.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.darkElevated,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _onVerifyPressed() async {
    if (_otpValue.length < 6) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() => _isLoading = false);
    
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PasswordScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: AppTextStyles.headingMd.copyWith(
        color: AppColors.textPrimary,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.border,
          width: 1.5,
        ),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(
          color: const Color(0xFFE8000D),
          width: 2,
        ),
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: const Color(0xFFE8000D).withAlpha(30),
        border: Border.all(
          color: const Color(0xFFE8000D),
          width: 1.5,
        ),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: AppColors.textPrimary,
            ),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.xl),

              // ── Título ───────────────────────────────────────────────────────
              Text(
                'Verificar Código',
                style: AppTextStyles.headingLg.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Enviámos um código SMS para ',
                      style: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    TextSpan(
                      text: widget.phoneNumber,
                      style: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xxxl),

              // ── OTP Pinput ───────────────────────────────────────────────────
              Center(
                child: Pinput(
                  length: 6,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: focusedPinTheme,
                  submittedPinTheme: submittedPinTheme,
                  pinAnimationType: PinAnimationType.slide,
                  onChanged: (value) => setState(() => _otpValue = value),
                  onCompleted: (_) => _onVerifyPressed(),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // ── Reenviar ─────────────────────────────────────────────────────
              Center(
                child: _canResend
                    ? GestureDetector(
                        onTap: _onResend,
                        child: Text(
                          'Reenviar código',
                          style: AppTextStyles.labelLg.copyWith(
                            color: const Color(0xFFE8000D),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Reenviar em ',
                              style: AppTextStyles.bodyMd.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            TextSpan(
                              text: '$_secondsLeft s',
                              style: AppTextStyles.bodyMd.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),

              const Spacer(),

              // ── Botão verificar ──────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: (_otpValue.length == 6 && !_isLoading)
                      ? _onVerifyPressed
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE8000D),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        const Color(0xFFE8000D).withAlpha(60),
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
                          'Verificar',
                          style: AppTextStyles.buttonLg.copyWith(
                            color: Colors.white,
                          ),
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
