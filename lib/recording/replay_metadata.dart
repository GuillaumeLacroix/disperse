
class ReplayMetadata extends Comparable<ReplayMetadata> {
  DateTime _date;
  int bgIndex;
  bool isSaved = false;
  bool isSession = false;
  String title;

  DateTime get date => _date;
  set date(DateTime newDate) => _date = newDate.subtract(Duration(microseconds: newDate.microsecond));

  @override
  int compareTo(ReplayMetadata other) {
    return other.date.difference(date).inMilliseconds;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ReplayMetadata &&
              runtimeType == other.runtimeType &&
              _date == other._date &&
              bgIndex == other.bgIndex &&
              isSaved == other.isSaved &&
              isSession == other.isSession &&
              title == other.title;

  @override
  int get hashCode =>
      _date.hashCode ^
      bgIndex.hashCode ^
      isSaved.hashCode ^
      isSession.hashCode ^
      title.hashCode;

  @override
  String toString() {
    return 'ReplayMetadata{_date: $_date, bgIndex: $bgIndex, isSaved: $isSaved, isSession: $isSession, title: $title}';
  }

}