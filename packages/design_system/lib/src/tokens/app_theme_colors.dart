// GENERADO por tool/generate_tokens.dart desde design/referencia_penpot.
// No editar a mano: cambia el JSON exportado de Penpot y vuelve a generar.

import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Colores semánticos de los temas claro y oscuro (`bg.surface-raised` es
/// `bgSurfaceRaised`). Se leen del tema con [AppThemeColors.of].
@immutable
class AppThemeColors extends ThemeExtension<AppThemeColors> {
  const AppThemeColors({
    required this.bgCanvas,
    required this.bgSurface,
    required this.bgSurfaceRaised,
    required this.bgSurfaceSunken,
    required this.bgSurfaceHover,
    required this.bgSurfacePressed,
    required this.bgBrandSubtle,
    required this.bgBrandMuted,
    required this.bgDisabled,
    required this.bgDangerSubtle,
    required this.bgSuccessSubtle,
    required this.bgWarningSubtle,
    required this.bgInfoSubtle,
    required this.bgScrim,
    required this.bgOnPhoto,
    required this.photoScrimStart,
    required this.photoScrimEnd,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textDisabled,
    required this.textBrand,
    required this.textOnBrand,
    required this.textOnBrandSubtle,
    required this.textOnPhoto,
    required this.textOnDanger,
    required this.textDanger,
    required this.textSuccess,
    required this.textWarning,
    required this.textInfo,
    required this.borderDefault,
    required this.borderStrong,
    required this.borderHover,
    required this.borderBrand,
    required this.borderBrandSubtle,
    required this.borderFocus,
    required this.borderDanger,
    required this.borderSuccess,
    required this.borderWarning,
    required this.borderDisabled,
    required this.borderOnPhoto,
    required this.actionPrimaryDefault,
    required this.actionPrimaryHover,
    required this.actionPrimaryPressed,
    required this.actionSecondaryDefault,
    required this.actionSecondaryHover,
    required this.actionSecondaryPressed,
    required this.actionGhostHover,
    required this.actionGhostPressed,
    required this.actionDangerDefault,
    required this.actionDangerHover,
    required this.actionDangerPressed,
    required this.actionDisabled,
    required this.statusDanger,
    required this.statusSuccess,
    required this.statusWarning,
    required this.statusInfo,
    required this.shadowSoft,
  });

  static const AppThemeColors light = AppThemeColors(
    bgCanvas: AppColors.warm50,
    bgSurface: AppColors.warm0,
    bgSurfaceRaised: AppColors.warm0,
    bgSurfaceSunken: AppColors.warm100,
    bgSurfaceHover: AppColors.warm100,
    bgSurfacePressed: AppColors.warm200,
    bgBrandSubtle: AppColors.amber50,
    bgBrandMuted: AppColors.amber100,
    bgDisabled: AppColors.warm100,
    bgDangerSubtle: AppColors.terra50,
    bgSuccessSubtle: AppColors.olive50,
    bgWarningSubtle: AppColors.ochre50,
    bgInfoSubtle: AppColors.slate50,
    bgScrim: AppColors.alphaScrim40,
    bgOnPhoto: AppColors.alphaWhite12,
    photoScrimStart: AppColors.alphaScrim0,
    photoScrimEnd: AppColors.alphaScrim72,
    textPrimary: AppColors.warm900,
    textSecondary: AppColors.warm600,
    textTertiary: AppColors.warm550,
    textDisabled: AppColors.warm400,
    textBrand: AppColors.amber700,
    textOnBrand: AppColors.warm1000,
    textOnBrandSubtle: AppColors.amber800,
    textOnPhoto: AppColors.warm0,
    textOnDanger: AppColors.warm0,
    textDanger: AppColors.terra700,
    textSuccess: AppColors.olive700,
    textWarning: AppColors.ochre700,
    textInfo: AppColors.slate700,
    borderDefault: AppColors.warm200,
    borderStrong: AppColors.warm450,
    borderHover: AppColors.warm600,
    borderBrand: AppColors.amber600,
    borderBrandSubtle: AppColors.amber200,
    borderFocus: AppColors.amber600,
    borderDanger: AppColors.terra600,
    borderSuccess: AppColors.olive600,
    borderWarning: AppColors.ochre500,
    borderDisabled: AppColors.warm200,
    borderOnPhoto: AppColors.alphaWhite20,
    actionPrimaryDefault: AppColors.amber400,
    actionPrimaryHover: AppColors.amber500,
    actionPrimaryPressed: AppColors.amber600,
    actionSecondaryDefault: AppColors.warm100,
    actionSecondaryHover: AppColors.warm200,
    actionSecondaryPressed: AppColors.warm300,
    actionGhostHover: AppColors.warm100,
    actionGhostPressed: AppColors.warm200,
    actionDangerDefault: AppColors.terra600,
    actionDangerHover: AppColors.terra700,
    actionDangerPressed: AppColors.terra800,
    actionDisabled: AppColors.warm200,
    statusDanger: AppColors.terra600,
    statusSuccess: AppColors.olive600,
    statusWarning: AppColors.ochre500,
    statusInfo: AppColors.slate600,
    shadowSoft: AppColors.alphaScrim40,
  );

  static const AppThemeColors dark = AppThemeColors(
    bgCanvas: AppColors.warm950,
    bgSurface: AppColors.warm900,
    bgSurfaceRaised: AppColors.warm850,
    bgSurfaceSunken: AppColors.warm1000,
    bgSurfaceHover: AppColors.warm850,
    bgSurfacePressed: AppColors.warm800,
    bgBrandSubtle: AppColors.amber950,
    bgBrandMuted: AppColors.amber900,
    bgDisabled: AppColors.warm850,
    bgDangerSubtle: AppColors.terra950,
    bgSuccessSubtle: AppColors.olive950,
    bgWarningSubtle: AppColors.ochre950,
    bgInfoSubtle: AppColors.slate950,
    bgScrim: AppColors.alphaScrim60,
    bgOnPhoto: AppColors.alphaWhite12,
    photoScrimStart: AppColors.alphaScrim0,
    photoScrimEnd: AppColors.alphaScrim72,
    textPrimary: AppColors.warm100,
    textSecondary: AppColors.warm400,
    textTertiary: AppColors.warm450,
    textDisabled: AppColors.warm600,
    textBrand: AppColors.amber300,
    textOnBrand: AppColors.warm1000,
    textOnBrandSubtle: AppColors.amber200,
    textOnPhoto: AppColors.warm0,
    textOnDanger: AppColors.warm0,
    textDanger: AppColors.terra300,
    textSuccess: AppColors.olive300,
    textWarning: AppColors.ochre300,
    textInfo: AppColors.slate300,
    borderDefault: AppColors.warm800,
    borderStrong: AppColors.warm500,
    borderHover: AppColors.warm400,
    borderBrand: AppColors.amber400,
    borderBrandSubtle: AppColors.amber800,
    borderFocus: AppColors.amber300,
    borderDanger: AppColors.terra400,
    borderSuccess: AppColors.olive400,
    borderWarning: AppColors.ochre400,
    borderDisabled: AppColors.warm800,
    borderOnPhoto: AppColors.alphaWhite20,
    actionPrimaryDefault: AppColors.amber400,
    actionPrimaryHover: AppColors.amber300,
    actionPrimaryPressed: AppColors.amber200,
    actionSecondaryDefault: AppColors.warm850,
    actionSecondaryHover: AppColors.warm800,
    actionSecondaryPressed: AppColors.warm700,
    actionGhostHover: AppColors.warm850,
    actionGhostPressed: AppColors.warm800,
    actionDangerDefault: AppColors.terra600,
    actionDangerHover: AppColors.terra500,
    actionDangerPressed: AppColors.terra700,
    actionDisabled: AppColors.warm800,
    statusDanger: AppColors.terra400,
    statusSuccess: AppColors.olive400,
    statusWarning: AppColors.ochre400,
    statusInfo: AppColors.slate400,
    shadowSoft: AppColors.alphaScrim60,
  );

  /// `bg.canvas`
  final Color bgCanvas;
  /// `bg.surface`
  final Color bgSurface;
  /// `bg.surface-raised`
  final Color bgSurfaceRaised;
  /// `bg.surface-sunken`
  final Color bgSurfaceSunken;
  /// `bg.surface-hover`
  final Color bgSurfaceHover;
  /// `bg.surface-pressed`
  final Color bgSurfacePressed;
  /// `bg.brand-subtle`
  final Color bgBrandSubtle;
  /// `bg.brand-muted`
  final Color bgBrandMuted;
  /// `bg.disabled`
  final Color bgDisabled;
  /// `bg.danger-subtle`
  final Color bgDangerSubtle;
  /// `bg.success-subtle`
  final Color bgSuccessSubtle;
  /// `bg.warning-subtle`
  final Color bgWarningSubtle;
  /// `bg.info-subtle`
  final Color bgInfoSubtle;
  /// `bg.scrim`
  final Color bgScrim;
  /// `bg.on-photo`
  final Color bgOnPhoto;
  /// `photo.scrim-start`
  final Color photoScrimStart;
  /// `photo.scrim-end`
  final Color photoScrimEnd;
  /// `text.primary`
  final Color textPrimary;
  /// `text.secondary`
  final Color textSecondary;
  /// `text.tertiary`
  final Color textTertiary;
  /// `text.disabled`
  final Color textDisabled;
  /// `text.brand`
  final Color textBrand;
  /// `text.on-brand`
  final Color textOnBrand;
  /// `text.on-brand-subtle`
  final Color textOnBrandSubtle;
  /// `text.on-photo`
  final Color textOnPhoto;
  /// `text.on-danger`
  final Color textOnDanger;
  /// `text.danger`
  final Color textDanger;
  /// `text.success`
  final Color textSuccess;
  /// `text.warning`
  final Color textWarning;
  /// `text.info`
  final Color textInfo;
  /// `border.default`
  final Color borderDefault;
  /// `border.strong`
  final Color borderStrong;
  /// `border.hover`
  final Color borderHover;
  /// `border.brand`
  final Color borderBrand;
  /// `border.brand-subtle`
  final Color borderBrandSubtle;
  /// `border.focus`
  final Color borderFocus;
  /// `border.danger`
  final Color borderDanger;
  /// `border.success`
  final Color borderSuccess;
  /// `border.warning`
  final Color borderWarning;
  /// `border.disabled`
  final Color borderDisabled;
  /// `border.on-photo`
  final Color borderOnPhoto;
  /// `action.primary-default`
  final Color actionPrimaryDefault;
  /// `action.primary-hover`
  final Color actionPrimaryHover;
  /// `action.primary-pressed`
  final Color actionPrimaryPressed;
  /// `action.secondary-default`
  final Color actionSecondaryDefault;
  /// `action.secondary-hover`
  final Color actionSecondaryHover;
  /// `action.secondary-pressed`
  final Color actionSecondaryPressed;
  /// `action.ghost-hover`
  final Color actionGhostHover;
  /// `action.ghost-pressed`
  final Color actionGhostPressed;
  /// `action.danger-default`
  final Color actionDangerDefault;
  /// `action.danger-hover`
  final Color actionDangerHover;
  /// `action.danger-pressed`
  final Color actionDangerPressed;
  /// `action.disabled`
  final Color actionDisabled;
  /// `status.danger`
  final Color statusDanger;
  /// `status.success`
  final Color statusSuccess;
  /// `status.warning`
  final Color statusWarning;
  /// `status.info`
  final Color statusInfo;
  /// `shadow.soft`
  final Color shadowSoft;

  /// Colores del tema de [context]; los del tema claro si no hay ninguno.
  static AppThemeColors of(BuildContext context) => Theme.of(context).extension<AppThemeColors>() ?? light;

  @override
  AppThemeColors copyWith({
    Color? bgCanvas,
    Color? bgSurface,
    Color? bgSurfaceRaised,
    Color? bgSurfaceSunken,
    Color? bgSurfaceHover,
    Color? bgSurfacePressed,
    Color? bgBrandSubtle,
    Color? bgBrandMuted,
    Color? bgDisabled,
    Color? bgDangerSubtle,
    Color? bgSuccessSubtle,
    Color? bgWarningSubtle,
    Color? bgInfoSubtle,
    Color? bgScrim,
    Color? bgOnPhoto,
    Color? photoScrimStart,
    Color? photoScrimEnd,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? textDisabled,
    Color? textBrand,
    Color? textOnBrand,
    Color? textOnBrandSubtle,
    Color? textOnPhoto,
    Color? textOnDanger,
    Color? textDanger,
    Color? textSuccess,
    Color? textWarning,
    Color? textInfo,
    Color? borderDefault,
    Color? borderStrong,
    Color? borderHover,
    Color? borderBrand,
    Color? borderBrandSubtle,
    Color? borderFocus,
    Color? borderDanger,
    Color? borderSuccess,
    Color? borderWarning,
    Color? borderDisabled,
    Color? borderOnPhoto,
    Color? actionPrimaryDefault,
    Color? actionPrimaryHover,
    Color? actionPrimaryPressed,
    Color? actionSecondaryDefault,
    Color? actionSecondaryHover,
    Color? actionSecondaryPressed,
    Color? actionGhostHover,
    Color? actionGhostPressed,
    Color? actionDangerDefault,
    Color? actionDangerHover,
    Color? actionDangerPressed,
    Color? actionDisabled,
    Color? statusDanger,
    Color? statusSuccess,
    Color? statusWarning,
    Color? statusInfo,
    Color? shadowSoft,
  }) =>
      AppThemeColors(
        bgCanvas: bgCanvas ?? this.bgCanvas,
        bgSurface: bgSurface ?? this.bgSurface,
        bgSurfaceRaised: bgSurfaceRaised ?? this.bgSurfaceRaised,
        bgSurfaceSunken: bgSurfaceSunken ?? this.bgSurfaceSunken,
        bgSurfaceHover: bgSurfaceHover ?? this.bgSurfaceHover,
        bgSurfacePressed: bgSurfacePressed ?? this.bgSurfacePressed,
        bgBrandSubtle: bgBrandSubtle ?? this.bgBrandSubtle,
        bgBrandMuted: bgBrandMuted ?? this.bgBrandMuted,
        bgDisabled: bgDisabled ?? this.bgDisabled,
        bgDangerSubtle: bgDangerSubtle ?? this.bgDangerSubtle,
        bgSuccessSubtle: bgSuccessSubtle ?? this.bgSuccessSubtle,
        bgWarningSubtle: bgWarningSubtle ?? this.bgWarningSubtle,
        bgInfoSubtle: bgInfoSubtle ?? this.bgInfoSubtle,
        bgScrim: bgScrim ?? this.bgScrim,
        bgOnPhoto: bgOnPhoto ?? this.bgOnPhoto,
        photoScrimStart: photoScrimStart ?? this.photoScrimStart,
        photoScrimEnd: photoScrimEnd ?? this.photoScrimEnd,
        textPrimary: textPrimary ?? this.textPrimary,
        textSecondary: textSecondary ?? this.textSecondary,
        textTertiary: textTertiary ?? this.textTertiary,
        textDisabled: textDisabled ?? this.textDisabled,
        textBrand: textBrand ?? this.textBrand,
        textOnBrand: textOnBrand ?? this.textOnBrand,
        textOnBrandSubtle: textOnBrandSubtle ?? this.textOnBrandSubtle,
        textOnPhoto: textOnPhoto ?? this.textOnPhoto,
        textOnDanger: textOnDanger ?? this.textOnDanger,
        textDanger: textDanger ?? this.textDanger,
        textSuccess: textSuccess ?? this.textSuccess,
        textWarning: textWarning ?? this.textWarning,
        textInfo: textInfo ?? this.textInfo,
        borderDefault: borderDefault ?? this.borderDefault,
        borderStrong: borderStrong ?? this.borderStrong,
        borderHover: borderHover ?? this.borderHover,
        borderBrand: borderBrand ?? this.borderBrand,
        borderBrandSubtle: borderBrandSubtle ?? this.borderBrandSubtle,
        borderFocus: borderFocus ?? this.borderFocus,
        borderDanger: borderDanger ?? this.borderDanger,
        borderSuccess: borderSuccess ?? this.borderSuccess,
        borderWarning: borderWarning ?? this.borderWarning,
        borderDisabled: borderDisabled ?? this.borderDisabled,
        borderOnPhoto: borderOnPhoto ?? this.borderOnPhoto,
        actionPrimaryDefault: actionPrimaryDefault ?? this.actionPrimaryDefault,
        actionPrimaryHover: actionPrimaryHover ?? this.actionPrimaryHover,
        actionPrimaryPressed: actionPrimaryPressed ?? this.actionPrimaryPressed,
        actionSecondaryDefault: actionSecondaryDefault ?? this.actionSecondaryDefault,
        actionSecondaryHover: actionSecondaryHover ?? this.actionSecondaryHover,
        actionSecondaryPressed: actionSecondaryPressed ?? this.actionSecondaryPressed,
        actionGhostHover: actionGhostHover ?? this.actionGhostHover,
        actionGhostPressed: actionGhostPressed ?? this.actionGhostPressed,
        actionDangerDefault: actionDangerDefault ?? this.actionDangerDefault,
        actionDangerHover: actionDangerHover ?? this.actionDangerHover,
        actionDangerPressed: actionDangerPressed ?? this.actionDangerPressed,
        actionDisabled: actionDisabled ?? this.actionDisabled,
        statusDanger: statusDanger ?? this.statusDanger,
        statusSuccess: statusSuccess ?? this.statusSuccess,
        statusWarning: statusWarning ?? this.statusWarning,
        statusInfo: statusInfo ?? this.statusInfo,
        shadowSoft: shadowSoft ?? this.shadowSoft,
      );

  @override
  AppThemeColors lerp(covariant AppThemeColors? other, double t) {
    if (other == null) {
      return this;
    }
    return AppThemeColors(
      bgCanvas: Color.lerp(bgCanvas, other.bgCanvas, t)!,
      bgSurface: Color.lerp(bgSurface, other.bgSurface, t)!,
      bgSurfaceRaised: Color.lerp(bgSurfaceRaised, other.bgSurfaceRaised, t)!,
      bgSurfaceSunken: Color.lerp(bgSurfaceSunken, other.bgSurfaceSunken, t)!,
      bgSurfaceHover: Color.lerp(bgSurfaceHover, other.bgSurfaceHover, t)!,
      bgSurfacePressed: Color.lerp(bgSurfacePressed, other.bgSurfacePressed, t)!,
      bgBrandSubtle: Color.lerp(bgBrandSubtle, other.bgBrandSubtle, t)!,
      bgBrandMuted: Color.lerp(bgBrandMuted, other.bgBrandMuted, t)!,
      bgDisabled: Color.lerp(bgDisabled, other.bgDisabled, t)!,
      bgDangerSubtle: Color.lerp(bgDangerSubtle, other.bgDangerSubtle, t)!,
      bgSuccessSubtle: Color.lerp(bgSuccessSubtle, other.bgSuccessSubtle, t)!,
      bgWarningSubtle: Color.lerp(bgWarningSubtle, other.bgWarningSubtle, t)!,
      bgInfoSubtle: Color.lerp(bgInfoSubtle, other.bgInfoSubtle, t)!,
      bgScrim: Color.lerp(bgScrim, other.bgScrim, t)!,
      bgOnPhoto: Color.lerp(bgOnPhoto, other.bgOnPhoto, t)!,
      photoScrimStart: Color.lerp(photoScrimStart, other.photoScrimStart, t)!,
      photoScrimEnd: Color.lerp(photoScrimEnd, other.photoScrimEnd, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      textBrand: Color.lerp(textBrand, other.textBrand, t)!,
      textOnBrand: Color.lerp(textOnBrand, other.textOnBrand, t)!,
      textOnBrandSubtle: Color.lerp(textOnBrandSubtle, other.textOnBrandSubtle, t)!,
      textOnPhoto: Color.lerp(textOnPhoto, other.textOnPhoto, t)!,
      textOnDanger: Color.lerp(textOnDanger, other.textOnDanger, t)!,
      textDanger: Color.lerp(textDanger, other.textDanger, t)!,
      textSuccess: Color.lerp(textSuccess, other.textSuccess, t)!,
      textWarning: Color.lerp(textWarning, other.textWarning, t)!,
      textInfo: Color.lerp(textInfo, other.textInfo, t)!,
      borderDefault: Color.lerp(borderDefault, other.borderDefault, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      borderHover: Color.lerp(borderHover, other.borderHover, t)!,
      borderBrand: Color.lerp(borderBrand, other.borderBrand, t)!,
      borderBrandSubtle: Color.lerp(borderBrandSubtle, other.borderBrandSubtle, t)!,
      borderFocus: Color.lerp(borderFocus, other.borderFocus, t)!,
      borderDanger: Color.lerp(borderDanger, other.borderDanger, t)!,
      borderSuccess: Color.lerp(borderSuccess, other.borderSuccess, t)!,
      borderWarning: Color.lerp(borderWarning, other.borderWarning, t)!,
      borderDisabled: Color.lerp(borderDisabled, other.borderDisabled, t)!,
      borderOnPhoto: Color.lerp(borderOnPhoto, other.borderOnPhoto, t)!,
      actionPrimaryDefault: Color.lerp(actionPrimaryDefault, other.actionPrimaryDefault, t)!,
      actionPrimaryHover: Color.lerp(actionPrimaryHover, other.actionPrimaryHover, t)!,
      actionPrimaryPressed: Color.lerp(actionPrimaryPressed, other.actionPrimaryPressed, t)!,
      actionSecondaryDefault: Color.lerp(actionSecondaryDefault, other.actionSecondaryDefault, t)!,
      actionSecondaryHover: Color.lerp(actionSecondaryHover, other.actionSecondaryHover, t)!,
      actionSecondaryPressed: Color.lerp(actionSecondaryPressed, other.actionSecondaryPressed, t)!,
      actionGhostHover: Color.lerp(actionGhostHover, other.actionGhostHover, t)!,
      actionGhostPressed: Color.lerp(actionGhostPressed, other.actionGhostPressed, t)!,
      actionDangerDefault: Color.lerp(actionDangerDefault, other.actionDangerDefault, t)!,
      actionDangerHover: Color.lerp(actionDangerHover, other.actionDangerHover, t)!,
      actionDangerPressed: Color.lerp(actionDangerPressed, other.actionDangerPressed, t)!,
      actionDisabled: Color.lerp(actionDisabled, other.actionDisabled, t)!,
      statusDanger: Color.lerp(statusDanger, other.statusDanger, t)!,
      statusSuccess: Color.lerp(statusSuccess, other.statusSuccess, t)!,
      statusWarning: Color.lerp(statusWarning, other.statusWarning, t)!,
      statusInfo: Color.lerp(statusInfo, other.statusInfo, t)!,
      shadowSoft: Color.lerp(shadowSoft, other.shadowSoft, t)!,
    );
  }
}
