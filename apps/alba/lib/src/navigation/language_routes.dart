import 'package:core_ui/core_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Envuelve el contenido de cada `GoRoute` con [LanguageRebuilder] para que
/// las páginas abiertas cambien de idioma (los textos de slang son globales).
/// Las rutas con `pageBuilder` se dejan igual: ningún plugin lo usa todavía.
List<RouteBase> withLanguageRebuild(List<RouteBase> routes) => <RouteBase>[
      for (final RouteBase route in routes)
        if (route is GoRoute && route.builder != null)
          GoRoute(
            path: route.path,
            name: route.name,
            redirect: route.redirect,
            parentNavigatorKey: route.parentNavigatorKey,
            builder: (BuildContext context, GoRouterState state) =>
                LanguageRebuilder(child: route.builder!(context, state)),
            routes: withLanguageRebuild(route.routes),
          )
        else
          route,
    ];
