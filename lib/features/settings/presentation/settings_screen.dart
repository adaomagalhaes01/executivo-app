import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../main.dart';
import '../../../shared/widgets/executive_app_bar.dart';
import '../widgets/settings_nav_tile.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_section_title.dart';
import '../widgets/settings_switch_tile.dart';

/// Full settings screen for the EXECUTIVO app.
///
/// Sections: Conta, Preferências, Segurança, Suporte, Sobre.
/// Theme switching is handled locally and bubbles up via [onThemeChanged].
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, this.onThemeChanged});

  /// Callback invoked when the user toggles the dark theme switch.
  final ValueChanged<bool>? onThemeChanged;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkTheme = false;
  bool _notifications = true;
  bool _locationServices = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        isDark ? AppColors.dark : AppColors.backgroundLight;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: ExecutiveAppBar(
        title: 'Configurações',
        subtitle: 'Personalize sua experiência.',
        showBack: false,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPadding,
          vertical: AppSpacing.md,
        ),
        children: [
          // ─── Conta ──────────────────────────────────────────────────────
          const SettingsSectionTitle(title: 'Conta'),
          SettingsSection(
            children: [
              SettingsNavTile(
                icon: Icons.person_outline_rounded,
                title: 'Perfil',
                subtitle: 'Gerencie seus dados pessoais',
                onTap: () => _showComingSoon(context, 'Perfil'),
              ),
              SettingsNavTile(
                icon: Icons.phone_outlined,
                title: 'Número de telefone',
                subtitle: 'Alterar ou verificar seu número',
                onTap: () => _showComingSoon(context, 'Número de telefone'),
              ),
              SettingsNavTile(
                icon: Icons.badge_outlined,
                title: 'Dados pessoais',
                subtitle: 'Nome, e-mail e documento',
                onTap: () => _showComingSoon(context, 'Dados pessoais'),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sectionGap),

          // ─── Preferências ───────────────────────────────────────────────
          const SettingsSectionTitle(title: 'Preferências'),
          SettingsSection(
            children: [
              SettingsNavTile(
                icon: Icons.language_outlined,
                title: 'Idioma',
                subtitle: 'Português (Brasil)',
                onTap: () => _showComingSoon(context, 'Idioma'),
                trailing: _TrailingBadge(label: 'PT'),
              ),
              SettingsSwitchTile(
                icon: Icons.dark_mode_outlined,
                title: 'Tema escuro',
                subtitle: 'Ativar modo noturno',
                value: _darkTheme,
                onChanged: (val) {
                  setState(() => _darkTheme = val);
                  ExecutivoApp.themeNotifier.value =
                      val ? ThemeMode.dark : ThemeMode.light;
                  widget.onThemeChanged?.call(val);
                },
              ),
              SettingsSwitchTile(
                icon: Icons.notifications_none_rounded,
                title: 'Notificações',
                subtitle: 'Avisos de corridas e promoções',
                value: _notifications,
                onChanged: (val) => setState(() => _notifications = val),
              ),
              SettingsSwitchTile(
                icon: Icons.location_on_outlined,
                title: 'Localização',
                subtitle: 'Permitir acesso à sua localização',
                value: _locationServices,
                onChanged: (val) => setState(() => _locationServices = val),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sectionGap),

          // ─── Segurança ──────────────────────────────────────────────────
          const SettingsSectionTitle(title: 'Segurança'),
          SettingsSection(
            children: [
              SettingsNavTile(
                icon: Icons.lock_outline_rounded,
                title: 'PIN e segurança',
                subtitle: 'Configurar PIN de acesso',
                onTap: () => _showComingSoon(context, 'PIN e segurança'),
              ),
              SettingsNavTile(
                icon: Icons.security_outlined,
                title: 'Privacidade',
                subtitle: 'Controle seus dados e permissões',
                onTap: () => _showComingSoon(context, 'Privacidade'),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sectionGap),

          // ─── Suporte ────────────────────────────────────────────────────
          const SettingsSectionTitle(title: 'Suporte'),
          SettingsSection(
            children: [
              SettingsNavTile(
                icon: Icons.help_outline_rounded,
                title: 'Central de ajuda',
                subtitle: 'Tire suas dúvidas',
                onTap: () => _showComingSoon(context, 'Central de ajuda'),
              ),
              SettingsNavTile(
                icon: Icons.description_outlined,
                title: 'Termos e condições',
                onTap: () => _showComingSoon(context, 'Termos e condições'),
              ),
              SettingsNavTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Política de privacidade',
                onTap: () =>
                    _showComingSoon(context, 'Política de privacidade'),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sectionGap),

          // ─── Sobre ──────────────────────────────────────────────────────
          const SettingsSectionTitle(title: 'Sobre'),
          SettingsSection(
            children: [
              SettingsNavTile(
                icon: Icons.info_outline_rounded,
                title: AppConstants.appName,
                subtitle: 'Versão ${AppConstants.appVersion}',
                trailing: _VersionBadge(version: AppConstants.appVersion),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xxl),

          // ─── Footer ─────────────────────────────────────────────────────
          Center(
            child: Column(
              children: [
                Text(
                  AppConstants.appName,
                  style: AppTextStyles.labelMd.copyWith(
                    color: isDark
                        ? AppColors.textOnDarkSecondary
                        : AppColors.textTertiary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppConstants.appTagline,
                  style: AppTextStyles.captionSm.copyWith(
                    color: isDark
                        ? AppColors.textOnDarkSecondary
                        : AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature — em breve.'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.dark,
        margin: const EdgeInsets.all(AppSpacing.md),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.sm),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// ─── Internal widgets ─────────────────────────────────────────────────────────

class _TrailingBadge extends StatelessWidget {
  const _TrailingBadge({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkElevated : AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isDark ? AppColors.darkElevated : AppColors.border,
        ),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSm.copyWith(
          color: isDark ? AppColors.textOnDarkSecondary : AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _VersionBadge extends StatelessWidget {
  const _VersionBadge({required this.version});
  final String version;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        'v$version',
        style: AppTextStyles.labelSm.copyWith(
          color: AppColors.primaryDark,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
