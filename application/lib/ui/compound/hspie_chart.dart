import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:tesis_app/ui/core/indicator.dart';

class HSPieChart extends StatefulWidget {
  final double inRange;
  final double outMinRange;
  final double outMaxRange;
  const HSPieChart(
      {super.key,
      required this.inRange,
      required this.outMinRange,
      required this.outMaxRange});

  @override
  State<StatefulWidget> createState() => _HSPieChart();
}

class _HSPieChart extends State<HSPieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        AspectRatio(
          aspectRatio: 16.0 / 9.0,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      touchedIndex = -1;
                      return;
                    }
                    touchedIndex =
                        pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              borderData: FlBorderData(
                show: false,
              ),
              sectionsSpace: 0,
              centerSpaceRadius: 40,
              sections: showingSections(
                  inRange: widget.inRange,
                  outMinRange: widget.outMinRange,
                  outMaxRange: widget.outMaxRange),
            ),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Indicator(
              color: Colors.blue.shade700,
              text: '% óptimas condiciones',
              isSquare: true,
            ),
            const SizedBox(
              height: 4,
            ),
            const Indicator(
              color: Colors.orange,
              text: '% tiempo límite inferior',
              isSquare: true,
            ),
            const SizedBox(
              height: 4,
            ),
            Indicator(
              color: Colors.red.shade700,
              text: '% tiempo límite superior',
              isSquare: true,
            ),
          ],
        ),
      ],
    );
  }

  List<PieChartSectionData> showingSections(
      {required double inRange,
      required double outMinRange,
      required double outMaxRange}) {
    return List.generate(3, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 60.0 : 50.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: Colors.blue.shade700,
            value: inRange,
            title: '$inRange%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: shadows,
            ),
          );
        case 1:
          return PieChartSectionData(
            color: Colors.orange,
            value: outMinRange,
            title: '$outMinRange%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              shadows: shadows,
            ),
          );
        case 2:
          return PieChartSectionData(
            color: Colors.red.shade700,
            value: outMaxRange,
            title: '$outMaxRange%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: shadows,
            ),
          );
        default:
          throw Error();
      }
    });
  }
}
