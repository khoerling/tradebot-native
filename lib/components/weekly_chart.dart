import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:bezier_chart/bezier_chart.dart';

class WeeklyChart extends StatelessWidget {
  const WeeklyChart({Key key, List<DateTime> this.alerted}) : super(key: key);
  final alerted;
  int dayOfYear(DateTime date) {
    return int.parse(DateFormat("D").format(date));
  }

  pointsFromDates(List<DateTime> dates) {
    DateTime last;
    int lastDay, curDay, count = 1;
    List<DataPoint> points = [];
    for (DateTime cur in dates) {
      curDay = dayOfYear(cur);
      if (curDay == lastDay) {
        // contiguous, so-- update count
        count += 1;
      } else {
        if (last != null) {
          // append last & reset
          points.add(DataPoint<DateTime>(value: count.toDouble(), xAxis: last));
          count = 1;
        } else {
          // first iteration
        }
      }
      // next
      last = cur;
      lastDay = curDay;
    }
    // don't forget last date
    points.add(DataPoint<DateTime>(value: count.toDouble(), xAxis: last));
    return points;
  }

  @override
  Widget build(BuildContext context) {
    if (alerted.isEmpty) return Container();
    final fromDate = alerted.last, toDate = alerted.first;
    return Center(
      child: Container(
        height: MediaQuery.of(context).size.height / 2,
        width: MediaQuery.of(context).size.width,
        child: BezierChart(
          bezierChartScale: BezierChartScale.WEEKLY,
          fromDate: fromDate,
          toDate: DateTime.now(),
          selectedDate: toDate,
          series: [
            BezierLine(
              label: 'Alerts',
              onMissingValue: (dateTime) {
                return 0.0;
              },
              data: pointsFromDates(alerted),
            ),
          ],
          config: BezierChartConfig(
            backgroundColor: Colors.white.withOpacity(.1),
            verticalIndicatorStrokeWidth: 3.0,
            verticalIndicatorColor: Colors.white.withOpacity(.1),
            showVerticalIndicator: true,
            verticalIndicatorFixedPosition: false,
            footerHeight: 30.0,
          ),
        ),
      ),
    );
  }
}
