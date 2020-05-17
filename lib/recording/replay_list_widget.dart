import 'package:disperse/animation/background_utilities.dart';
import 'package:disperse/recording/recorder.dart';
import 'package:disperse/recording/recording_saver.dart';
import 'package:disperse/recording/replay_manager.dart';
import 'package:disperse/recording/replay_metadata.dart';
import 'package:disperse/recording/replay_widget.dart';
import 'package:disperse/util/default_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReplayListWidget extends StatefulWidget {
  static const SESSION_INDEX = 0;
  static const SAVED_INDEX = 1;

  final int selected;

  const ReplayListWidget({Key key, this.selected}) : super(key: key);

  @override
  _ReplayListWidgetState createState() => _ReplayListWidgetState(this.selected);
}

class _ReplayListWidgetState extends State<ReplayListWidget> {
  final int tabIndex;
  List<ReplayMetadata> metadatas;

  _ReplayListWidgetState(this.tabIndex);

  @override
  void initState() {
    super.initState();
    recalculateReplays();
  }

  void recalculateReplays() {
    metadatas = ReplayManager().getMetadatas();
    metadatas = metadatas
        .where((rm) => tabIndex == ReplayListWidget.SAVED_INDEX
            ? rm.isSaved
            : rm.isSession)
        .toList();
    metadatas.sort();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        key: ObjectKey(metadatas),
        itemCount: metadatas.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          ReplayMetadata rm = metadatas[index];
          return Container(
              color: tabIndex == ReplayListWidget.SESSION_INDEX && rm.isSaved
                  ? DefaultColors().savedBackgroundColor
                  : null,
              child: ReplayMetadataWidget(rm: rm, parent: this));
        });
  }
}

class ReplayMetadataWidget extends StatefulWidget {
  final ReplayMetadata rm;
  final _ReplayListWidgetState parent;

  ReplayMetadataWidget({this.rm, this.parent}) : super(key: ObjectKey(rm));

  @override
  _ReplayMetadataWidgetState createState() => _ReplayMetadataWidgetState();
}

class _ReplayMetadataWidgetState extends State<ReplayMetadataWidget> {
  @override
  Widget build(BuildContext context) {
    int bgIndex = widget.rm.bgIndex;
    DateTime from = widget.rm.date;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onLongPress: !widget.rm.isSaved
            ? null
            : () {
                TextEditingController controller =
                    TextEditingController(text: widget.rm.title);
                showDialog(
                    context: context,
                    builder: (innerContext) {
                      return AlertDialog(
                        title: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                'Rename file to...',
                                style: TextStyle(fontSize: 16),
                              ),
                              TextField(
                                controller: controller,
                              )
                            ]),
                        actions: <Widget>[
                          FlatButton(
                            child: Text('Cancel'),
                            onPressed: () {
                              Navigator.of(innerContext).pop();
                            },
                          ),
                          FlatButton(
                            child: Text('Confirm'),
                            onPressed: () {
                              String text = controller.text;
                              if (text.length >= 3) {
                                try {
                                  RecordingSaver()
                                      .renameFile(
                                          widget.rm.title, controller.text)
                                      .then((val) {
                                    if (val) {
                                      Navigator.of(innerContext).pop(true);
                                    } else {
                                      Scaffold.of(context).showSnackBar(
                                          SnackBar(
                                              content:
                                                  Text('File already exists')));
                                    }
                                  }).catchError((err) {
                                    Scaffold.of(context).showSnackBar(SnackBar(
                                        content: Text('An error occured')));
                                  });
                                } catch (_) {
                                  Scaffold.of(context).showSnackBar(SnackBar(
                                      content: Text('An error occured')));
                                }
                              }
                            },
                          ),
                        ],
                      );
                    }).then((val) {
                  if (val is bool && val == true) {
                    setState(() {});
                  }
                });
              },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                        widget.rm.isSaved
                            ? widget.rm.title
                            : DateFormat('dd_MM_yyyy_HH_mm_ss').format(from),
                        style: TextStyle(fontSize: 16), textAlign: TextAlign.center,),
                    Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          IconButton(
                            icon: widget.rm.isSaved
                                ? Icon(Icons.favorite)
                                : Icon(Icons.favorite_border),
                            onPressed: () {
                              widget.rm.isSaved
                                  ? RecordingSaver()
                                      .deleteFile(widget.rm)
                                      .whenComplete(() {
                                      this.widget.parent.recalculateReplays();
                                    })
                                  : RecordingSaver()
                                      .writeEventList(widget.rm,
                                          Recorder().getReplayFrom(from))
                                      .whenComplete(() {
                                      this.widget.parent.recalculateReplays();
                                    });
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.share),
                            onPressed: () {
                              RecordingSaver().shareFile(widget.rm);
                            },
                          )
                        ]),
                  ],
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                  onTap: () => ReplayManager().getEvents(widget.rm).then((val) {
                    Navigator.of(context).pushNamed(
                        ReplayWidget.ROUTE_NAME,
                        arguments: val);
                      }),
                  child: Image(
                      fit: BoxFit.contain,
                      image: BackgroundUtilities.getBackground(bgIndex))),
            )
          ],
        ),
      ),
    );
  }
}
