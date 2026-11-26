import 'package:core_contracts/core_contracts.dart';
import 'package:core_ui/core_ui.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'alba_bootstrap.dart';
import 'ambient/ambient_alert_navigator.dart';
import 'ambient/ambient_host.dart';
import 'navigation/language_routes.dart';

/// Raíz de la app: tema, idioma, rutas de los plugins listos y avisos a
/// pantalla completa.
///
/// Mientras no exista el reloj, el inicio (`/`) lleva a la pantalla del
/// primer plugin con entrada propia.
class AlbaApp extends StatefulWidget {
  const AlbaApp({super.key, required this.environment});

  final AlbaEnvironment environment;

  /// Nombre de la app en el sistema (no se traduce).
  static const String appName = 'Alba';

  static const String home = '/';

  @override
  State<AlbaApp> createState() => _AlbaAppState();
}

class _AlbaAppState extends State<AlbaApp> {
  List<HomePlugin> get _plugins => widget.environment.plugins;

  late final AmbientHost _ambient = AmbientHost(_plugins);

  late final String? _entry = <String>[
    for (final HomePlugin plugin in _plugins)
      if (plugin is HomePluginEntryRoute) (plugin as HomePluginEntryRoute).entryRoute,
  ].firstOrNull;

  late final GoRouter _router = GoRouter(
    initialLocation: AlbaApp.home,
    redirect: (BuildContext context, GoRouterState state) => state.matchedLocation == AlbaApp.home ? _entry : null,
    routes: <RouteBase>[
      GoRoute(path: AlbaApp.home, builder: (BuildContext context, GoRouterState state) => const SizedBox.shrink()),
      ...withLanguageRebuild(<RouteBase>[for (final HomePlugin plugin in _plugins) ...plugin.routes]),
    ],
  );

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ValueListenable<String> languageCode = widget.environment.localization.languageCode;
    return LanguageScope(
      languageCode: languageCode,
      child: ValueListenableBuilder<String>(
        valueListenable: languageCode,
        builder: (BuildContext context, String language, Widget? child) => MaterialApp.router(
          title: AlbaApp.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          locale: Locale(language),
          localizationsDelegates: LocalizationCoordinator.localizationsDelegates,
          supportedLocales: LocalizationCoordinator.supportedLocales,
          routerConfig: _router,
          builder: (BuildContext context, Widget? child) => AmbientAlertNavigator(
            host: _ambient,
            router: _router,
            child: child ?? const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}
