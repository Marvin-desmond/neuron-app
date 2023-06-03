import 'package:flutter_native/file_progress.dart';
import 'package:flutter_native/global.dart';
import 'package:flutter_native/catalog/model_catalog.dart';
import 'package:flutter_native/test_screen.dart';
import 'package:flutter_native/model_cards.dart';
import 'package:flutter_native/playground/model_playground.dart';
import 'package:flutter_native/ml_store/ml_model_class.dart';

class ScreenPaths {
  static String home = 'home';
  static String modelCards = 'model_cards';
  static String modelPlayground = 'model_playground';
  static String fileProgress = "file_progress";
  static String modelCatalog = "model_catalog";
}

final GoRouter appRouter = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      name: ScreenPaths.home,
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const TestApp();
      },
      routes: <RouteBase>[
        GoRoute(
          name: ScreenPaths.modelCards,
          path: "model_cards",
          builder: (BuildContext context, GoRouterState state) {
            return ModelCards();
          },
        ),
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
          name: ScreenPaths.fileProgress,
          path: "file_progress",
          builder: (BuildContext context, GoRouterState state) {
            return const FileProgress();
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
