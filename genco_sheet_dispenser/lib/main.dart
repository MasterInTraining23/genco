import 'package:flutter/material.dart';
import 'package:genco_sheet_dispenser/app_config.dart';
import 'package:genco_sheet_dispenser/auth_page.dart';
import 'package:genco_sheet_dispenser/coordination_model.dart';
import 'package:genco_sheet_dispenser/eco_informational_page.dart';
import 'package:genco_sheet_dispenser/error_page.dart';
import 'package:genco_sheet_dispenser/home_page.dart';
import 'package:genco_sheet_dispenser/models/dynamo_db_service.dart';
import 'package:genco_sheet_dispenser/navigator.dart';
import 'package:genco_sheet_dispenser/sheet_selection_page.dart';
import 'package:genco_sheet_dispenser/survey_question_correct.dart';
import 'package:genco_sheet_dispenser/survey_question_incorrect.dart';
import 'package:genco_sheet_dispenser/survey_question_page.dart';
import 'package:provider/provider.dart';

void main() async {
  DynamoDbService.initialize();
  await AppConfig.getAppConfig().startPolling();

  runApp(
    ChangeNotifierProvider(
      create: (context) => CoordinationModel(),
      child: const GencoApp(),
    ),
  );
}

class GencoApp extends StatelessWidget {
  const GencoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final coordinationModel = Provider.of<CoordinationModel>(context);
    coordinationModel.startFlow();
    final pageInfo = coordinationModel.getCurrentPageRenderingInfo();
    final pageRoute = pageInfo["route"];

    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Generation Conscious Kiosk App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: "OwnersXNarrow",
        textTheme: TextTheme(
          titleLarge: TextStyle(
            color: Colors.red,
            fontSize: 52,
            fontWeight: FontWeight.bold,
          ),
          headlineLarge: TextStyle(
            color: Colors.red,
            fontSize: 52,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.underline,
            decorationColor: Colors.red,
            decorationStyle: TextDecorationStyle.solid,
          ),
          bodyLarge: TextStyle(
            color: Colors.red,
            fontSize: 46,
            fontWeight: FontWeight.bold,
          ),
          bodyMedium: TextStyle(
            color: Colors.red,
            fontSize: 38,
            fontWeight: FontWeight.bold,
          ),
          bodySmall: TextStyle(
            color: Colors.red,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            disabledBackgroundColor: Colors.transparent,
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            elevation: 0,
          ),
        ),
        useMaterial3: true,
      ),
      onUnknownRoute: (settings) {
        return MaterialPageRoute(builder: (context) => const HomePage());
      },
      initialRoute: pageRoute,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/home':
            return _NoTransitionPageRoute(HomePage());
          case '/auth':
            return _NoTransitionPageRoute(AuthPage());
          case '/sheet_selection':
            return _NoTransitionPageRoute(SheetSelectionPage());
          case '/survey_question':
            return _NoTransitionPageRoute(SurveyQuestionPage());
          case '/eco_informational':
            return _NoTransitionPageRoute(EcoInformationalPage());
          case '/error':
            return _NoTransitionPageRoute(
                ErrorPage(pageArguments: settings.arguments));
          case '/survey_question/correct':
            return _NoTransitionPageRoute(CorrectlyAnsweredSurveyQuestionPage(
                pageArguments: settings.arguments));
          case '/survey_question/incorrect':
            return _NoTransitionPageRoute(InorrectlyAnsweredSurveyQuestionPage(
                pageArguments: settings.arguments));
          default:
            break;
        }
        return null; // For other routes, the default route behavior is applied
      },
    );
  }
}

class _NoTransitionPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  _NoTransitionPageRoute(this.page)
      : super(
          pageBuilder: (context, animation, secondaryAnimation) {
            return page; // The page is shown immediately, no animation
          },
          transitionDuration: Duration(seconds: 0), // No transition duration
        );
}
