import 'package:flutter_native/global.dart';
import 'package:flutter_native/catalog/model_catalog.dart';
import 'package:flutter_native/model_cards.dart';
import 'package:flutter_native/playground/model_playground.dart';

class ScreenPaths {
  static String home = 'home';
  static String modelPlayground = 'model_playground';
  static String modelCatalog = "model_catalog";
}

final GoRouter appRouter = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      name: ScreenPaths.home,
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return ModelCards();
      },
      routes: <RouteBase>[
        GoRoute(
          name: ScreenPaths.modelPlayground,
          path: "model_playground",
          builder: (BuildContext context, GoRouterState state) {
            return ModelPlayground(
              icon: state.queryParameters['icon']!,
              tag: state.queryParameters['tag']!,
              playground: state.queryParameters['playground']!,
            );
          },
        ),
        GoRoute(
          name: ScreenPaths.modelCatalog,
          path: "model_catalog",
          builder: (BuildContext context, GoRouterState state) {
            return const ModelCatalog();
          },
        ),
      ],
    ),
  ],
);
