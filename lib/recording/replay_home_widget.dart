import 'package:disperse/recording/recording_saver.dart';
import 'package:disperse/recording/replay_list_widget.dart';
import 'package:disperse/recording/replay_manager.dart';
import 'package:disperse/recording/replay_metadata.dart';
import 'package:disperse/recording/replay_widget.dart';
import 'package:disperse/util/default_colors.dart';
import 'package:flutter/material.dart';

class ReplayHomeWidget extends StatefulWidget {
  static const String ROUTE_NAME = '/recordings';

  @override
  _ReplayHomeWidgetState createState() => _ReplayHomeWidgetState();
}

class _ReplayHomeWidgetState extends State<ReplayHomeWidget> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Recordings'),
          centerTitle: true,
          bottom: TabBar(
            tabs: <Widget>[
              Tab(
                child: Text('Session'),
              ),
              Tab(child: Text('Saved')),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Stack(children: <Widget>[
            TabBarView(
              children: <Widget>[
                ReplayListWidget(selected: ReplayListWidget.SESSION_INDEX),
                ReplayListWidget(
                    key: UniqueKey(), selected: ReplayListWidget.SAVED_INDEX),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: FloatingActionButton(
                backgroundColor: DefaultColors().loadBackgroundColor,
                child: Text('Load'),
                onPressed: () {
                  RecordingSaver().ingestFile().then((fileName) {
                    if (fileName != null) {
                      if (fileName is bool) {
                        if (!fileName) {
                          Scaffold.of(context).showSnackBar(SnackBar(
                              content:
                                  Text('File already exists with this name')));
                        }
                        return;
                      }
                      setState(() {});
                      ReplayManager()
                          .getEvents(ReplayMetadata()
                            ..title = fileName
                            ..isSaved = true)
                          .then((val) {
                        Navigator.of(context)
                            .pushNamed(ReplayWidget.ROUTE_NAME, arguments: val);
                        setState(() {});
                      });
                    }
                  });
                },
              ),
            )
          ]),
        ),
      ),
      length: 2,
    );
  }
}
