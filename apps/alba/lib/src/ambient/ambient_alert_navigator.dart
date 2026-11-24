import 'dart:async';

import 'package:core_contracts/core_contracts.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'ambient_host.dart';

/// Abre la pantalla del aviso a pantalla completa que gana (p. ej. la alarma
/// sonando), esté donde esté la app. Cerrarla es cosa del plugin.
///
/// Solo los avisos con `route`: el aviso genérico (sin pantalla propia), los
/// banners y los estados los dibuja el reloj, que aún no existe.
class AmbientAlertNavigator extends StatefulWidget {
  const AmbientAlertNavigator({super.key, required this.host, required this.router, required this.child});

  final AmbientHost host;
  final GoRouter router;
  final Widget child;

  @override
  State<AmbientAlertNavigator> createState() => _AmbientAlertNavigatorState();
}

class _AmbientAlertNavigatorState extends State<AmbientAlertNavigator> {
  StreamSubscription<AmbientResolution>? _subscription;

  /// El aviso ya abierto, para no abrirlo otra vez en cada emisión.
  String? _openedKey;

  @override
  void initState() {
    super.initState();
    _subscription = widget.host.watch().listen(_onResolution);
  }

  void _onResolution(AmbientResolution resolution) {
    final AmbientAlert? alert = resolution.fullScreen;
    final String? route = alert?.route;
    if (alert == null || route == null) {
      _openedKey = null;
      return;
    }
    final String key = '${alert.sourceId}/${alert.id}';
    if (key != _openedKey && widget.router.state.matchedLocation != route) {
      unawaited(widget.router.push(route));
    }
    _openedKey = key;
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
