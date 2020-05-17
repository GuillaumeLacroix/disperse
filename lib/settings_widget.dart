import 'package:disperse/util/configuration.dart';
import 'package:disperse/util/user_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'animation/color_utilities.dart';
import 'util/default_colors.dart';
import 'animation/shapes_utilities.dart';

class SettingsButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
          alignment: Alignment.topRight,
          child: FloatingActionButton(
            backgroundColor: Colors.transparent,
            foregroundColor: DefaultColors().settingsButtonColor,
            elevation: 0,
            child: Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(PageRouteBuilder(
                opaque: false,
                pageBuilder: (BuildContext context,_,__) {
                  return Scaffold(
                        backgroundColor: DefaultColors().opacityBlackColor,
                        body: SettingsPanel());
                },
                fullscreenDialog: true,
              ));
            },
          )),
    );
  }
}

class SettingsPanel extends StatefulWidget {
  @override
  _SettingsPanelState createState() => _SettingsPanelState();
}

class _SettingsPanelState extends State<SettingsPanel> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: Colors.transparent,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(5.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Colors',
                  style: Theme.of(context).textTheme.headline6,
                )),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: generateColors(),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Shapes',
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: generateShapes(),
            ),
            RadiusSliderWidget(),
            RaisedButton(
                shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(18.0),
                    side: BorderSide(
                        color: DefaultColors().selectedColor,
                        width: Configuration.SETTINGS_STROKE_WIDTH)),
                color: DefaultColors().fillColor,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Recording',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pushNamed('/recordings');
                }),
            Flexible(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 24.0),
                  child: IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    color: DefaultColors().settingsCloseButtonColor,
                    icon: Icon(Icons.cancel, size: 60,),
                    iconSize: 60,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  List<Widget> generateColors() {
    List<Widget> res = [];
    for (int i = 0; i < ColorUtilities.colors.length; i++) {
      res.add(ColorWidget(
        index: i,
      ));
    }
    return res;
  }

  List<Widget> generateShapes() {
    List<Widget> res = [];
    for (int i = 0; i < Shape.values.length; i++) {
      res.add(ShapeWidget(
        index: i,
      ));
    }
    return res;
  }
}

class RadiusSliderWidget extends StatefulWidget {
  @override
  _RadiusSliderWidgetState createState() => _RadiusSliderWidgetState();
}

class _RadiusSliderWidgetState extends State<RadiusSliderWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            'Shape radius',
            style: Theme.of(context)
                .textTheme
                .headline6
                .copyWith(color: DefaultColors().settingsTextColor),
          ),
          Flexible(
            child: Slider(
              min: Configuration.MIN_RADIUS_VALUE,
              max: Configuration.MAX_RADIUS_VALUE,
              value: UserPreferencesUtilities.getMaxRadius(),
              onChanged: (double value) {
                UserPreferencesUtilities.setMaxRadius(value).then((_) {
                  setState(() {});
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
