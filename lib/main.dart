import 'package:disperse/animation/background_utilities.dart';
import 'package:disperse/animation/color_utilities.dart';
import 'package:disperse/animation/shapes_utilities.dart';
import 'package:disperse/loading_screen.dart';
import 'package:disperse/recording/replay_home_widget.dart';
import 'package:disperse/recording/replay_manager.dart';
import 'package:disperse/recording/replay_widget.dart';
import 'package:disperse/settings_widget.dart';
import 'package:disperse/util/configuration.dart';
import 'package:disperse/util/default_colors.dart';
import 'package:disperse/util/portrait_mode.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:disperse/util/user_preferences.dart';
import 'package:disperse/touch_listener.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await UserPreferencesUtilities.init()
      .then((_) => BackgroundUtilities.init())
      .then((_) => ColorUtilities.init())
      .then((_) => ShapesUtilities.init());
  ReplayManager().init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget with PortraitModeMixin {

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return MaterialApp(
      title: 'Disperse',
      darkTheme: ThemeData.dark().copyWith(
          textTheme: ThemeData.dark().textTheme.copyWith(
              headline6: ThemeData.dark().textTheme.headline6.copyWith(
                  fontSize: Configuration.TITLE_SIZE, color: DefaultColors().settingsTextColor))),
      themeMode: ThemeMode.dark,
      initialRoute: '/loadingScreen',
      routes: {
        '/loadingScreen': (context) => LoadingScreen(),
        '/': (context) => Scaffold(
          body: Stack(children: <Widget>[
            Center(
              child: TouchListener(),
            ),
            SettingsButton(),
          ]),
        ),
        ReplayHomeWidget.ROUTE_NAME: (context) => ReplayHomeWidget(),
        ReplayWidget.ROUTE_NAME: (context) => ReplayWidget(),
      },
    );
  }
}
