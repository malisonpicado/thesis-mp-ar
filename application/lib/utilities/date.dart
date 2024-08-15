// ISO FORMAT: 2024-07-23T10:38:41.000Z
// Result format: HH:mm-DD/MM/YYYY
String fromIsoToDateFormatted(String isoString) {
  List<String> dateTime= isoString.split("T");
  List<String> date = dateTime[0].split("-");
  List<String> time = dateTime[1].split(":");

  return "${time[0]}:${time[1]}-${date[2]}/${date[1]}/${date[0]}";
}

String fromDateStringToIso(String fecha, bool isFinal) {
  List<String> partesEntrada = fecha.split('/');
  String year = partesEntrada[2];
  String month = partesEntrada[1];
  String day = partesEntrada[0];
  String time = isFinal ? "T05:59:59.000Z" : "T06:00:00.000Z";

  return "$year-$month-$day$time";
}
