class TimeProviderResult {
  final DateTime dateTime;
  final Geh geh;
  final String dayPhase;
  final int chogNumber;

  const TimeProviderResult({
    required this.dateTime,
    required this.geh,
    required this.dayPhase,
    required this.chogNumber,
  });
}

enum Geh { Ushahin, Havan, Rapithwan, Uzirin, Aevishuthrem }
